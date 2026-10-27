//! One WebSocket to one relay: through Tor's SOCKS port (the relay's name is
//! resolved by Tor, never locally), then TLS, then the WebSocket handshake.

use std::sync::Arc;
use std::time::Duration;

use futures_util::{SinkExt, StreamExt};
use rustls::pki_types::ServerName;
use serde_json::{Value, json};
use tokio::io::{AsyncRead, AsyncWrite};
use tokio::net::TcpStream;
use tokio_rustls::TlsConnector;
use tokio_tungstenite::WebSocketStream;
use tokio_tungstenite::tungstenite::Message;

use crate::NetError;
use crate::event::{Event, Filter};

/// Any byte stream a WebSocket can run over.
pub(crate) trait Io: AsyncRead + AsyncWrite + Unpin + Send {}
impl<T: AsyncRead + AsyncWrite + Unpin + Send> Io for T {}

pub(crate) type Socket = WebSocketStream<Box<dyn Io>>;

const CONNECT_TIMEOUT: Duration = Duration::from_secs(60);

/// `wss://host[:port][/path]` as host, port.
pub(crate) fn host_port(url: &str) -> Result<(String, u16), NetError> {
    let rest = url.strip_prefix("wss://").ok_or(NetError::Url)?;
    let authority = rest.split('/').next().unwrap_or_default();
    let (host, port) = match authority.rsplit_once(':') {
        Some((h, p)) => (h, p.parse().map_err(|_| NetError::Url)?),
        None => (authority, 443),
    };
    if host.is_empty()
        || !host
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b == b'.' || b == b'-')
    {
        return Err(NetError::Url);
    }
    Ok((host.to_ascii_lowercase(), port))
}

fn tls() -> TlsConnector {
    let roots = rustls::RootCertStore::from_iter(webpki_roots::TLS_SERVER_ROOTS.iter().cloned());
    let config = rustls::ClientConfig::builder_with_provider(Arc::new(
        rustls::crypto::ring::default_provider(),
    ))
    .with_safe_default_protocol_versions()
    .map(|b| b.with_root_certificates(roots).with_no_client_auth());
    // the ring provider supports the default versions; this cannot fail
    TlsConnector::from(Arc::new(config.unwrap_or_else(|_| {
        rustls::ClientConfig::builder()
            .with_root_certificates(rustls::RootCertStore::empty())
            .with_no_client_auth()
    })))
}

/// Opens a WebSocket to `url`, through Tor when `socks` is a port. Each
/// connection gets its own SOCKS credentials, so Tor builds it its own
/// circuit (IsolateSOCKSAuth): relays cannot link one connection to another
/// by exit.
pub(crate) async fn connect(url: &str, socks: Option<u16>) -> Result<Socket, NetError> {
    let (host, port) = host_port(url)?;
    let go = async {
        let tcp: Box<dyn Io> = match socks {
            Some(p) => {
                let mut user = [0u8; 8];
                getrandom::fill(&mut user).map_err(|_| NetError::Key)?;
                let user: String = user.iter().map(|b| format!("{b:02x}")).collect();
                Box::new(
                    tokio_socks::tcp::Socks5Stream::connect_with_password(
                        ("127.0.0.1", p),
                        (host.as_str(), port),
                        &user,
                        "kilit",
                    )
                    .await
                    .map_err(|e| NetError::Connect(e.to_string()))?,
                )
            }
            None => Box::new(
                TcpStream::connect((host.as_str(), port))
                    .await
                    .map_err(|e| NetError::Connect(e.to_string()))?,
            ),
        };
        let name = ServerName::try_from(host.clone()).map_err(|_| NetError::Url)?;
        let tls: Box<dyn Io> = Box::new(
            tls()
                .connect(name, tcp)
                .await
                .map_err(|e| NetError::Connect(e.to_string()))?,
        );
        let (ws, _) = tokio_tungstenite::client_async(url, tls)
            .await
            .map_err(|e| NetError::Connect(e.to_string()))?;
        Ok(ws)
    };
    tokio::time::timeout(CONNECT_TIMEOUT, go)
        .await
        .map_err(|_| NetError::Connect("timed out".into()))?
}

pub(crate) async fn send(ws: &mut Socket, v: Value) -> Result<(), NetError> {
    ws.send(Message::text(v.to_string()))
        .await
        .map_err(|e| NetError::Connect(e.to_string()))
}

pub(crate) fn req(sub: &str, filter: &Filter) -> Value {
    json!(["REQ", sub, filter.to_json()])
}

pub(crate) fn publish(e: &Event) -> Value {
    json!(["EVENT", e])
}

/// What a relay said.
#[derive(Debug)]
pub(crate) enum Said {
    Event(String, Box<Event>),
    Ok(String, bool),
    EndOfStored(String),
    Closed(String),
    Other,
}

pub(crate) fn read(text: &str) -> Said {
    let Ok(Value::Array(a)) = serde_json::from_str::<Value>(text) else {
        return Said::Other;
    };
    let word = a.first().and_then(Value::as_str);
    let s = |i: usize| {
        a.get(i)
            .and_then(Value::as_str)
            .unwrap_or_default()
            .to_owned()
    };
    match word {
        Some("EVENT") => match a.get(2).cloned().map(serde_json::from_value::<Event>) {
            Some(Ok(e)) => Said::Event(s(1), Box::new(e)),
            _ => Said::Other,
        },
        Some("OK") => Said::Ok(s(1), a.get(2).and_then(Value::as_bool).unwrap_or(false)),
        Some("EOSE") => Said::EndOfStored(s(1)),
        Some("CLOSED") => Said::Closed(s(1)),
        _ => Said::Other,
    }
}

/// The next text frame, answering pings on the way; None when closed.
pub(crate) async fn next(ws: &mut Socket) -> Option<String> {
    while let Some(m) = ws.next().await {
        match m {
            Ok(Message::Text(t)) => return Some(t.to_string()),
            Ok(Message::Ping(p)) => {
                let _ = ws.send(Message::Pong(p)).await;
            }
            Ok(Message::Close(_)) | Err(_) => return None,
            Ok(_) => {}
        }
    }
    None
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use super::*;

    #[test]
    fn relay_urls() {
        assert_eq!(host_port("wss://nos.lol").unwrap(), ("nos.lol".into(), 443));
        assert_eq!(
            host_port("wss://relay.example:8443/x").unwrap(),
            ("relay.example".into(), 8443)
        );
        for bad in [
            "ws://nos.lol",
            "https://nos.lol",
            "wss://",
            "wss://a b",
            "wss://x:yz",
        ] {
            assert!(host_port(bad).is_err(), "{bad}");
        }
    }

    #[test]
    fn relay_words() {
        assert!(matches!(read(r#"["OK","ab",true,""]"#), Said::Ok(id, true) if id == "ab"));
        assert!(matches!(read(r#"["EOSE","s"]"#), Said::EndOfStored(s) if s == "s"));
        assert!(matches!(read(r#"["NOTICE","x"]"#), Said::Other));
        assert!(matches!(read("not json"), Said::Other));
        assert!(matches!(read(r#"["EVENT","s",{"id":1}]"#), Said::Other));
    }
}
