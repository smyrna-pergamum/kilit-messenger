//! Groups of up to [`MAX_GROUP`] people, pairwise: a group message goes to
//! each member over the one-to-one session with them, sealed once per
//! member under one message id. Nothing on the relays says it is a group.
//!
//! **Who decides.** The maker is the group's admin. Only the admin names it,
//! adds and removes people and ends it, by sending everyone the whole
//! roster with a newer stamp; a roster from anyone else, or an older one,
//! is ignored. The admin also sends the roster with every message, so a
//! member who missed a change catches up. Anyone may leave.
//!
//! **Who may put you in one.** Only a contact you accepted. A roster from
//! anyone else opens nothing.
//!
//! **Members you do not know.** The roster carries each member's address
//! and four words. Kilit fetches the card those words name from the relays
//! and checks it against the address (which is a hash of the identity
//! key), then keeps the person as a [`ContactState::Member`]: out of the
//! chats and Requests, there only to write to in the group. Messages to a
//! member whose card has not come yet wait for it.

use super::*;

const GROUPS: &str = "groups";
const GROUPS_NAME: &str = "groups.cbor";
const GROUP_CHAT_NAME: &str = "group.cbor";

/// What a notice line in a group says; its `from` did it, to `about`.
pub mod notice {
    /// `from` made the group.
    pub const CREATED: u8 = 1;
    /// `from` put this vault in the group.
    pub const JOINED: u8 = 2;
    pub const ADDED: u8 = 3;
    pub const REMOVED: u8 = 4;
    pub const LEFT: u8 = 5;
    /// The new name is the line's text.
    pub const RENAMED: u8 = 6;
    pub const ENDED: u8 = 7;
    /// `from` took this vault out.
    pub const REMOVED_YOU: u8 = 8;
}

fn group_blob(id: &str) -> Result<String, EngineError> {
    chat_blob(id).map(|b| b.replacen("chat-", "grp-", 1))
}

/// A group as this vault knows it.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Group {
    /// 32 hex digits.
    pub id: String,
    /// The maker's address.
    pub admin: String,
    pub roster: Roster,
    /// This vault left or was taken out: kept to read, nothing goes out.
    pub gone: bool,
    /// When this vault joined, Unix seconds.
    pub added: i64,
}

impl Group {
    pub fn has(&self, address: &str) -> bool {
        self.roster.members.iter().any(|m| m.address == address)
    }

    /// Nobody writes in it any more, here.
    pub fn closed(&self) -> bool {
        self.gone || self.roster.ended
    }
}

#[derive(Default, Serialize, Deserialize)]
struct Groups {
    list: BTreeMap<String, Group>,
}

/// One member's copy of an outgoing group message.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct Target {
    pub address: String,
    /// The event that carries it; empty while their card is awaited.
    pub event: String,
    pub state: LineState,
    pub tries: u32,
    pub tried: i64,
}

/// A line's state from its members' copies: delivered once every member
/// has it, sent once a relay holds every copy.
fn sum(targets: &[Target]) -> LineState {
    if targets.iter().all(|t| t.state == LineState::Delivered) {
        LineState::Delivered
    } else if targets.iter().all(|t| t.state != LineState::Queued) {
        LineState::Sent
    } else {
        LineState::Queued
    }
}

impl Engine {
    fn groups_all(&self) -> Result<Groups, EngineError> {
        self.load(GROUPS)
    }

    fn save_groups(&self, g: &Groups) -> Result<(), EngineError> {
        self.save(GROUPS, GROUPS_NAME, g)
    }

    fn load_group_chat(&self, id: &str) -> Result<Vec<Line>, EngineError> {
        self.load(&group_blob(id)?)
    }

    fn save_group_chat(&self, id: &str, mut lines: Vec<Line>) -> Result<(), EngineError> {
        if lines.len() > MAX_LINES {
            lines.drain(..lines.len() - MAX_LINES);
        }
        self.save(&group_blob(id)?, GROUP_CHAT_NAME, &lines)
    }

