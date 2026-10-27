//! Talks to a real relay. Needs the internet, so it runs only with
//! KILIT_NET_LIVE=1; with KILIT_SOCKS=<port> it goes through Tor.

#![allow(clippy::unwrap_used)]

use std::time::{Duration, SystemTime};

use kilit_net::{Event, Filter, Net};

#[test]
fn publish_then_watch_and_query() {
    if std::env::var("KILIT_NET_LIVE").as_deref() != Ok("1") {
        eprintln!("set KILIT_NET_LIVE=1 to reach a relay");
        return;
    }
    let socks = std::env::var("KILIT_SOCKS")
        .ok()
        .and_then(|p| p.parse().ok());
    let relay = std::env::var("KILIT_RELAY").unwrap_or_else(|_| "wss://nos.lol".into());
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;
    let mut tag = [0u8; 32];
    getrandom::fill(&mut tag).unwrap();
    let tag: String = tag.iter().map(|b| format!("{b:02x}")).collect();
    let filter = Filter {
        kinds: vec![1059],
        tags: vec![('p', vec![tag.clone()])],
        since: Some(now - 60),
        limit: None,
    };

    let net = Net::start(socks, vec![relay.clone()]).unwrap();
    net.watch(filter.clone());
    let e = Event::sign_once(
        now,
        1059,
        vec![vec!["p".into(), tag.clone()]],
        "a2lsaXQgdGVzdA".into(),
    )
    .unwrap();
    // let the watcher connect first, then publish
    let deadline = std::time::Instant::now() + Duration::from_secs(90);
    while !net.status()[0].connected {
        assert!(
            std::time::Instant::now() < deadline,
            "no connection to {relay}"
        );
        std::thread::sleep(Duration::from_millis(200));
    }
    net.publish(e.clone());
    let mut got = Vec::new();
    while got.is_empty() || net.stored(&e.id) == 0 {
        assert!(
            std::time::Instant::now() < deadline,
            "nothing back from {relay}"
        );
        got.extend(net.take());
        std::thread::sleep(Duration::from_millis(200));
    }
    assert_eq!(got, vec![e.clone()]);
    assert_eq!(net.stored(&e.id), 1);

    let found = net.query(&filter, Duration::from_secs(30));
    assert_eq!(found, vec![e]);
}
