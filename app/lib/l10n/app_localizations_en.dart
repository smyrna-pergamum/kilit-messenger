// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get share => 'Share';

  @override
  String get lockNow => 'Lock now';

  @override
  String get panicTooltip => 'Tap to lock, hold for the panic code';

  @override
  String get panicNoCode => 'Set a panic code in Settings first.';

  @override
  String get panicEnterTitle => 'Panic code';

  @override
  String get panicEnterHint =>
      'Enter the panic code to erase everything in Kilit.';

  @override
  String get panicWrong => 'That is not the panic code.';

  @override
  String get settingsPanic => 'Panic code';

  @override
  String get panicExplain =>
      'Four digits. Entered on the lock screen instead of your PIN, or after holding the lock button, it erases every key, message and file in Kilit for good, and Kilit starts over as if it had just been installed.';

  @override
  String get panicStatusOn => 'Set';

  @override
  String get panicStatusOff => 'Not set';

  @override
  String get panicSet => 'Set panic code';

  @override
  String get panicChange => 'Change panic code';

  @override
  String get panicRemove => 'Remove panic code';

  @override
  String get panicCreateTitle => 'Choose a panic code';

  @override
  String get panicCreateHint =>
      'Four digits. Anyone who sees this code entered can erase Kilit.';

  @override
  String get panicConfirmTitle => 'Repeat the panic code';

  @override
  String get panicMismatch => 'The codes did not match. Start again.';

  @override
  String get panicSaved => 'Panic code set.';

  @override
  String get panicRemoved => 'Panic code removed.';

  @override
  String get panicRejected => 'This code cannot be used. Choose another.';

  @override
  String get keptInVault => 'Saved in the vault.';

  @override
  String get alreadyInVault => 'Already in the vault.';

  @override
  String get keptTitleFallback => 'Message';

  @override
  String get devBanner => 'Development core: no real encryption.';

  @override
  String get lockTitleUnlock => 'Unlock';

  @override
  String get lockTitleCreate => 'Choose a PIN';

  @override
  String get lockTitleConfirm => 'Enter the PIN again';

  @override
  String get lockHintUnlock => 'Enter your PIN to open your vault.';

  @override
  String lockHintCreate(int min) {
    return 'At least $min digits. If you forget it your vault cannot be opened: there is no recovery.';
  }

  @override
  String get lockHintConfirm => 'Enter the same PIN once more.';

  @override
  String get lockMismatch => 'The PINs did not match. Start again.';

  @override
  String get lockWrongPin => 'Wrong PIN.';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get changePinCurrent => 'Enter your current PIN';

  @override
  String get changePinNew => 'Choose a new PIN';

  @override
  String get changePinDone => 'PIN changed.';

  @override
  String lockWait(int seconds) {
    return 'Wait $seconds s before trying again.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count digits entered';
  }

  @override
  String get pinDelete => 'Delete';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Chats';

  @override
  String get navVault => 'Vault';

  @override
  String get navCamera => 'Camera';

  @override
  String get navSettings => 'Settings';

  @override
  String get chatsLater => 'Messaging over Tor arrives in stage 2.';

  @override
  String get chatsIntro =>
      'Messages are end-to-end encrypted with Signal\'s protocol (PQXDH and SPQR, post-quantum). Until Kilit\'s own network arrives, they travel as text you copy into any chat app.';

  @override
  String get chatsEmpty =>
      'No contacts yet. Give your card to someone, or add theirs.';

  @override
  String get chatsShareCard => 'My card';

  @override
  String get chatsAddContact => 'Add contact';

  @override
  String get chatsOpenClipboard => 'Open from clipboard';

  @override
  String get chatsNothingOnClipboard =>
      'No Kilit message or contact card on the clipboard.';

  @override
  String get cardTitle => 'Your contact card';

  @override
  String get cardName => 'Name to show (optional)';

  @override
  String get cardShow => 'Make card';

  @override
  String get cardHint =>
      'Send this text to the person you want to talk to. It holds no secret. Once you are connected, compare safety numbers.';

  @override
  String get addContactTitle => 'Add a contact';

  @override
  String get addContactCard => 'Their contact card (KLC1:…)';

  @override
  String get addContactName => 'Name (optional)';

  @override
  String get addContactGo => 'Add';

  @override
  String get addContactRefused =>
      'This is not a contact card, or it is your own.';

  @override
  String get contactUnnamed => 'Unnamed contact';

  @override
  String get chatEmpty =>
      'No messages yet. The first one you write starts the encrypted session.';

  @override
  String get chatInput => 'Message';

  @override
  String get chatSend => 'Encrypt';

  @override
  String get chatPaste => 'Open a reply from the clipboard';

  @override
  String get chatSealedTitle => 'Encrypted message';

  @override
  String chatSealedHint(String name) {
    return 'Copy this into your chat app and send it to $name. Only they can open it.';
  }

  @override
  String get chatNewContact =>
      'Someone who has your card wrote to you. Give them a name, and compare safety numbers before you trust them.';

  @override
  String get chatOtherContact =>
      'A message from another contact was opened too; it is in their conversation.';

  @override
  String get chatDuplicate => 'This message was opened before.';

  @override
  String get chatUnknown =>
      'This message is from no one you have a session with.';

  @override
  String get chatDamaged => 'The message is damaged.';

  @override
  String get safetyTitle => 'Safety number';

  @override
  String safetyHint(String name) {
    return 'Compare these 60 digits with $name, in person or on a call. If they are the same on both phones, no one is in between.';
  }

  @override
  String get contactRename => 'Rename';

  @override
  String get contactRemove => 'Delete contact';

  @override
  String get contactRemoveTitle => 'Delete this contact?';

  @override
  String get contactRemoveBody =>
      'The session and the whole conversation are deleted. To write again you need each other\'s cards.';

  @override
  String get contactRemoveGo => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cameraLater =>
      'A camera that never writes plaintext to disk arrives in stage 2.';

  @override
  String get vaultAddNote => 'Add note';

  @override
  String get vaultCompose => 'Carrier message';

  @override
  String get vaultOpenClipboard => 'Open from clipboard';

  @override
  String get vaultOpenPasted => 'Open pasted text';

  @override
  String get vaultSealFile => 'Encrypt a file';

  @override
  String get vaultOpenKlt => 'Open .klt';

  @override
  String get vaultEmpty =>
      'Your vault is empty. Add a note or encrypt a file; everything is kept as a .klt packet.';

  @override
  String get vaultSigned => 'Signed';

  @override
  String get vaultFileTooLarge => 'The file is too large: 64 MB at most.';

  @override
  String vaultFileSealed(String name) {
    return '$name was encrypted and added to the vault.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name was encrypted and added to the vault. Hidden data removed: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name was encrypted and added to the vault. Kilit can\'t remove hidden data (such as the author) from this file type; check it before you share it.';
  }

  @override
  String get damagedPictureTitle => 'Damaged picture';

  @override
  String get damagedPictureBody =>
      'This picture is damaged, so Kilit couldn\'t remove its hidden data, such as where it was taken. Add it as it is?';

  @override
  String get damagedPictureSeal => 'Add as it is';

  @override
  String get hiddenLocation => 'location';

  @override
  String get hiddenCamera => 'camera details';

  @override
  String get hiddenAuthorNotes => 'author and notes';

  @override
  String get hiddenExtraImages => 'extra pictures';

  @override
  String get hiddenOther => 'other metadata';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'No Kilit message on the clipboard. In WhatsApp, long-press the message and tap Copy.';

  @override
  String get clipboardBanner => 'There is a Kilit message on the clipboard.';

  @override
  String get clipboardBannerOpen => 'Open';

  @override
  String get clipboardBannerDismiss => 'Ignore';

  @override
  String get noteNew => 'New note';

  @override
  String get noteTitle => 'Title';

  @override
  String get noteText => 'Note';

  @override
  String get sealAndSave => 'Encrypt and save';

  @override
  String get carrierTitle => 'Carrier message';

  @override
  String get carrierIntro =>
      'The message is encrypted and turned into text to paste into an app such as WhatsApp.';

  @override
  String get carrierMessage => 'Message';

  @override
  String get withPassphrase => 'With a shared passphrase';

  @override
  String get carrierWithPassphraseHint =>
      'The other side opens it with the same passphrase. Off: only you can open it.';

  @override
  String get passphrase => 'Shared passphrase';

  @override
  String get carrierPassphraseHelper =>
      'At least 12 characters. Do not send it through the same channel as the message.';

  @override
  String get carrierSeal => 'Encrypt';

  @override
  String get carrierResultIntro =>
      'Copy and send this text. The channel only sees encrypted data.';

  @override
  String carrierChars(int count) {
    return '$count characters';
  }

  @override
  String get pasteTitle => 'Open pasted text';

  @override
  String get pasteInput => 'Text you copied from a chat';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get passphraseIfAny => 'Shared passphrase (if any)';

  @override
  String get pasteOpen => 'Find and open';

  @override
  String get pasteNone => 'No KLT1 packet found in the text.';

  @override
  String get pasteTruncated =>
      'A packet was cut off: the sending app may have shortened the message.';

  @override
  String get pasteMalformed => 'A packet is damaged.';

  @override
  String get openWrongKey =>
      'This packet does not open with this passphrase or key.';

  @override
  String get openDamaged => 'This packet is damaged or was changed.';

  @override
  String get openIsFile =>
      'This packet holds a file; add it to the vault with Open .klt.';

  @override
  String get packetTitle => 'Packet analysis';

  @override
  String get packetFile => 'File';

  @override
  String get packetType => 'Type';

  @override
  String get packetSize => 'Size';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (packet $packet)';
  }

  @override
  String get packetFormat => 'Format';

  @override
  String get packetFormatValue => 'KLT1 (built on age v1)';

  @override
  String get packetRecipients => 'Recipients';

  @override
  String get packetContent => 'Content';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, 64 KiB chunks';

  @override
  String get packetSignature => 'Signature';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, verified';

  @override
  String get sigUnsigned => 'Unsigned';

  @override
  String get sigInvalid => 'INVALID';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (shared passphrase)';

  @override
  String get itemOpen => 'Open';

  @override
  String get itemView => 'View';

  @override
  String get itemExport => 'Export as .klt';

  @override
  String get itemSavePlain => 'Save unencrypted';

  @override
  String get savePlainTitle => 'Save unencrypted?';

  @override
  String get savePlainBody =>
      'The file is saved decrypted. Anyone with access to where you save it can read it; Kilit can no longer protect it.';

  @override
  String get itemDelete => 'Delete from vault';

  @override
  String get exportTitle => 'Export as .klt';

  @override
  String get exportIntro =>
      'The file is encrypted again and signed by your vault. The file name is random; the real name stays inside the encrypted packet.';

  @override
  String get exportWithPassphraseHint =>
      'Anyone with the passphrase can open it. Off: only your vault opens it (for backups).';

  @override
  String get exportPassphraseHelper =>
      'At least 12 characters. Do not send it through the same channel as the file.';

  @override
  String get passphraseTooShort =>
      'The shared passphrase must be at least 12 characters.';

  @override
  String get importTitle => 'Open a .klt file';

  @override
  String get importPassphraseHelper =>
      'Leave empty if it was sent to your own vault.';

  @override
  String get importGo => 'Open and add to vault';

  @override
  String importAddedSigned(String name) {
    return '$name was added to the vault (signed).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name was added to the vault (unsigned).';
  }

  @override
  String get importWrongKey =>
      'This file does not open with this passphrase or your vault.';

  @override
  String get importNotKlt => 'This is not a .klt file.';

  @override
  String get importDamaged => 'The file is damaged or was changed.';

  @override
  String get settingsProtections => 'Your protections';

  @override
  String get protPin => 'PIN protection';

  @override
  String get protScreenshots => 'Screenshot blocking';

  @override
  String get protScreenshotsValue => 'On, on every screen';

  @override
  String get protAutoLock => 'Auto-lock';

  @override
  String get protAutoLockValue => 'When you leave the app';

  @override
  String get protNetwork => 'Tor connection';

  @override
  String get protNetworkValue =>
      'Not connected: stage 1 never goes online. Tor arrives in stage 2.';

  @override
  String get hwStrongbox => 'StrongBox security chip';

  @override
  String get hwTee => 'Trusted execution environment (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (no secure hardware)';

  @override
  String get hwSoftwareFile => 'Software key (next to the vault)';

  @override
  String get hwNone => 'None';

  @override
  String get hwDev => 'None (development core)';

  @override
  String get hwBoundHint =>
      'Your PIN is bound to this device\'s hardware key. Even a copy of the vault file cannot be tried on another device.';

  @override
  String get hwNotBoundHint =>
      'No hardware key: if the vault file is copied, the PIN can be guessed on another device.';

  @override
  String get settingsFingerprint => 'Your safety number';

  @override
  String get settingsFingerprintHint =>
      'When verifying a contact it must be the same on both devices.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get clipboardCheck => 'Offer the Kilit message on the clipboard';

  @override
  String get clipboardCheckHint =>
      'When the vault opens, offers to open a KLT1: message on the clipboard. Android shows a notice that the clipboard was read.';

  @override
  String get settingsPermissions => 'Permissions';

  @override
  String get permIntro => 'Kilit uses no sensitive permission right now.';

  @override
  String get permCamera => 'Camera';

  @override
  String get permCameraValue => 'Not used (camera arrives in stage 2)';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permNotificationsValue => 'Not used';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'None: stage 1 works offline';

  @override
  String get permOpenSystem => 'Open system permission settings';

  @override
  String get settingsAbout => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicense => 'License';

  @override
  String get aboutAlpha =>
      'Not independently audited. Alpha: good for testing, not for high-stakes use.';
}
