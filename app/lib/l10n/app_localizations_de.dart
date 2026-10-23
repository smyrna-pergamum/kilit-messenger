// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get share => 'Teilen';

  @override
  String get lockNow => 'Jetzt sperren';

  @override
  String get panicTooltip => 'Tippen zum Sperren, halten für den Paniccode';

  @override
  String get panicNoCode =>
      'Lege zuerst in den Einstellungen einen Paniccode fest.';

  @override
  String get panicEnterTitle => 'Paniccode';

  @override
  String get panicEnterHint =>
      'Gib den Paniccode ein, um alles in Kilit zu löschen.';

  @override
  String get panicWrong => 'Das ist nicht der Paniccode.';

  @override
  String get settingsPanic => 'Paniccode';

  @override
  String get panicExplain =>
      'Vier Ziffern. Auf dem Sperrbildschirm statt deiner PIN oder nach langem Drücken der Sperrtaste eingegeben, löscht er alle Schlüssel, Nachrichten und Dateien in Kilit endgültig, und Kilit beginnt neu, als wäre es gerade installiert worden.';

  @override
  String get panicStatusOn => 'Festgelegt';

  @override
  String get panicStatusOff => 'Nicht festgelegt';

  @override
  String get panicSet => 'Paniccode festlegen';

  @override
  String get panicChange => 'Paniccode ändern';

  @override
  String get panicRemove => 'Paniccode entfernen';

  @override
  String get panicCreateTitle => 'Wähle einen Paniccode';

  @override
  String get panicCreateHint =>
      'Vier Ziffern. Wer diesen Code eingeben sieht, kann Kilit löschen.';

  @override
  String get panicConfirmTitle => 'Paniccode wiederholen';

  @override
  String get panicMismatch =>
      'Die Codes stimmen nicht überein. Beginne von vorn.';

  @override
  String get panicSaved => 'Paniccode festgelegt.';

  @override
  String get panicRemoved => 'Paniccode entfernt.';

  @override
  String get panicRejected =>
      'Dieser Code ist nicht möglich. Wähle einen anderen.';

  @override
  String get keptInVault => 'Im Tresor gespeichert.';

  @override
  String get alreadyInVault => 'Bereits im Tresor.';

  @override
  String get keptTitleFallback => 'Nachricht';

  @override
  String get devBanner => 'Entwicklungskern: keine echte Verschlüsselung.';

  @override
  String get lockTitleUnlock => 'Entsperren';

  @override
  String get lockTitleCreate => 'PIN festlegen';

  @override
  String get lockTitleConfirm => 'PIN erneut eingeben';

  @override
  String get lockHintUnlock => 'Gib deine PIN ein, um deinen Tresor zu öffnen.';

  @override
  String lockHintCreate(int min) {
    return 'Mindestens $min Ziffern. Wenn du sie vergisst, lässt sich dein Tresor nicht mehr öffnen: Es gibt keine Wiederherstellung.';
  }

  @override
  String get lockHintConfirm => 'Gib dieselbe PIN noch einmal ein.';

  @override
  String get lockMismatch => 'Die PINs stimmen nicht überein. Fang neu an.';

  @override
  String get lockWrongPin => 'Falsche PIN.';

  @override
  String get settingsChangePin => 'PIN ändern';

  @override
  String get changePinCurrent => 'Gib deine aktuelle PIN ein';

  @override
  String get changePinNew => 'Wähle eine neue PIN';

  @override
  String get changePinDone => 'PIN geändert.';

  @override
  String lockWait(int seconds) {
    return 'Warte $seconds s, bevor du es erneut versuchst.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count Ziffern eingegeben';
  }

  @override
  String get pinDelete => 'Löschen';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Chats';

  @override
  String get navVault => 'Tresor';

  @override
  String get navCamera => 'Kamera';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get chatsLater => 'Nachrichten über Tor kommen in Phase 2.';

  @override
  String get cameraLater =>
      'Eine Kamera, die nie Klartext auf den Speicher schreibt, kommt in Phase 2.';

  @override
  String get vaultAddNote => 'Notiz hinzufügen';

  @override
  String get vaultCompose => 'Träger-Nachricht';

  @override
  String get vaultOpenClipboard => 'Aus Zwischenablage öffnen';

  @override
  String get vaultOpenPasted => 'Eingefügten Text öffnen';

  @override
  String get vaultSealFile => 'Datei verschlüsseln';

  @override
  String get vaultOpenKlt => '.klt öffnen';

  @override
  String get vaultEmpty =>
      'Dein Tresor ist leer. Füge eine Notiz hinzu oder verschlüssele eine Datei; alles wird als .klt-Paket gespeichert.';

  @override
  String get vaultSigned => 'Signiert';

  @override
  String get vaultFileTooLarge => 'Die Datei ist zu groß: höchstens 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name wurde verschlüsselt und zum Tresor hinzugefügt.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name wurde verschlüsselt und zum Tresor hinzugefügt. Entfernte versteckte Daten: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name wurde verschlüsselt und zum Tresor hinzugefügt. Kilit kann aus diesem Dateityp keine versteckten Daten (etwa den Autor) entfernen; prüfe die Datei, bevor du sie teilst.';
  }

  @override
  String get damagedPictureTitle => 'Beschädigtes Bild';

  @override
  String get damagedPictureBody =>
      'Dieses Bild ist beschädigt, daher konnte Kilit seine versteckten Daten, etwa den Aufnahmeort, nicht entfernen. Trotzdem unverändert hinzufügen?';

  @override
  String get damagedPictureSeal => 'Unverändert hinzufügen';

  @override
  String get hiddenLocation => 'Standort';

  @override
  String get hiddenCamera => 'Kameradaten';

  @override
  String get hiddenAuthorNotes => 'Autor und Notizen';

  @override
  String get hiddenExtraImages => 'zusätzliche Bilder';

  @override
  String get hiddenOther => 'sonstige Metadaten';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Keine Kilit-Nachricht in der Zwischenablage. Halte in WhatsApp die Nachricht gedrückt und tippe auf Kopieren.';

  @override
  String get clipboardBanner =>
      'In der Zwischenablage ist eine Kilit-Nachricht.';

  @override
  String get clipboardBannerOpen => 'Öffnen';

  @override
  String get clipboardBannerDismiss => 'Ignorieren';

  @override
  String get noteNew => 'Neue Notiz';

  @override
  String get noteTitle => 'Titel';

  @override
  String get noteText => 'Notiz';

  @override
  String get sealAndSave => 'Verschlüsseln und speichern';

  @override
  String get carrierTitle => 'Träger-Nachricht';

  @override
  String get carrierIntro =>
      'Die Nachricht wird verschlüsselt und in Text umgewandelt, den du in eine App wie WhatsApp einfügen kannst.';

  @override
  String get carrierMessage => 'Nachricht';

  @override
  String get withPassphrase => 'Mit gemeinsamer Passphrase';

  @override
  String get carrierWithPassphraseHint =>
      'Die Gegenseite öffnet sie mit derselben Passphrase. Aus: Nur du kannst sie öffnen.';

  @override
  String get passphrase => 'Gemeinsame Passphrase';

  @override
  String get carrierPassphraseHelper =>
      'Mindestens 12 Zeichen. Schick sie nicht über denselben Kanal wie die Nachricht.';

  @override
  String get carrierSeal => 'Verschlüsseln';

  @override
  String get carrierResultIntro =>
      'Kopiere diesen Text und schick ihn. Der Kanal sieht nur verschlüsselte Daten.';

  @override
  String carrierChars(int count) {
    return '$count Zeichen';
  }

  @override
  String get pasteTitle => 'Eingefügten Text öffnen';

  @override
  String get pasteInput => 'Aus einem Chat kopierter Text';

  @override
  String get pasteFromClipboard => 'Aus Zwischenablage einfügen';

  @override
  String get passphraseIfAny => 'Gemeinsame Passphrase (falls vorhanden)';

  @override
  String get pasteOpen => 'Suchen und öffnen';

  @override
  String get pasteNone => 'Kein KLT1-Paket im Text gefunden.';

  @override
  String get pasteTruncated =>
      'Ein Paket wurde abgeschnitten: Die sendende App hat die Nachricht eventuell gekürzt.';

  @override
  String get pasteMalformed => 'Ein Paket ist beschädigt.';

  @override
  String get openWrongKey =>
      'Dieses Paket lässt sich mit dieser Passphrase oder diesem Schlüssel nicht öffnen.';

  @override
  String get openDamaged => 'Dieses Paket ist beschädigt oder wurde verändert.';

  @override
  String get openIsFile =>
      'Dieses Paket enthält eine Datei; füge sie mit „.klt öffnen“ zum Tresor hinzu.';

  @override
  String get packetTitle => 'Paketanalyse';

  @override
  String get packetFile => 'Datei';

  @override
  String get packetType => 'Typ';

  @override
  String get packetSize => 'Größe';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (Paket $packet)';
  }

  @override
  String get packetFormat => 'Format';

  @override
  String get packetFormatValue => 'KLT1 (basiert auf age v1)';

  @override
  String get packetRecipients => 'Empfänger';

  @override
  String get packetContent => 'Inhalt';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, 64-KiB-Blöcke';

  @override
  String get packetSignature => 'Signatur';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, verifiziert';

  @override
  String get sigUnsigned => 'Unsigniert';

  @override
  String get sigInvalid => 'UNGÜLTIG';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (gemeinsame Passphrase)';

  @override
  String get itemOpen => 'Öffnen';

  @override
  String get itemView => 'Ansehen';

  @override
  String get itemExport => 'Als .klt exportieren';

  @override
  String get itemSavePlain => 'Unverschlüsselt speichern';

  @override
  String get savePlainTitle => 'Unverschlüsselt speichern?';

  @override
  String get savePlainBody =>
      'Die Datei wird entschlüsselt gespeichert. Jeder mit Zugriff auf den Speicherort kann sie lesen; Kilit kann sie dann nicht mehr schützen.';

  @override
  String get itemDelete => 'Aus dem Tresor löschen';

  @override
  String get exportTitle => 'Als .klt exportieren';

  @override
  String get exportIntro =>
      'Die Datei wird erneut verschlüsselt und von deinem Tresor signiert. Der Dateiname ist zufällig; der echte Name bleibt im verschlüsselten Paket.';

  @override
  String get exportWithPassphraseHint =>
      'Jeder mit der Passphrase kann sie öffnen. Aus: Nur dein Tresor kann sie öffnen (für Backups).';

  @override
  String get exportPassphraseHelper =>
      'Mindestens 12 Zeichen. Schick sie nicht über denselben Kanal wie die Datei.';

  @override
  String get passphraseTooShort =>
      'Die gemeinsame Passphrase muss mindestens 12 Zeichen lang sein.';

  @override
  String get importTitle => '.klt-Datei öffnen';

  @override
  String get importPassphraseHelper =>
      'Leer lassen, wenn sie an deinen eigenen Tresor gesendet wurde.';

  @override
  String get importGo => 'Öffnen und zum Tresor hinzufügen';

  @override
  String importAddedSigned(String name) {
    return '$name wurde zum Tresor hinzugefügt (signiert).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name wurde zum Tresor hinzugefügt (unsigniert).';
  }

  @override
  String get importWrongKey =>
      'Diese Datei lässt sich mit dieser Passphrase oder deinem Tresor nicht öffnen.';

  @override
  String get importNotKlt => 'Das ist keine .klt-Datei.';

  @override
  String get importDamaged => 'Die Datei ist beschädigt oder wurde verändert.';

  @override
  String get settingsProtections => 'Deine Schutzmaßnahmen';

  @override
  String get protPin => 'PIN-Schutz';

  @override
  String get protScreenshots => 'Screenshot-Sperre';

  @override
  String get protScreenshotsValue => 'An, auf jedem Bildschirm';

  @override
  String get protAutoLock => 'Automatische Sperre';

  @override
  String get protAutoLockValue => 'Wenn du die App verlässt';

  @override
  String get protNetwork => 'Tor-Verbindung';

  @override
  String get protNetworkValue =>
      'Nicht verbunden: Phase 1 geht nie online. Tor kommt in Phase 2.';

  @override
  String get hwStrongbox => 'StrongBox-Sicherheitschip';

  @override
  String get hwTee => 'Vertrauenswürdige Ausführungsumgebung (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (keine sichere Hardware)';

  @override
  String get hwSoftwareFile => 'Software-Schlüssel (neben dem Tresor)';

  @override
  String get hwNone => 'Keine';

  @override
  String get hwDev => 'Keine (Entwicklungskern)';

  @override
  String get hwBoundHint =>
      'Deine PIN ist an den Hardware-Schlüssel dieses Geräts gebunden. Selbst eine Kopie der Tresordatei kann auf keinem anderen Gerät ausprobiert werden.';

  @override
  String get hwNotBoundHint =>
      'Kein Hardware-Schlüssel: Wird die Tresordatei kopiert, kann die PIN auf einem anderen Gerät erraten werden.';

  @override
  String get settingsFingerprint => 'Deine Sicherheitsnummer';

  @override
  String get settingsFingerprintHint =>
      'Beim Verifizieren eines Kontakts muss sie auf beiden Geräten gleich sein.';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get clipboardCheck =>
      'Kilit-Nachricht aus der Zwischenablage anbieten';

  @override
  String get clipboardCheckHint =>
      'Beim Öffnen des Tresors wird angeboten, eine KLT1:-Nachricht aus der Zwischenablage zu öffnen. Android zeigt einen Hinweis, dass die Zwischenablage gelesen wurde.';

  @override
  String get settingsPermissions => 'Berechtigungen';

  @override
  String get permIntro => 'Kilit nutzt derzeit keine sensible Berechtigung.';

  @override
  String get permCamera => 'Kamera';

  @override
  String get permCameraValue => 'Nicht genutzt (Kamera kommt in Phase 2)';

  @override
  String get permNotifications => 'Benachrichtigungen';

  @override
  String get permNotificationsValue => 'Nicht genutzt';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Keine: Phase 1 funktioniert offline';

  @override
  String get permOpenSystem => 'Berechtigungseinstellungen des Systems öffnen';

  @override
  String get settingsAbout => 'Über';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicense => 'Lizenz';

  @override
  String get aboutAlpha =>
      'Nicht unabhängig geprüft. Alpha: gut zum Testen, nicht für kritische Einsätze.';
}
