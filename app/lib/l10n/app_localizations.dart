import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kilit'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @devBanner.
  ///
  /// In en, this message translates to:
  /// **'Development core: no real encryption.'**
  String get devBanner;

  /// No description provided for @lockTitleUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockTitleUnlock;

  /// No description provided for @lockTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN'**
  String get lockTitleCreate;

  /// No description provided for @lockTitleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get lockTitleConfirm;

  /// No description provided for @lockHintUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to open your vault.'**
  String get lockHintUnlock;

  /// No description provided for @lockHintCreate.
  ///
  /// In en, this message translates to:
  /// **'At least {min} digits. If you forget it your vault cannot be opened: there is no recovery.'**
  String lockHintCreate(int min);

  /// No description provided for @lockHintConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN once more.'**
  String get lockHintConfirm;

  /// No description provided for @lockMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs did not match. Start again.'**
  String get lockMismatch;

  /// No description provided for @lockWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get lockWrongPin;

  /// No description provided for @lockWait.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds} s before trying again.'**
  String lockWait(int seconds);

  /// No description provided for @pinDigitsEntered.
  ///
  /// In en, this message translates to:
  /// **'{count} digits entered'**
  String pinDigitsEntered(int count);

  /// No description provided for @pinDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pinDelete;

  /// No description provided for @pinOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get pinOk;

  /// No description provided for @navChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get navVault;

  /// No description provided for @navCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get navCamera;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @chatsLater.
  ///
  /// In en, this message translates to:
  /// **'Messaging over Tor arrives in stage 2.'**
  String get chatsLater;

  /// No description provided for @cameraLater.
  ///
  /// In en, this message translates to:
  /// **'A camera that never writes plaintext to disk arrives in stage 2.'**
  String get cameraLater;

  /// No description provided for @vaultAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get vaultAddNote;

  /// No description provided for @vaultCompose.
  ///
  /// In en, this message translates to:
  /// **'Carrier message'**
  String get vaultCompose;

  /// No description provided for @vaultOpenClipboard.
  ///
  /// In en, this message translates to:
  /// **'Open from clipboard'**
  String get vaultOpenClipboard;

  /// No description provided for @vaultOpenPasted.
  ///
  /// In en, this message translates to:
  /// **'Open pasted text'**
  String get vaultOpenPasted;

  /// No description provided for @vaultSealFile.
  ///
  /// In en, this message translates to:
  /// **'Encrypt a file'**
  String get vaultSealFile;

  /// No description provided for @vaultOpenKlt.
  ///
  /// In en, this message translates to:
  /// **'Open .klt'**
  String get vaultOpenKlt;

  /// No description provided for @vaultEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your vault is empty. Add a note or encrypt a file; everything is kept as a .klt packet.'**
  String get vaultEmpty;

  /// No description provided for @vaultSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get vaultSigned;

  /// No description provided for @vaultFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is too large: 64 MB at most.'**
  String get vaultFileTooLarge;

  /// No description provided for @vaultFileSealed.
  ///
  /// In en, this message translates to:
  /// **'{name} was encrypted and added to the vault.'**
  String vaultFileSealed(String name);

  /// No description provided for @vaultFileCleaned.
  ///
  /// In en, this message translates to:
  /// **'{name} was encrypted and added to the vault. Hidden data removed: {removed}.'**
  String vaultFileCleaned(String name, String removed);

  /// No description provided for @vaultFileUnchecked.
  ///
  /// In en, this message translates to:
  /// **'{name} was encrypted and added to the vault. Kilit can\'t remove hidden data (such as the author) from this file type; check it before you share it.'**
  String vaultFileUnchecked(String name);

  /// No description provided for @damagedPictureTitle.
  ///
  /// In en, this message translates to:
  /// **'Damaged picture'**
  String get damagedPictureTitle;

  /// No description provided for @damagedPictureBody.
  ///
  /// In en, this message translates to:
  /// **'This picture is damaged, so Kilit couldn\'t remove its hidden data, such as where it was taken. Add it as it is?'**
  String get damagedPictureBody;

  /// No description provided for @damagedPictureSeal.
  ///
  /// In en, this message translates to:
  /// **'Add as it is'**
  String get damagedPictureSeal;

  /// No description provided for @hiddenLocation.
  ///
  /// In en, this message translates to:
  /// **'location'**
  String get hiddenLocation;

  /// No description provided for @hiddenCamera.
  ///
  /// In en, this message translates to:
  /// **'camera details'**
  String get hiddenCamera;

  /// No description provided for @hiddenAuthorNotes.
  ///
  /// In en, this message translates to:
  /// **'author and notes'**
  String get hiddenAuthorNotes;

  /// No description provided for @hiddenExtraImages.
  ///
  /// In en, this message translates to:
  /// **'extra pictures'**
  String get hiddenExtraImages;

  /// No description provided for @hiddenOther.
  ///
  /// In en, this message translates to:
  /// **'other metadata'**
  String get hiddenOther;

  /// Between the kinds of hidden data in vaultFileCleaned, with any space it needs.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get hiddenListSeparator;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Kilit message on the clipboard. In WhatsApp, long-press the message and tap Copy.'**
  String get clipboardEmpty;

  /// No description provided for @clipboardBanner.
  ///
  /// In en, this message translates to:
  /// **'There is a Kilit message on the clipboard.'**
  String get clipboardBanner;

  /// No description provided for @clipboardBannerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get clipboardBannerOpen;

  /// No description provided for @clipboardBannerDismiss.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get clipboardBannerDismiss;

  /// No description provided for @noteNew.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get noteNew;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitle;

  /// No description provided for @noteText.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteText;

  /// No description provided for @sealAndSave.
  ///
  /// In en, this message translates to:
  /// **'Encrypt and save'**
  String get sealAndSave;

  /// No description provided for @carrierTitle.
  ///
  /// In en, this message translates to:
  /// **'Carrier message'**
  String get carrierTitle;

  /// No description provided for @carrierIntro.
  ///
  /// In en, this message translates to:
  /// **'The message is encrypted and turned into text to paste into an app such as WhatsApp.'**
  String get carrierIntro;

  /// No description provided for @carrierMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get carrierMessage;

  /// No description provided for @withPassphrase.
  ///
  /// In en, this message translates to:
  /// **'With a shared passphrase'**
  String get withPassphrase;

  /// No description provided for @carrierWithPassphraseHint.
  ///
  /// In en, this message translates to:
  /// **'The other side opens it with the same passphrase. Off: only you can open it.'**
  String get carrierWithPassphraseHint;

  /// No description provided for @passphrase.
  ///
  /// In en, this message translates to:
  /// **'Shared passphrase'**
  String get passphrase;

  /// No description provided for @carrierPassphraseHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. Do not send it through the same channel as the message.'**
  String get carrierPassphraseHelper;

  /// No description provided for @carrierSeal.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get carrierSeal;

  /// No description provided for @carrierResultIntro.
  ///
  /// In en, this message translates to:
  /// **'Copy and send this text. The channel only sees encrypted data.'**
  String get carrierResultIntro;

  /// No description provided for @carrierChars.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String carrierChars(int count);

  /// No description provided for @pasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Open pasted text'**
  String get pasteTitle;

  /// No description provided for @pasteInput.
  ///
  /// In en, this message translates to:
  /// **'Text you copied from a chat'**
  String get pasteInput;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @passphraseIfAny.
  ///
  /// In en, this message translates to:
  /// **'Shared passphrase (if any)'**
  String get passphraseIfAny;

  /// No description provided for @pasteOpen.
  ///
  /// In en, this message translates to:
  /// **'Find and open'**
  String get pasteOpen;

  /// No description provided for @pasteNone.
  ///
  /// In en, this message translates to:
  /// **'No KLT1 packet found in the text.'**
  String get pasteNone;

  /// No description provided for @pasteTruncated.
  ///
  /// In en, this message translates to:
  /// **'A packet was cut off: the sending app may have shortened the message.'**
  String get pasteTruncated;

  /// No description provided for @pasteMalformed.
  ///
  /// In en, this message translates to:
  /// **'A packet is damaged.'**
  String get pasteMalformed;

  /// No description provided for @openWrongKey.
  ///
  /// In en, this message translates to:
  /// **'This packet does not open with this passphrase or key.'**
  String get openWrongKey;

  /// No description provided for @openDamaged.
  ///
  /// In en, this message translates to:
  /// **'This packet is damaged or was changed.'**
  String get openDamaged;

  /// No description provided for @openIsFile.
  ///
  /// In en, this message translates to:
  /// **'This packet holds a file; add it to the vault with Open .klt.'**
  String get openIsFile;

  /// No description provided for @packetTitle.
  ///
  /// In en, this message translates to:
  /// **'Packet analysis'**
  String get packetTitle;

  /// No description provided for @packetFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get packetFile;

  /// No description provided for @packetType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get packetType;

  /// No description provided for @packetSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get packetSize;

  /// No description provided for @packetSizeValue.
  ///
  /// In en, this message translates to:
  /// **'{content} (packet {packet})'**
  String packetSizeValue(String content, String packet);

  /// No description provided for @packetFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get packetFormat;

  /// No description provided for @packetFormatValue.
  ///
  /// In en, this message translates to:
  /// **'KLT1 (built on age v1)'**
  String get packetFormatValue;

  /// No description provided for @packetRecipients.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get packetRecipients;

  /// No description provided for @packetContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get packetContent;

  /// No description provided for @packetContentValue.
  ///
  /// In en, this message translates to:
  /// **'ChaCha20-Poly1305, 64 KiB chunks'**
  String get packetContentValue;

  /// No description provided for @packetSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get packetSignature;

  /// No description provided for @sigVerified.
  ///
  /// In en, this message translates to:
  /// **'Ed25519 + ML-DSA-65, verified'**
  String get sigVerified;

  /// No description provided for @sigUnsigned.
  ///
  /// In en, this message translates to:
  /// **'Unsigned'**
  String get sigUnsigned;

  /// No description provided for @sigInvalid.
  ///
  /// In en, this message translates to:
  /// **'INVALID'**
  String get sigInvalid;

  /// No description provided for @recipientXwing.
  ///
  /// In en, this message translates to:
  /// **'klt-xwing (ML-KEM-768 + X25519)'**
  String get recipientXwing;

  /// No description provided for @recipientPassphrase.
  ///
  /// In en, this message translates to:
  /// **'klt-argon2id (shared passphrase)'**
  String get recipientPassphrase;

  /// No description provided for @itemOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get itemOpen;

  /// No description provided for @itemView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get itemView;

  /// No description provided for @itemExport.
  ///
  /// In en, this message translates to:
  /// **'Export as .klt'**
  String get itemExport;

  /// No description provided for @itemSavePlain.
  ///
  /// In en, this message translates to:
  /// **'Save unencrypted'**
  String get itemSavePlain;

  /// No description provided for @savePlainTitle.
  ///
  /// In en, this message translates to:
  /// **'Save unencrypted?'**
  String get savePlainTitle;

  /// No description provided for @savePlainBody.
  ///
  /// In en, this message translates to:
  /// **'The file is saved decrypted. Anyone with access to where you save it can read it; Kilit can no longer protect it.'**
  String get savePlainBody;

  /// No description provided for @itemDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete from vault'**
  String get itemDelete;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export as .klt'**
  String get exportTitle;

  /// No description provided for @exportIntro.
  ///
  /// In en, this message translates to:
  /// **'The file is encrypted again and signed by your vault. The file name is random; the real name stays inside the encrypted packet.'**
  String get exportIntro;

  /// No description provided for @exportWithPassphraseHint.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the passphrase can open it. Off: only your vault opens it (for backups).'**
  String get exportWithPassphraseHint;

  /// No description provided for @exportPassphraseHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. Do not send it through the same channel as the file.'**
  String get exportPassphraseHelper;

  /// No description provided for @passphraseTooShort.
  ///
  /// In en, this message translates to:
  /// **'The shared passphrase must be at least 12 characters.'**
  String get passphraseTooShort;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a .klt file'**
  String get importTitle;

  /// No description provided for @importPassphraseHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if it was sent to your own vault.'**
  String get importPassphraseHelper;

  /// No description provided for @importGo.
  ///
  /// In en, this message translates to:
  /// **'Open and add to vault'**
  String get importGo;

  /// No description provided for @importAddedSigned.
  ///
  /// In en, this message translates to:
  /// **'{name} was added to the vault (signed).'**
  String importAddedSigned(String name);

  /// No description provided for @importAddedUnsigned.
  ///
  /// In en, this message translates to:
  /// **'{name} was added to the vault (unsigned).'**
  String importAddedUnsigned(String name);

  /// No description provided for @importWrongKey.
  ///
  /// In en, this message translates to:
  /// **'This file does not open with this passphrase or your vault.'**
  String get importWrongKey;

  /// No description provided for @importNotKlt.
  ///
  /// In en, this message translates to:
  /// **'This is not a .klt file.'**
  String get importNotKlt;

  /// No description provided for @importDamaged.
  ///
  /// In en, this message translates to:
  /// **'The file is damaged or was changed.'**
  String get importDamaged;

  /// No description provided for @settingsProtections.
  ///
  /// In en, this message translates to:
  /// **'Your protections'**
  String get settingsProtections;

  /// No description provided for @protPin.
  ///
  /// In en, this message translates to:
  /// **'PIN protection'**
  String get protPin;

  /// No description provided for @protScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshot blocking'**
  String get protScreenshots;

  /// No description provided for @protScreenshotsValue.
  ///
  /// In en, this message translates to:
  /// **'On, on every screen'**
  String get protScreenshotsValue;

  /// No description provided for @protAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get protAutoLock;

  /// No description provided for @protAutoLockValue.
  ///
  /// In en, this message translates to:
  /// **'When you leave the app'**
  String get protAutoLockValue;

  /// No description provided for @protNetwork.
  ///
  /// In en, this message translates to:
  /// **'Tor connection'**
  String get protNetwork;

  /// No description provided for @protNetworkValue.
  ///
  /// In en, this message translates to:
  /// **'Not connected: stage 1 never goes online. Tor arrives in stage 2.'**
  String get protNetworkValue;

  /// No description provided for @hwStrongbox.
  ///
  /// In en, this message translates to:
  /// **'StrongBox security chip'**
  String get hwStrongbox;

  /// No description provided for @hwTee.
  ///
  /// In en, this message translates to:
  /// **'Trusted execution environment (TEE)'**
  String get hwTee;

  /// No description provided for @hwTpm.
  ///
  /// In en, this message translates to:
  /// **'TPM 2.0'**
  String get hwTpm;

  /// No description provided for @hwOsSoftware.
  ///
  /// In en, this message translates to:
  /// **'Android Keystore (no secure hardware)'**
  String get hwOsSoftware;

  /// No description provided for @hwSoftwareFile.
  ///
  /// In en, this message translates to:
  /// **'Software key (next to the vault)'**
  String get hwSoftwareFile;

  /// No description provided for @hwNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get hwNone;

  /// No description provided for @hwDev.
  ///
  /// In en, this message translates to:
  /// **'None (development core)'**
  String get hwDev;

  /// No description provided for @hwBoundHint.
  ///
  /// In en, this message translates to:
  /// **'Your PIN is bound to this device\'s hardware key. Even a copy of the vault file cannot be tried on another device.'**
  String get hwBoundHint;

  /// No description provided for @hwNotBoundHint.
  ///
  /// In en, this message translates to:
  /// **'No hardware key: if the vault file is copied, the PIN can be guessed on another device.'**
  String get hwNotBoundHint;

  /// No description provided for @settingsFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Your safety number'**
  String get settingsFingerprint;

  /// No description provided for @settingsFingerprintHint.
  ///
  /// In en, this message translates to:
  /// **'When verifying a contact it must be the same on both devices.'**
  String get settingsFingerprintHint;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @clipboardCheck.
  ///
  /// In en, this message translates to:
  /// **'Offer the Kilit message on the clipboard'**
  String get clipboardCheck;

  /// No description provided for @clipboardCheckHint.
  ///
  /// In en, this message translates to:
  /// **'When the vault opens, offers to open a KLT1: message on the clipboard. Android shows a notice that the clipboard was read.'**
  String get clipboardCheckHint;

  /// No description provided for @settingsPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// No description provided for @permIntro.
  ///
  /// In en, this message translates to:
  /// **'Kilit uses no sensitive permission right now.'**
  String get permIntro;

  /// No description provided for @permCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permCamera;

  /// No description provided for @permCameraValue.
  ///
  /// In en, this message translates to:
  /// **'Not used (camera arrives in stage 2)'**
  String get permCameraValue;

  /// No description provided for @permNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotifications;

  /// No description provided for @permNotificationsValue.
  ///
  /// In en, this message translates to:
  /// **'Not used'**
  String get permNotificationsValue;

  /// No description provided for @permInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get permInternet;

  /// No description provided for @permInternetValue.
  ///
  /// In en, this message translates to:
  /// **'None: stage 1 works offline'**
  String get permInternetValue;

  /// No description provided for @permOpenSystem.
  ///
  /// In en, this message translates to:
  /// **'Open system permission settings'**
  String get permOpenSystem;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicense;

  /// No description provided for @aboutAlpha.
  ///
  /// In en, this message translates to:
  /// **'Not independently audited. Alpha: good for testing, not for high-stakes use.'**
  String get aboutAlpha;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'id',
    'it',
    'ja',
    'pt',
    'ru',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return LAr();
    case 'de':
      return LDe();
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'fa':
      return LFa();
    case 'fr':
      return LFr();
    case 'id':
      return LId();
    case 'it':
      return LIt();
    case 'ja':
      return LJa();
    case 'pt':
      return LPt();
    case 'ru':
      return LRu();
    case 'tr':
      return LTr();
    case 'uk':
      return LUk();
    case 'vi':
      return LVi();
    case 'zh':
      return LZh();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
