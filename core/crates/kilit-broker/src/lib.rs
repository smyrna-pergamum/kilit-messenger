//! Coordinator (the dom0 of Kilit).
//!
//! Starts each compartment as its own process and routes every request through the policy in kilit-ipc. It has no network access and holds no keys.
