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
  String get chatEmpty =>
      'No messages yet. The first one you write starts the encrypted session.';

  @override
  String get chatInput => 'Message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatNewContact =>
      'Wrote to you without being added. Accept to reply, or block them. Compare safety numbers before you trust them.';

  @override
  String get safetyTitle => 'Safety number';

  @override
  String safetyHint(String name) {
    return 'Compare these 60 digits with $name, in person or on a call. If they are the same on both phones, no one is in between.';
  }

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachFile => 'Photo or file';

  @override
  String get chatFileTooLarge => 'Too large to send: 5 MB at most.';

  @override
  String get chatDelivered => 'Delivered';

  @override
  String get fileComing => 'Receiving…';

  @override
  String get fileToVault => 'Add to vault';

  @override
  String get fileSavedVault => 'Added to the vault.';

  @override
  String get timerTitle => 'Disappearing messages';

  @override
  String get timerHint =>
      'New messages in this chat disappear after this time, on both phones.';

  @override
  String get timerOff => 'Off';

  @override
  String get timer5m => '5 minutes';

  @override
  String get timer1h => '1 hour';

  @override
  String get timer1d => '1 day';

  @override
  String get timer1w => '1 week';

  @override
  String get renewTitle => 'Renew my Kilit ID';

  @override
  String get renewBody =>
      'You get new words, a new link and a new QR code. Your contacts keep talking to you as before; the old ID and link stop working for anyone new.';

  @override
  String get renewGo => 'Renew';

  @override
  String renewDone(String id) {
    return 'Your new ID: @$id';
  }

  @override
  String get cameraNoCamera =>
      'The camera could not be opened. Check the camera permission in the phone\'s settings.';

  @override
  String get cameraShutter => 'Take a photo';

  @override
  String get cameraRetake => 'Retake';

  @override
  String get cameraUse => 'Use';

  @override
  String get cameraIntro =>
      'Photos are taken in memory only: nothing is written to the phone, and they carry no location or camera data.';

  @override
  String get cameraSendTo => 'Send to…';

  @override
  String get cameraToVault => 'Keep in the vault';

  @override
  String get cameraSavedVault => 'Photo kept in the vault.';

  @override
  String get cameraNoContacts => 'No contacts to send to yet.';

  @override
  String cameraSent(String name) {
    return 'Sent to $name.';
  }

  @override
  String get chatsYourKilit => 'Your Kilit';

  @override
  String get chatsSearch => 'Search';

  @override
  String get chatsEmptyNew =>
      'No one here yet. Add someone, or show them your code.';

  @override
  String get torChipReady => 'Tor ready';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor off';

  @override
  String get addTitle => 'Add someone';

  @override
  String get addHint =>
      'Scan their code, or paste what they gave you: a link or an @ID.';

  @override
  String get addScan => 'Scan their code';

  @override
  String get addField => 'A Kilit link or @ID';

  @override
  String get addGo => 'Add';

  @override
  String get addSearching => 'Looking them up over Tor…';

  @override
  String get addNotFound =>
      'No one found for this ID. Check it, or try again in a moment.';

  @override
  String get addOffline =>
      'Not connected to Tor yet. Wait until it says Tor ready.';

  @override
  String get addNotInvite => 'That is not a Kilit link or @ID.';

  @override
  String get addShowMine => 'Show my code';

  @override
  String get addShowMineHint => 'Your QR code, your link, your @ID';

  @override
  String get myTitle => 'My code';

  @override
  String get myHint =>
      'Anyone with this code, your link or your @ID can write to you. Their first message waits in Requests until you accept.';

  @override
  String get myCopyLink => 'Copy link';

  @override
  String myShareText(String id, String link) {
    return 'Add me on Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'Scan a Kilit code';

  @override
  String get scanHint => 'Point the camera at the QR code.';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get requestsEmpty => 'No requests.';

  @override
  String get requestHint =>
      'They wrote to you without being added. Nothing reaches them until you accept and write back.';

  @override
  String get requestAccept => 'Accept';

  @override
  String get requestDecline => 'Decline';

  @override
  String get requestBlock => 'Block';

  @override
  String get chatOnRelay => 'On the relays';

  @override
  String get chatQueued => 'Waiting for the network';

  @override
  String get contactRename => 'Rename';

  @override
  String get contactRemove => 'Delete contact';

  @override
  String get contactRemoveTitle => 'Delete this contact?';

  @override
  String get contactRemoveBody =>
      'The session and the whole conversation are deleted. To write again, add each other again.';

  @override
  String get contactRemoveGo => 'Delete';

  @override
  String get save => 'Save';

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
  String get torOff => 'Off: Kilit does not go online.';

  @override
  String torStarting(int progress) {
    return 'Connecting… $progress%';
  }

  @override
  String get torReady => 'Connected through Tor.';

  @override
  String get torFailed => 'Could not connect to Tor.';

  @override
  String get torUnavailable => 'Not available on this device yet.';

  @override
  String get torSwitch => 'Connect over Tor';

  @override
  String get torSwitchHint =>
      'Kilit reaches the network only through Tor. Off, it stays offline.';

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

  @override
  String get settingsBridges => 'Tor connection';

  @override
  String get torRouteAuto => 'Automatic';

  @override
  String get torRouteAutoHint =>
      'Straight to Tor; through bridges when that is blocked.';

  @override
  String get torRouteDirect => 'Straight to Tor';

  @override
  String get torRouteObfs4 => 'obfs4 bridges';

  @override
  String get torRouteObfs4Hint => 'For networks that block Tor.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'For heavy censorship. Slower.';

  @override
  String get torRouteCustom => 'My own bridges';

  @override
  String get torRouteCustomHint =>
      'Bridge lines from bridges.torproject.org or someone you trust.';

  @override
  String get torRouteLinesHint => 'One bridge line per row';

  @override
  String get resend => 'Send again';

  @override
  String get resendHint =>
      'A relay has this message, but their phone has not said it arrived. Kilit sends it again once a day for a week, until it does.';

  @override
  String get resendDone => 'Sent again.';
}