    fn notice(
        &self,
        id: &str,
        what: u8,
        from: &str,
        about: Vec<String>,
        text: &str,
    ) -> Result<(), EngineError> {
        let mut lines = self.load_group_chat(id)?;
        let now = (self.now)();
        lines.push(Line {
            text: text.to_owned(),
            at: now,
            sent: now,
            state: LineState::Delivered,
            from: from.to_owned(),
            notice: what,
            about,
            ..Line::default()
        });
        self.save_group_chat(id, lines)
    }

    /// The groups, newest conversation first, each with its newest line.
    pub fn groups(&self) -> Result<Vec<(Group, Option<Line>)>, EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(Vec::new());
        }
        let mut v = Vec::new();
        for g in self.groups_all()?.list.into_values() {
            let last = self.load_group_chat(&g.id)?.pop();
            v.push((g, last));
        }
        v.sort_by_key(|(g, l)| std::cmp::Reverse(l.as_ref().map_or(g.added, |l| l.at)));
        Ok(v)
    }

    /// This vault's address.
    pub fn my_address(&self) -> Result<String, EngineError> {
        Ok(self.messaging()?.my_address().to_owned())
    }

    pub fn group(&self, id: &str) -> Result<Group, EngineError> {
        self.groups_all()?
            .list
            .remove(id)
            .ok_or(EngineError::NotFound)
    }

    /// A group's conversation, oldest first.
    pub fn group_chat(&self, id: &str) -> Result<Vec<Line>, EngineError> {
        self.group(id)?;
        self.load_group_chat(id)
    }

    /// Seals `content` for one member; None when that cannot be done yet
    /// (no card for them) or at all (blocked).
    fn seal_for(
        &self,
        m: &mut Messaging,
        to: &str,
        content: &Content,
    ) -> Result<Option<Event>, EngineError> {
        match m.seal(to, content, self.system_now()) {
            Ok(out) => Ok(Some(self.message_event(out.tag, &out.payload)?)),
            Err(MessagingError::NoContact | MessagingError::Blocked) => Ok(None),
            Err(e) => Err(messaging_err(e)),
        }
    }

    /// Sends a group's roster to `to`, as the admin. Returns the events.
    fn send_roster(&mut self, g: &Group, to: &[String]) -> Result<Vec<Event>, EngineError> {
        let mut m = self.messaging()?;
        let content = Content {
            group: Some(GroupWire {
                id: ByteBuf::from(unhex(&g.id)?),
                roster: Some(g.roster.clone()),
                leave: false,
            }),
            ..Content::default()
        };
        let mut events = Vec::new();
        let me = m.my_address().to_owned();
        for a in to.iter().filter(|a| **a != me) {
            if let Some(e) = self.seal_for(&mut m, a, &content)? {
                events.push(e);
            }
        }
        self.save_messaging(&m)?;
        self.queue(events.clone())?;
        Ok(events)
    }

    fn admin_group(&self, id: &str) -> Result<(Groups, Group), EngineError> {
        let all = self.groups_all()?;
        let g = all.list.get(id).cloned().ok_or(EngineError::NotFound)?;
        if g.admin != self.messaging()?.my_address() || g.closed() {
            return Err(EngineError::Rejected("only the group's admin can".into()));
        }
        Ok((all, g))
    }

    /// The stamp for a change: now, and above the last one.
    fn next_stamp(&self, g: &Group) -> i64 {
        (self.now)().max(g.roster.stamp + 1)
    }

    fn roster_member(m: &Messaging, address: &str) -> Result<RosterMember, EngineError> {
        if address == m.my_address() {
            return Ok(RosterMember {
                address: address.to_owned(),
                kilit_id: m.kilit_id().to_owned(),
            });
        }
        let c = m
            .contacts()
            .into_iter()
            .find(|c| c.id == address && c.state == ContactState::Accepted)
            .ok_or_else(|| EngineError::Rejected("only contacts can be added".into()))?;
        Ok(RosterMember {
            address: c.id,
            kilit_id: c.kilit_id,
        })
    }

    /// Makes a group of this vault and `members` (accepted contacts) and
    /// tells them. Returns the group and the events.
    pub fn create_group(
        &mut self,
        name: &str,
        members: &[String],
    ) -> Result<(Group, Vec<Event>), EngineError> {
        let m = self.messaging()?;
        let me = m.my_address().to_owned();
        let mut people = vec![Self::roster_member(&m, &me)?];
        for a in members {
            if people.iter().all(|p| p.address != *a) {
                people.push(Self::roster_member(&m, a)?);
            }
        }
        let roster = Roster {
            stamp: (self.now)(),
            name: name.trim().chars().take(MAX_GROUP_NAME).collect(),
            members: people,
            ended: false,
        };
        if !roster.sound() {
            return Err(EngineError::Rejected(format!(
                "a group holds 2 to {MAX_GROUP} people"
            )));
        }
        let g = Group {
            id: hex(&random::<16>()?),
            admin: me.clone(),
            roster,
            gone: false,
            added: (self.now)(),
        };
        let mut all = self.groups_all()?;
        all.list.insert(g.id.clone(), g.clone());
        self.save_groups(&all)?;
        self.notice(&g.id, notice::CREATED, &me, Vec::new(), "")?;
        let to: Vec<String> = g.roster.members.iter().map(|x| x.address.clone()).collect();
        let events = self.send_roster(&g, &to)?;
        Ok((g, events))
    }

    /// Admin: a new name, sent to everyone.
    pub fn rename_group(&mut self, id: &str, name: &str) -> Result<Vec<Event>, EngineError> {
        let (mut all, mut g) = self.admin_group(id)?;
        g.roster.name = name.trim().chars().take(MAX_GROUP_NAME).collect();
        g.roster.stamp = self.next_stamp(&g);
        all.list.insert(g.id.clone(), g.clone());
        self.save_groups(&all)?;
        let me = g.admin.clone();
        self.notice(id, notice::RENAMED, &me, Vec::new(), &g.roster.name)?;
        let to: Vec<String> = g.roster.members.iter().map(|x| x.address.clone()).collect();
        self.send_roster(&g, &to)
    }

    /// Admin: adds contacts; everyone gets the new roster.
    pub fn add_group_members(
        &mut self,
        id: &str,
        add: &[String],
    ) -> Result<Vec<Event>, EngineError> {
        let (mut all, mut g) = self.admin_group(id)?;
        let m = self.messaging()?;
        let mut added = Vec::new();
        for a in add {
            if !g.has(a) {
                g.roster.members.push(Self::roster_member(&m, a)?);
                added.push(a.clone());
            }
        }
        if added.is_empty() {
            return Ok(Vec::new());
        }
        if !g.roster.sound() {
            return Err(EngineError::Rejected(format!(
                "a group holds at most {MAX_GROUP} people"
            )));
        }
        g.roster.stamp = self.next_stamp(&g);
        all.list.insert(g.id.clone(), g.clone());
        self.save_groups(&all)?;
        self.notice(id, notice::ADDED, &g.admin, added, "")?;
        let to: Vec<String> = g.roster.members.iter().map(|x| x.address.clone()).collect();
        self.send_roster(&g, &to)
    }

    /// Admin: takes someone out; they get the roster without them too, so
    /// they know.
    pub fn remove_group_member(&mut self, id: &str, who: &str) -> Result<Vec<Event>, EngineError> {
        let (mut all, mut g) = self.admin_group(id)?;
        if who == g.admin || !g.has(who) {
            return Err(EngineError::NotFound);
        }
        g.roster.members.retain(|x| x.address != who);
        if g.roster.members.len() < 2 {
            g.roster.ended = true;
        }
        g.roster.stamp = self.next_stamp(&g);
        all.list.insert(g.id.clone(), g.clone());
        self.save_groups(&all)?;
        self.notice(id, notice::REMOVED, &g.admin, vec![who.to_owned()], "")?;
        let mut to: Vec<String> = g.roster.members.iter().map(|x| x.address.clone()).collect();
        to.push(who.to_owned());
        self.send_roster(&g, &to)
    }

    /// Admin: ends the group for everyone.
    pub fn end_group(&mut self, id: &str) -> Result<Vec<Event>, EngineError> {
        let (mut all, mut g) = self.admin_group(id)?;
        g.roster.ended = true;
        g.roster.stamp = self.next_stamp(&g);
        all.list.insert(g.id.clone(), g.clone());
        self.save_groups(&all)?;
        self.notice(id, notice::ENDED, &g.admin, Vec::new(), "")?;
        let to: Vec<String> = g.roster.members.iter().map(|x| x.address.clone()).collect();
        self.send_roster(&g, &to)
    }

    /// Leaves a group; the members are told. The admin ends it instead.
    pub fn leave_group(&mut self, id: &str) -> Result<Vec<Event>, EngineError> {
        let mut all = self.groups_all()?;
        let g = all.list.get(id).cloned().ok_or(EngineError::NotFound)?;
        let mut m = self.messaging()?;
        let me = m.my_address().to_owned();
        if g.admin == me {
            return self.end_group(id);
        }
        let mut events = Vec::new();
        if !g.closed() {
            let content = Content {
                group: Some(GroupWire {
                    id: ByteBuf::from(unhex(id)?),
                    roster: None,
                    leave: true,
                }),
                ..Content::default()
            };
            for x in g.roster.members.iter().filter(|x| x.address != me) {
                if let Some(e) = self.seal_for(&mut m, &x.address, &content)? {
                    events.push(e);
                }
            }
            self.save_messaging(&m)?;
            self.queue(events.clone())?;
        }
        if let Some(g) = all.list.get_mut(id) {
            g.gone = true;
        }
        self.save_groups(&all)?;
        self.notice(id, notice::LEFT, &me, Vec::new(), "")?;
        Ok(events)
    }

    /// Forgets a group this vault has left, or that ended: its
    /// conversation and files go too.
    pub fn delete_group(&mut self, id: &str) -> Result<(), EngineError> {
        let mut all = self.groups_all()?;
        let g = all.list.get(id).ok_or(EngineError::NotFound)?;
        if !g.closed() {
            return Err(EngineError::Rejected("leave the group first".into()));
        }
        for l in self.load_group_chat(id)? {
            self.drop_file(&l)?;
        }
        all.list.remove(id);
        self.save_groups(&all)?;
        Ok(self.store.delete(&group_blob(id)?)?)
    }

    /// Sends text to a group.
    pub fn send_group_message(
        &mut self,
        id: &str,
        text: &str,
    ) -> Result<(Line, Vec<Event>), EngineError> {
        self.send_group(id, text, None, Vec::new(), None)
    }

    /// Sends a file to a group: its pieces once, the message to each member.
    pub fn send_group_file(
        &mut self,
        id: &str,
        name: &str,
        mime: &str,
        data: &[u8],
        text: &str,
    ) -> Result<(Line, Vec<Event>), EngineError> {
        let (file, pieces, shown) = self.prepare_file(name, mime, data)?;
        self.send_group(id, text, Some(file), pieces, Some(shown))
    }

    fn group_content(&self, g: &Group, me: &str, line: &Line) -> Result<Content, EngineError> {
        Ok(Content {
            text: line.text.clone(),
            file: line.file_ref.clone(),
            again: Some((line.id.to_vec(), line.sent)),
            group: Some(GroupWire {
                id: ByteBuf::from(unhex(&g.id)?),
                // the admin's every message carries the roster
                roster: (g.admin == me).then(|| g.roster.clone()),
                leave: false,
            }),
            ..Content::default()
        })
    }

    fn send_group(
        &mut self,
        id: &str,
        text: &str,
        file: Option<FileRef>,
        mut pieces: Vec<Event>,
        shown: Option<LineFile>,
    ) -> Result<(Line, Vec<Event>), EngineError> {
        let g = self.group(id)?;
        if g.closed() {
            return Err(EngineError::Rejected("this group is closed".into()));
        }
        if text.len() > MAX_TEXT {
            return Err(EngineError::TooLong);
        }
        let mut m = self.messaging()?;
        let me = m.my_address().to_owned();
        let now = (self.now)();
        let mut line = Line {
            outgoing: true,
            text: text.to_owned(),
            at: now,
            sent: now,
            id: ByteBuf::from(random::<16>()?.to_vec()),
            file: shown,
            file_ref: file,
            ..Line::default()
        };
        let content = self.group_content(&g, &me, &line)?;
        for x in g.roster.members.iter().filter(|x| x.address != me) {
            let event = self.seal_for(&mut m, &x.address, &content)?;
            let mut t = Target {
                address: x.address.clone(),
                ..Target::default()
            };
            if let Some(e) = event {
                t.event = e.id.clone();
                pieces.push(e);
            }
            line.to.push(t);
        }
        self.save_messaging(&m)?;
        self.queue(pieces.clone())?;
        line.state = sum(&line.to);
        let mut lines = self.load_group_chat(id)?;
        lines.push(line.clone());
        self.save_group_chat(id, lines)?;
        Ok((line, pieces))
    }

    /// Group members this vault has no card for yet: their words and
    /// address, to look their cards up with.
    pub fn missing_members(&self) -> Result<Vec<Invite>, EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(Vec::new());
        }
        let m = self.messaging()?;
        let known: Vec<String> = m.contacts().into_iter().map(|c| c.id).collect();
        let mut out: Vec<Invite> = Vec::new();
        for g in self.groups_all()?.list.values().filter(|g| !g.closed()) {
            for x in &g.roster.members {
                if x.address != m.my_address()
                    && !known.contains(&x.address)
                    && out.iter().all(|i| i.address.as_deref() != Some(&x.address))
                {
                    out.push(Invite {
                        id: x.kilit_id.clone(),
                        address: Some(x.address.clone()),
                    });
                }
            }
        }
        Ok(out)
    }

    /// The filter that finds the cards of [`Engine::missing_members`].
    pub fn cards_filter(missing: &[Invite]) -> Filter {
        Filter {
            kinds: vec![CARD_KIND],
            tags: vec![('d', missing.iter().map(|i| card_tag(&i.id)).collect())],
            since: None,
            limit: Some(20 * missing.len().max(1) as u32),
        }
    }

    /// Takes the cards the relays gave for missing members, starts a
    /// session with each that checks out, and sends them what waited.
    /// Returns the events.
    pub fn add_member_cards(&mut self, cards: &[Event]) -> Result<Vec<Event>, EngineError> {
        let missing = self.missing_members()?;
        if missing.is_empty() {
            return Ok(Vec::new());
        }
        let mut found: Vec<(i64, Vec<u8>)> = cards
            .iter()
            .filter(|e| e.kind == CARD_KIND && !e.content.is_empty() && e.verify())
            .filter_map(|e| Some((e.created_at, URL_SAFE_NO_PAD.decode(&e.content).ok()?)))
            .collect();
        found.sort_by_key(|(t, _)| std::cmp::Reverse(*t));
        let mut m = self.messaging()?;
        let mut added = false;
        for inv in &missing {
            // the card's identity must hash to the address the admin gave
            if let Some(card) = found.iter().map(|(_, c)| c).find(|c| card_matches(c, inv))
                && m.add_member(card, inv, self.system_now()).is_ok()
            {
                added = true;
            }
        }
        if !added {
            return Ok(Vec::new());
        }
        self.save_messaging(&m)?;
        self.flush_waiting()
    }

    /// Seals the group messages that waited for a member's card.
    fn flush_waiting(&mut self) -> Result<Vec<Event>, EngineError> {
        let mut m = self.messaging()?;
        let me = m.my_address().to_owned();
        let mut events = Vec::new();
        for g in self
            .groups_all()?
            .list
            .into_values()
            .filter(|g| !g.closed())
        {
            let mut lines = self.load_group_chat(&g.id)?;
            let mut changed = false;
            for l in lines.iter_mut() {
                if !l.outgoing || l.to.iter().all(|t| !t.event.is_empty()) {
                    continue;
                }
                let content = self.group_content(&g, &me, l)?;
                for t in l.to.iter_mut().filter(|t| t.event.is_empty()) {
                    if let Some(e) = self.seal_for(&mut m, &t.address, &content)? {
                        t.event = e.id.clone();
                        events.push(e);
                        changed = true;
                    }
                }
                l.state = sum(&l.to);
            }
            if changed {
                self.save_group_chat(&g.id, lines)?;
            }
        }
        self.save_messaging(&m)?;
        self.queue(events.clone())?;
        Ok(events)
    }

    /// Sends a group message again to every member who has not got it,
    /// with its file's pieces. Returns the events.
    pub fn resend_group_message(
        &mut self,
        id: &str,
        line: &[u8],
    ) -> Result<Vec<Event>, EngineError> {
        let g = self.group(id)?;
        if g.closed() {
            return Ok(Vec::new());
        }
        self.resend_targets(&g, |l| *l.id == *line, true, i64::MIN)
    }

    /// Seals again, under today's mailbox, the copies `which` picks that a
    /// relay kept but no receipt answered, last tried before `before`.
    fn resend_targets(
        &mut self,
        g: &Group,
        which: impl Fn(&Line) -> bool,
        pieces: bool,
        before: i64,
    ) -> Result<Vec<Event>, EngineError> {
        let mut m = self.messaging()?;
        let me = m.my_address().to_owned();
        let now = (self.now)();
        let mut lines = self.load_group_chat(&g.id)?;
        let mut events = Vec::new();
        for l in lines.iter_mut().filter(|l| l.outgoing && which(l)) {
            let content = self.group_content(g, &me, l)?;
            let at = l.at;
            let mut went = false;
            for t in l.to.iter_mut().filter(|t| {
                t.state == LineState::Sent
                    && (before == i64::MIN || (t.tries < MAX_RESENDS && t.tried.max(at) <= before))
            }) {
                if let Some(e) = self.seal_for(&mut m, &t.address, &content)? {
                    t.event = e.id.clone();
                    t.state = LineState::Queued;
                    t.tries += 1;
                    t.tried = now;
                    events.push(e);
                    went = true;
                }
            }
            if went
                && pieces
                && let (Some(f), Some(shown)) = (&l.file_ref, &l.file)
                && !shown.blob.is_empty()
            {
                let data = self.read_attachment(&shown.blob)?;
                let mut p = self.pieces(&f.key, &f.tag, &data)?;
                p.append(&mut events);
                events = p;
            }
            l.state = sum(&l.to);
        }
        self.save_messaging(&m)?;
        if !events.is_empty() {
            self.queue(events.clone())?;
            self.save_group_chat(&g.id, lines)?;
        }
        Ok(events)
    }

    /// Admin: sends the roster of each group in `ids` to its members.
    pub(super) fn send_rosters(&mut self, ids: &[String]) -> Result<(), EngineError> {
        for id in ids {
            let g = self.group(id)?;
            let to: Vec<String> = g.roster.members.iter().map(|x| x.address.clone()).collect();
            self.send_roster(&g, &to)?;
        }
        Ok(())
    }

    /// The group half of [`Engine::resend_due`].
    pub(super) fn resend_due_groups(&mut self) -> Result<usize, EngineError> {
        let before = (self.now)() - RESEND_EVERY;
        let mut n = 0;
        for g in self
            .groups_all()?
            .list
            .into_values()
            .filter(|g| !g.closed())
        {
            n += self.resend_targets(&g, |_| true, false, before)?.len();
        }
        Ok(n)
    }

    /// The group half of [`Engine::mark_stored`] and of receipts: copies a
    /// relay kept, and copies `delivered` (sender, message id) confirms.
    pub(super) fn restate_groups(
        &mut self,
        stored: &[String],
        delivered: &[(String, Vec<u8>)],
    ) -> Result<(), EngineError> {
        for g in self.groups_all()?.list.into_values() {
            let mut lines = self.load_group_chat(&g.id)?;
            let mut changed = false;
            for l in lines.iter_mut().filter(|l| l.outgoing && !l.to.is_empty()) {
                for t in l.to.iter_mut() {
                    if t.state == LineState::Queued && stored.contains(&t.event) {
                        t.state = LineState::Sent;
                        changed = true;
                    }
                    if t.state != LineState::Delivered
                        && delivered
                            .iter()
                            .any(|(who, id)| *who == t.address && **id == *l.id)
                    {
                        t.state = LineState::Delivered;
                        changed = true;
                    }
                }
                l.state = sum(&l.to);
            }
            if changed {
                self.save_group_chat(&g.id, lines)?;
            }
        }
        Ok(())
    }

    /// A message marked for a group, opened. Changes the group when it is
    /// the admin's roster, keeps the line when it is a member's message.
    /// Returns what to tell the user, if anything.
    pub(super) fn take_group(
        &mut self,
        m: &mut Messaging,
        r: Received,
        wire: GroupWire,
        files: &mut Files,
        confirm: &mut HashMap<String, Vec<Vec<u8>>>,
        rosters: &mut Vec<String>,
    ) -> Result<Option<Incoming>, EngineError> {
        let me = m.my_address().to_owned();
        let state = m
            .contacts()
            .into_iter()
            .find(|c| c.id == r.contact)
            .map(|c| c.state);
        let mut all = self.groups_all()?;
        let gid = hex(&wire.id);
        let mut told = None;
        if wire.id.len() == 16
            && let Some(roster) = wire.roster.filter(|ro| ro.sound())
        {
            match all.list.get(&gid).cloned() {
                None if state == Some(ContactState::Accepted)
                    && !roster.ended
                    && roster.members.iter().any(|x| x.address == me)
                    && roster.members.iter().any(|x| x.address == r.contact) =>
                {
                    all.list.insert(
                        gid.clone(),
                        Group {
                            id: gid.clone(),
                            admin: r.contact.clone(),
                            roster,
                            gone: false,
                            added: (self.now)(),
                        },
                    );
                    self.save_groups(&all)?;
                    self.notice(&gid, notice::JOINED, &r.contact, Vec::new(), "")?;
                    told = Some(Incoming {
                        contact: r.contact.clone(),
                        new_contact: false,
                        text: String::new(),
                        group: gid.clone(),
                    });
                }
                Some(old)
                    if old.admin == r.contact && !old.gone && roster.stamp > old.roster.stamp =>
                {
                    let had: Vec<&str> = old
                        .roster
                        .members
                        .iter()
                        .map(|x| x.address.as_str())
                        .collect();
                    let has: Vec<&str> =
                        roster.members.iter().map(|x| x.address.as_str()).collect();
                    let added: Vec<String> = has
                        .iter()
                        .filter(|a| !had.contains(a))
                        .map(|a| (*a).to_owned())
                        .collect();
                    let removed: Vec<String> = had
                        .iter()
                        .filter(|a| !has.contains(a) && **a != me)
                        .map(|a| (*a).to_owned())
                        .collect();
                    let out = !has.contains(&me.as_str());
                    let mut g = old.clone();
                    g.roster = roster;
                    g.gone = out;
                    all.list.insert(gid.clone(), g.clone());
                    self.save_groups(&all)?;
                    if g.roster.name != old.roster.name {
                        self.notice(
                            &gid,
                            notice::RENAMED,
                            &r.contact,
                            Vec::new(),
                            &g.roster.name,
                        )?;
                    }
                    if !added.is_empty() {
                        self.notice(&gid, notice::ADDED, &r.contact, added, "")?;
                    }
                    if !removed.is_empty() {
                        self.notice(&gid, notice::REMOVED, &r.contact, removed, "")?;
                    }
                    if out {
                        self.notice(&gid, notice::REMOVED_YOU, &r.contact, Vec::new(), "")?;
                    } else if g.roster.ended && !old.roster.ended {
                        self.notice(&gid, notice::ENDED, &r.contact, Vec::new(), "")?;
                    }
                }
                _ => {}
            }
        }

        let Some(g) = all.list.get(&gid).cloned() else {
            // nothing to do with any group here: someone this opened for
            // the first time is not kept either
            if r.new_contact {
                m.remove(&r.contact).map_err(messaging_err)?;
                self.save_messaging(m)?;
            }
            return Ok(told);
        };
        let member = g.has(&r.contact);
        if r.new_contact {
            if member {
                // a member who did not know us: one of the group, not a request
                m.set_state(&r.contact, ContactState::Member)
                    .map_err(messaging_err)?;
            } else {
                m.remove(&r.contact).map_err(messaging_err)?;
            }
            self.save_messaging(m)?;
        }
        if !member || g.gone {
            return Ok(told);
        }

        if wire.leave && r.contact != g.admin {
            let mut g = g.clone();
            g.roster.members.retain(|x| x.address != r.contact);
            self.notice(&gid, notice::LEFT, &r.contact, Vec::new(), "")?;
            if g.admin == me {
                g.roster.stamp = self.next_stamp(&g);
                if g.roster.members.len() < 2 {
                    g.roster.ended = true;
                }
                all.list.insert(gid.clone(), g);
                self.save_groups(&all)?;
                // sent once the loop that opens messages is done with the
                // Signal state
                rosters.push(gid.clone());
            } else {
                all.list.insert(gid.clone(), g);
                self.save_groups(&all)?;
            }
            return Ok(told);
        }

        if (r.text.is_empty() && r.file.is_none()) || g.roster.ended || r.id.len() != 16 {
            return Ok(told);
        }
        // every member answers with a receipt, whoever the sender is to us
        confirm
            .entry(r.contact.clone())
            .or_default()
            .push(r.id.clone());
        let mut lines = self.load_group_chat(&gid)?;
        if lines
            .iter()
            .any(|l| !l.outgoing && l.from == r.contact && *l.id == *r.id)
        {
            return Ok(told);
        }
        let file = match &r.file {
            Some(f) if f.chunks > 0 && f.chunks as usize <= MAX_FILE.div_ceil(CHUNK) + 1 => {
                if files.pending.len() < MAX_PENDING_FILES {
                    files.pending.insert(
                        f.tag.clone(),
                        Pending {
                            contact: r.contact.clone(),
                            line: ByteBuf::from(r.id.clone()),
                            file: f.clone(),
                            got: BTreeMap::new(),
                            group: gid.clone(),
                        },
                    );
                }
                Some(LineFile {
                    name: f.name.clone(),
                    mime: f.mime.clone(),
                    size: f.size,
                    blob: String::new(),
                })
            }
            _ => None,
        };
        lines.push(Line {
            text: r.text.clone(),
            at: (self.now)(),
            sent: r.sent,
            state: LineState::Delivered,
            id: ByteBuf::from(r.id.clone()),
            file,
            from: r.contact.clone(),
            ..Line::default()
        });
        self.save_group_chat(&gid, lines)?;
        Ok(Some(Incoming {
            contact: r.contact,
            new_contact: false,
            text: r.text,
            group: gid,
        }))
    }

    /// Where a pending file's line lives: a group's conversation or a
    /// contact's.
    pub(super) fn file_lines(&self, p: &Pending) -> Result<Vec<Line>, EngineError> {
        if p.group.is_empty() {
            self.load_chat(&p.contact)
        } else {
            self.load_group_chat(&p.group)
        }
    }

    pub(super) fn save_file_lines(&self, p: &Pending, lines: Vec<Line>) -> Result<(), EngineError> {
        if p.group.is_empty() {
            self.save_chat(&p.contact, lines)
        } else {
            self.save_group_chat(&p.group, lines)
        }
    }
}

fn unhex(s: &str) -> Result<Vec<u8>, EngineError> {
    (0..s.len())
        .step_by(2)
        .map(|i| s.get(i..i + 2).and_then(|h| u8::from_str_radix(h, 16).ok()))
        .collect::<Option<Vec<u8>>>()
        .ok_or(EngineError::NotFound)
}
