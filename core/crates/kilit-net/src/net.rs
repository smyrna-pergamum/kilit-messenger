//! The relays together: one long-lived connection each, watching the inbox
//! tags; publishing to all of them; one-off queries for contact cards.

use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::{Arc, Mutex, MutexGuard};
use std::time::Duration;

use tokio::runtime::Runtime;
use tokio::sync::mpsc;

use crate::NetError;
use crate::event::{Event, Filter};
use crate::relay::{self, Said};

const INBOX: &str = "inbox";
const QUERY: &str = "query";
/// Event ids remembered, so the same event from six relays counts once.
const SEEN_KEPT: usize = 20_000;
const FIRST_RETRY: Duration = Duration::from_secs(5);
const LAST_RETRY: Duration = Duration::from_secs(120);

/// How one relay is doing.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RelayStatus {
    /// Its address.
    pub url: String,
    /// Whether a connection is open now.
    pub connected: bool,
}

#[derive(Default)]
struct Shared {
    filter: Option<Filter>,
    inbox: Vec<Event>,
    seen: HashSet<String>,
    seen_order: VecDeque<String>,
    /// Event id -> relays that stored it.
    stored: HashMap<String, usize>,
    connected: HashMap<String, bool>,
}

impl Shared {
    fn first_time(&mut self, id: &str) -> bool {
        if !self.seen.insert(id.to_owned()) {
            return false;
        }
        self.seen_order.push_back(id.to_owned());
        if self.seen_order.len() > SEEN_KEPT
            && let Some(old) = self.seen_order.pop_front()
        {
            self.seen.remove(&old);
        }
        true
    }
}

enum Command {
    Publish(Event),
    Filter,
}

/// The relays, over Tor. Dropping it closes every connection.
pub struct Net {
    rt: Runtime,
    socks: Option<u16>,
    relays: Vec<String>,
    shared: Arc<Mutex<Shared>>,
    commands: Vec<mpsc::UnboundedSender<Command>>,
}

fn lock(s: &Mutex<Shared>) -> MutexGuard<'_, Shared> {
    // a panic while holding it would only leave counters half-updated
    s.lock().unwrap_or_else(|p| p.into_inner())
}

impl Net {
    /// Connects to `relays` (`wss://` URLs), through Tor's SOCKS port when
    /// `socks` is given; without it only for tests.
    pub fn start(socks: Option<u16>, relays: Vec<String>) -> Result<Self, NetError> {
        let rt = tokio::runtime::Builder::new_multi_thread()
            .worker_threads(2)
            .enable_all()
            .thread_name("kilit-net")
            .build()
            .map_err(|e| NetError::Connect(e.to_string()))?;
        let shared = Arc::new(Mutex::new(Shared::default()));
        let mut commands = Vec::new();
        for url in &relays {
            relay::host_port(url)?;
            let (tx, rx) = mpsc::unbounded_channel();
            commands.push(tx);
            rt.spawn(keep(url.clone(), socks, shared.clone(), rx));
        }
        Ok(Self {
            rt,
            socks,
            relays,
            shared,
            commands,
        })
    }

    /// Watches for events matching `filter` from now on, in place of the
    /// filter before.
    pub fn watch(&self, filter: Filter) {
        lock(&self.shared).filter = Some(filter);
        for c in &self.commands {
            let _ = c.send(Command::Filter);
        }
    }

    /// Sends `event` to every relay. [`Net::stored`] says how many kept it.
    pub fn publish(&self, event: Event) {
        lock(&self.shared)
            .stored
            .entry(event.id.clone())
            .or_insert(0);
        for c in &self.commands {
            let _ = c.send(Command::Publish(event.clone()));
        }
    }

    /// How many relays said they stored the event with this id.
    pub fn stored(&self, id: &str) -> usize {
        lock(&self.shared).stored.get(id).copied().unwrap_or(0)
    }

    /// Events that arrived since the last call, each once, all verified.
    pub fn take(&self) -> Vec<Event> {
        std::mem::take(&mut lock(&self.shared).inbox)
    }

    /// Each relay and whether it is connected.
    pub fn status(&self) -> Vec<RelayStatus> {
        let s = lock(&self.shared);
        self.relays
            .iter()
            .map(|url| RelayStatus {
                url: url.clone(),
                connected: s.connected.get(url).copied().unwrap_or(false),
            })
            .collect()
    }

