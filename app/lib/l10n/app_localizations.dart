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

  /// No description provided for @panicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap to lock, hold for the panic code'**
  String get panicTooltip;

  /// No description provided for @panicNoCode.
  ///
  /// In en, this message translates to:
  /// **'Set a panic code in Settings first.'**
  String get panicNoCode;

  /// No description provided for @panicEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Panic code'**
  String get panicEnterTitle;

  /// No description provided for @panicEnterHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the panic code to erase everything in Kilit.'**
  String get panicEnterHint;

  /// No description provided for @panicWrong.
  ///
  /// In en, this message translates to:
  /// **'That is not the panic code.'**
  String get panicWrong;

  /// No description provided for @settingsPanic.
  ///
  /// In en, this message translates to:
  /// **'Panic code'**
  String get settingsPanic;

  /// No description provided for @panicExplain.
  ///
  /// In en, this message translates to:
  /// **'Four digits. Entered on the lock screen instead of your PIN, or after holding the lock button, it erases every key, message and file in Kilit for good, and Kilit starts over as if it had just been installed.'**
  String get panicExplain;

  /// No description provided for @panicStatusOn.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get panicStatusOn;

  /// No description provided for @panicStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get panicStatusOff;

  /// No description provided for @panicSet.
  ///
  /// In en, this message translates to:
  /// **'Set panic code'**
  String get panicSet;

  /// No description provided for @panicChange.
  ///
  /// In en, this message translates to:
  /// **'Change panic code'**
  String get panicChange;

  /// No description provided for @panicRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove panic code'**
  String get panicRemove;

  /// No description provided for @panicCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a panic code'**
  String get panicCreateTitle;

  /// No description provided for @panicCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Four digits. Anyone who sees this code entered can erase Kilit.'**
  String get panicCreateHint;

  /// No description provided for @panicConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat the panic code'**
  String get panicConfirmTitle;

  /// No description provided for @panicMismatch.
  ///
  /// In en, this message translates to:
  /// **'The codes did not match. Start again.'**
  String get panicMismatch;

  /// No description provided for @panicSaved.
  ///
  /// In en, this message translates to:
  /// **'Panic code set.'**
  String get panicSaved;

  /// No description provided for @panicRemoved.
  ///
  /// In en, this message translates to:
  /// **'Panic code removed.'**
  String get panicRemoved;

  /// No description provided for @panicRejected.
  ///
  /// In en, this message translates to:
  /// **'This code cannot be used. Choose another.'**
  String get panicRejected;

  /// No description provided for @keptInVault.
  ///
  /// In en, this message translates to:
  /// **'Saved in the vault.'**
  String get keptInVault;

  /// No description provided for @alreadyInVault.
  ///
  /// In en, this message translates to:
  /// **'Already in the vault.'**
  String get alreadyInVault;

  /// No description provided for @keptTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get keptTitleFallback;

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

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @changePinCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get changePinCurrent;

  /// No description provided for @changePinNew.
  ///
  /// In en, this message translates to:
  /// **'Choose a new PIN'**
  String get changePinNew;

  /// No description provided for @changePinDone.
  ///
  /// In en, this message translates to:
  /// **'PIN changed.'**
  String get changePinDone;

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

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. The first one you write starts the encrypted session.'**
  String get chatEmpty;

  /// No description provided for @chatInput.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatInput;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatNewContact.
  ///
  /// In en, this message translates to:
  /// **'Wrote to you without being added. Accept to reply, or block them. Compare safety numbers before you trust them.'**
  String get chatNewContact;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety number'**
  String get safetyTitle;

  /// No description provided for @safetyHint.
  ///
  /// In en, this message translates to:
  /// **'Compare these 60 digits with {name}, in person or on a call. If they are the same on both phones, no one is in between.'**
  String safetyHint(String name);

  /// No description provided for @attachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachCamera;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Photo or file'**
  String get attachFile;

  /// No description provided for @chatFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Too large to send: 5 MB at most.'**
  String get chatFileTooLarge;

  /// No description provided for @chatDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get chatDelivered;

  /// No description provided for @fileComing.
  ///
  /// In en, this message translates to:
  /// **'Receiving…'**
  String get fileComing;

  /// No description provided for @fileToVault.
  ///
  /// In en, this message translates to:
  /// **'Add to vault'**
  String get fileToVault;

  /// No description provided for @fileSavedVault.
  ///
  /// In en, this message translates to:
  /// **'Added to the vault.'**
  String get fileSavedVault;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disappearing messages'**
  String get timerTitle;

  /// No description provided for @timerHint.
  ///
  /// In en, this message translates to:
  /// **'New messages in this chat disappear after this time, on both phones.'**
  String get timerHint;

  /// No description provided for @timerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get timerOff;

  /// No description provided for @timer5m.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get timer5m;

  /// No description provided for @timer1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get timer1h;

  /// No description provided for @timer1d.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get timer1d;

  /// No description provided for @timer1w.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get timer1w;

  /// No description provided for @renewTitle.
  ///
  /// In en, this message translates to:
  /// **'Renew my Kilit ID'**
  String get renewTitle;

  /// No description provided for @renewBody.
  ///
  /// In en, this message translates to:
  /// **'You get new words, a new link and a new QR code. Your contacts keep talking to you as before; the old ID and link stop working for anyone new.'**
  String get renewBody;

  /// No description provided for @renewGo.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renewGo;

  /// No description provided for @renewDone.
  ///
  /// In en, this message translates to:
  /// **'Your new ID: @{id}'**
  String renewDone(String id);

  /// No description provided for @cameraNoCamera.
  ///
  /// In en, this message translates to:
  /// **'The camera could not be opened. Check the camera permission in the phone\'s settings.'**
  String get cameraNoCamera;

  /// No description provided for @cameraShutter.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get cameraShutter;

  /// No description provided for @cameraRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get cameraRetake;

  /// No description provided for @cameraUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get cameraUse;

  /// No description provided for @cameraIntro.
  ///
  /// In en, this message translates to:
  /// **'Photos are taken in memory only: nothing is written to the phone, and they carry no location or camera data.'**
  String get cameraIntro;

  /// No description provided for @cameraSendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to…'**
  String get cameraSendTo;

  /// No description provided for @cameraToVault.
  ///
  /// In en, this message translates to:
  /// **'Keep in the vault'**
  String get cameraToVault;

  /// No description provided for @cameraSavedVault.
  ///
  /// In en, this message translates to:
  /// **'Photo kept in the vault.'**
  String get cameraSavedVault;

  /// No description provided for @cameraNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts to send to yet.'**
  String get cameraNoContacts;

  /// No description provided for @cameraSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to {name}.'**
  String cameraSent(String name);

  /// No description provided for @chatsYourKilit.
  ///
  /// In en, this message translates to:
  /// **'Your Kilit'**
  String get chatsYourKilit;

  /// No description provided for @chatsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get chatsSearch;

  /// No description provided for @chatsEmptyNew.
  ///
  /// In en, this message translates to:
  /// **'No one here yet. Add someone, or show them your code.'**
  String get chatsEmptyNew;

  /// No description provided for @torChipReady.
  ///
  /// In en, this message translates to:
  /// **'Tor ready'**
  String get torChipReady;

  /// No description provided for @torChipStarting.
  ///
  /// In en, this message translates to:
  /// **'Tor {progress}%'**
  String torChipStarting(int progress);

  /// No description provided for @torChipOff.
  ///
  /// In en, this message translates to:
  /// **'Tor off'**
  String get torChipOff;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get addTitle;

  /// No description provided for @addHint.
  ///
  /// In en, this message translates to:
  /// **'Scan their code, or paste what they gave you: a link or an @ID.'**
  String get addHint;

  /// No description provided for @addScan.
  ///
  /// In en, this message translates to:
  /// **'Scan their code'**
  String get addScan;

  /// No description provided for @addField.
  ///
  /// In en, this message translates to:
  /// **'A Kilit link or @ID'**
  String get addField;

  /// No description provided for @addGo.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addGo;

  /// No description provided for @addSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking them up over Tor…'**
  String get addSearching;

  /// No description provided for @addNotFound.
  ///
  /// In en, this message translates to:
  /// **'No one found for this ID. Check it, or try again in a moment.'**
  String get addNotFound;

  /// No description provided for @addOffline.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Tor yet. Wait until it says Tor ready.'**
  String get addOffline;

  /// No description provided for @addNotInvite.
  ///
  /// In en, this message translates to:
  /// **'That is not a Kilit link or @ID.'**
  String get addNotInvite;

  /// No description provided for @addShowMine.
  ///
  /// In en, this message translates to:
  /// **'Show my code'**
  String get addShowMine;

  /// No description provided for @addShowMineHint.
  ///
  /// In en, this message translates to:
  /// **'Your QR code, your link, your @ID'**
  String get addShowMineHint;

  /// No description provided for @myTitle.
  ///
  /// In en, this message translates to:
  /// **'My code'**
  String get myTitle;

  /// No description provided for @myHint.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this code, your link or your @ID can write to you. Their first message waits in Requests until you accept.'**
  String get myHint;

  /// No description provided for @myCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get myCopyLink;

  /// No description provided for @myShareText.
  ///
  /// In en, this message translates to:
  /// **'Add me on Kilit: @{id}\n{link}'**
  String myShareText(String id, String link);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a Kilit code'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code.'**
  String get scanHint;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests.'**
  String get requestsEmpty;

  /// No description provided for @requestHint.
  ///
  /// In en, this message translates to:
  /// **'They wrote to you without being added. Nothing reaches them until you accept and write back.'**
  String get requestHint;

  /// No description provided for @requestAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get requestAccept;

  /// No description provided for @requestDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get requestDecline;

  /// No description provided for @requestBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get requestBlock;

  /// No description provided for @chatOnRelay.
  ///
  /// In en, this message translates to:
  /// **'On the relays'**
  String get chatOnRelay;

  /// No description provided for @chatQueued.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the network'**
  String get chatQueued;

  /// No description provided for @contactRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get contactRename;

  /// No description provided for @contactRemove.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get contactRemove;

  /// No description provided for @contactRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this contact?'**
  String get contactRemoveTitle;

  /// No description provided for @contactRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'The session and the whole conversation are deleted. To write again, add each other again.'**
  String get contactRemoveBody;

  /// No description provided for @contactRemoveGo.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get contactRemoveGo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @torOff.
  ///
  /// In en, this message translates to:
  /// **'Off: Kilit does not go online.'**
  String get torOff;

  /// No description provided for @torStarting.
  ///
  /// In en, this message translates to:
  /// **'Connecting… {progress}%'**
  String torStarting(int progress);

  /// No description provided for @torReady.
  ///
  /// In en, this message translates to:
  /// **'Connected through Tor.'**
  String get torReady;

  /// No description provided for @torFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Tor.'**
  String get torFailed;

  /// No description provided for @torUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device yet.'**
  String get torUnavailable;

  /// No description provided for @torSwitch.
  ///
  /// In en, this message translates to:
  /// **'Connect over Tor'**
  String get torSwitch;

  /// No description provided for @torSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Kilit reaches the network only through Tor. Off, it stays offline.'**
  String get torSwitchHint;

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

  /// No description provided for @settingsBridges.
  ///
  /// In en, this message translates to:
  /// **'Tor connection'**
  String get settingsBridges;

  /// No description provided for @torRouteAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get torRouteAuto;

  /// No description provided for @torRouteAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Straight to Tor; through bridges when that is blocked.'**
  String get torRouteAutoHint;

  /// No description provided for @torRouteDirect.
  ///
  /// In en, this message translates to:
  /// **'Straight to Tor'**
  String get torRouteDirect;

  /// No description provided for @torRouteObfs4.
  ///
  /// In en, this message translates to:
  /// **'obfs4 bridges'**
  String get torRouteObfs4;

  /// No description provided for @torRouteObfs4Hint.
  ///
  /// In en, this message translates to:
  /// **'For networks that block Tor.'**
  String get torRouteObfs4Hint;

  /// No description provided for @torRouteSnowflake.
  ///
  /// In en, this message translates to:
  /// **'Snowflake'**
  String get torRouteSnowflake;

  /// No description provided for @torRouteSnowflakeHint.
  ///
  /// In en, this message translates to:
  /// **'For heavy censorship. Slower.'**
  String get torRouteSnowflakeHint;

  /// No description provided for @torRouteCustom.
  ///
  /// In en, this message translates to:
  /// **'My own bridges'**
  String get torRouteCustom;

  /// No description provided for @torRouteCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Bridge lines from bridges.torproject.org or someone you trust.'**
  String get torRouteCustomHint;

  /// No description provided for @torRouteLinesHint.
  ///
  /// In en, this message translates to:
  /// **'One bridge line per row'**
  String get torRouteLinesHint;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get resend;

  /// No description provided for @resendHint.
  ///
  /// In en, this message translates to:
  /// **'A relay has this message, but their phone has not said it arrived. Kilit sends it again once a day for a week, until it does.'**
  String get resendHint;

  /// No description provided for @resendDone.
  ///
  /// In en, this message translates to:
  /// **'Sent again.'**
  String get resendDone;
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
