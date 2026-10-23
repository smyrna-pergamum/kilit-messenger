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