    /// Asks every relay once for what `filter` matches, and waits up to
    /// `wait` for their answers. For looking a contact card up.
    pub fn query(&self, filter: &Filter, wait: Duration) -> Vec<Event> {
        let socks = self.socks;
        self.rt.block_on(async {
            let asks = self.relays.iter().map(|url| {
                let url = url.clone();
                let filter = filter.clone();
                tokio::spawn(async move {
                    tokio::time::timeout(wait, ask(&url, socks, &filter))
                        .await
                        .unwrap_or_default()
                })
            });
            let mut seen = HashSet::new();
            let mut all = Vec::new();
            for a in futures_util::future::join_all(asks).await {
                for e in a.unwrap_or_default() {
                    if e.verify() && filter.matches(&e) && seen.insert(e.id.clone()) {
                        all.push(e);
                    }
                }
            }
            all
        })
    }
}

async fn ask(url: &str, socks: Option<u16>, filter: &Filter) -> Vec<Event> {
    let mut found = Vec::new();
    let Ok(mut ws) = relay::connect(url, socks).await else {
        return found;
    };
    if relay::send(&mut ws, relay::req(QUERY, filter))
        .await
        .is_err()
    {
        return found;
    }
    while let Some(text) = relay::next(&mut ws).await {
        match relay::read(&text) {
            Said::Event(sub, e) if sub == QUERY => found.push(*e),
            Said::EndOfStored(sub) | Said::Closed(sub) if sub == QUERY => break,
            _ => {}
        }
    }
    let _ = ws.close(None).await;
    found
}

/// One relay, for as long as the runtime lives: connect, watch, publish,
/// and when the connection drops, connect again a little later each time.
async fn keep(
    url: String,
    socks: Option<u16>,
    shared: Arc<Mutex<Shared>>,
    mut rx: mpsc::UnboundedReceiver<Command>,
) {
    let mut retry = FIRST_RETRY;
    loop {
        if let Ok(mut ws) = relay::connect(&url, socks).await {
            lock(&shared).connected.insert(url.clone(), true);
            retry = FIRST_RETRY;
            session(&mut ws, &shared, &mut rx).await;
            lock(&shared).connected.insert(url.clone(), false);
        }
        tokio::time::sleep(retry).await;
        retry = (retry * 2).min(LAST_RETRY);
    }
}

async fn session(
    ws: &mut relay::Socket,
    shared: &Mutex<Shared>,
    rx: &mut mpsc::UnboundedReceiver<Command>,
) {
    let watch = |shared: &Mutex<Shared>| lock(shared).filter.clone();
    if let Some(f) = watch(shared)
        && relay::send(ws, relay::req(INBOX, &f)).await.is_err()
    {
        return;
    }
    let mut ping = tokio::time::interval(Duration::from_secs(30));
    loop {
        tokio::select! {
            text = relay::next(ws) => {
                let Some(text) = text else { return };
                match relay::read(&text) {
                    Said::Event(sub, e) if sub == INBOX => {
                        let wanted = lock(shared).filter.as_ref().is_some_and(|f| f.matches(&e));
                        if wanted && e.verify() {
                            let mut s = lock(shared);
                            if s.first_time(&e.id) {
                                s.inbox.push(*e);
                            }
                        }
                    }
                    Said::Ok(id, true) => {
                        if let Some(n) = lock(shared).stored.get_mut(&id) {
                            *n += 1;
                        }
                    }
                    _ => {}
                }
            }
            cmd = rx.recv() => {
                let sent = match cmd {
                    Some(Command::Publish(e)) => relay::send(ws, relay::publish(&e)).await,
                    Some(Command::Filter) => match watch(shared) {
                        Some(f) => relay::send(ws, relay::req(INBOX, &f)).await,
                        None => Ok(()),
                    },
                    None => return,
                };
                if sent.is_err() {
                    return;
                }
            }
            _ = ping.tick() => {
                use futures_util::SinkExt;
                if ws.send(tokio_tungstenite::tungstenite::Message::Ping(Vec::new().into())).await.is_err() {
                    return;
                }
            }
        }
    }
}
