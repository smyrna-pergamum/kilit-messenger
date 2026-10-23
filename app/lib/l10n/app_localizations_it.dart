// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LIt extends L {
  LIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get copy => 'Copia';

  @override
  String get copied => 'Copiato';

  @override
  String get share => 'Condividi';

  @override
  String get lockNow => 'Blocca ora';

  @override
  String get panicTooltip =>
      'Tocca per bloccare, tieni premuto per il codice di panico';

  @override
  String get panicNoCode =>
      'Imposta prima un codice di panico nelle Impostazioni.';

  @override
  String get panicEnterTitle => 'Codice di panico';

  @override
  String get panicEnterHint =>
      'Inserisci il codice di panico per cancellare tutto in Kilit.';

  @override
  String get panicWrong => 'Questo non è il codice di panico.';

  @override
  String get settingsPanic => 'Codice di panico';

  @override
  String get panicExplain =>
      'Quattro cifre. Inserito nella schermata di blocco al posto del PIN, o dopo aver tenuto premuto il pulsante di blocco, cancella per sempre tutte le chiavi, i messaggi e i file di Kilit, e Kilit riparte come appena installato.';

  @override
  String get panicStatusOn => 'Impostato';

  @override
  String get panicStatusOff => 'Non impostato';

  @override
  String get panicSet => 'Imposta codice di panico';

  @override
  String get panicChange => 'Cambia codice di panico';

  @override
  String get panicRemove => 'Rimuovi codice di panico';

  @override
  String get panicCreateTitle => 'Scegli un codice di panico';

  @override
  String get panicCreateHint =>
      'Quattro cifre. Chi ti vede inserirlo può cancellare Kilit.';

  @override
  String get panicConfirmTitle => 'Ripeti il codice di panico';

  @override
  String get panicMismatch => 'I codici non corrispondono. Ricomincia.';

  @override
  String get panicSaved => 'Codice di panico impostato.';

  @override
  String get panicRemoved => 'Codice di panico rimosso.';

  @override
  String get panicRejected =>
      'Questo codice non si può usare. Scegline un altro.';

  @override
  String get keptInVault => 'Salvato nella cassaforte.';

  @override
  String get alreadyInVault => 'Già nella cassaforte.';

  @override
  String get keptTitleFallback => 'Messaggio';

  @override
  String get devBanner => 'Nucleo di sviluppo: nessuna vera crittografia.';

  @override
  String get lockTitleUnlock => 'Sblocca';

  @override
  String get lockTitleCreate => 'Scegli un PIN';

  @override
  String get lockTitleConfirm => 'Inserisci di nuovo il PIN';

  @override
  String get lockHintUnlock =>
      'Inserisci il tuo PIN per aprire la tua cassaforte.';

  @override
  String lockHintCreate(int min) {
    return 'Almeno $min cifre. Se lo dimentichi, la tua cassaforte non potrà essere aperta: non c\'è recupero.';
  }

  @override
  String get lockHintConfirm => 'Inserisci lo stesso PIN ancora una volta.';

  @override
  String get lockMismatch => 'I PIN non corrispondono. Ricomincia.';

  @override
  String get lockWrongPin => 'PIN errato.';

  @override
  String get settingsChangePin => 'Cambia PIN';

  @override
  String get changePinCurrent => 'Inserisci il PIN attuale';

  @override
  String get changePinNew => 'Scegli un nuovo PIN';

  @override
  String get changePinDone => 'PIN cambiato.';

  @override
  String lockWait(int seconds) {
    return 'Attendi $seconds s prima di riprovare.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count cifre inserite';
  }

  @override
  String get pinDelete => 'Cancella';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Chat';

  @override
  String get navVault => 'Cassaforte';

  @override
  String get navCamera => 'Fotocamera';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get chatsLater => 'La messaggistica tramite Tor arriva nella fase 2.';

  @override
  String get chatsIntro =>
      'I messaggi sono cifrati end-to-end con il protocollo Signal (PQXDH e SPQR, post-quantistico). Finché non arriva la rete di Kilit, viaggiano come testo che copi in qualsiasi app di chat.';

  @override
  String get chatsEmpty =>
      'Ancora nessun contatto. Dai la tua scheda a qualcuno o aggiungi la sua.';

  @override
  String get chatsShareCard => 'La mia scheda';

  @override
  String get chatsAddContact => 'Aggiungi contatto';

  @override
  String get chatsOpenClipboard => 'Apri dagli appunti';

  @override
  String get chatsNothingOnClipboard =>
      'Negli appunti non c\'è nessun messaggio Kilit né scheda contatto.';

  @override
  String get cardTitle => 'La tua scheda contatto';

  @override
  String get cardName => 'Nome da mostrare (facoltativo)';

  @override
  String get cardShow => 'Crea scheda';

  @override
  String get cardHint =>
      'Invia questo testo alla persona con cui vuoi parlare. Non contiene segreti. Una volta collegati, confrontate i numeri di sicurezza.';

  @override
  String get addContactTitle => 'Aggiungi un contatto';

  @override
  String get addContactCard => 'La sua scheda contatto (KLC1:…)';

  @override
  String get addContactName => 'Nome (facoltativo)';

  @override
  String get addContactGo => 'Aggiungi';

  @override
  String get addContactRefused =>
      'Questa non è una scheda contatto, oppure è la tua.';

  @override
  String get contactUnnamed => 'Contatto senza nome';

  @override
  String get chatEmpty =>
      'Ancora nessun messaggio. Il primo che scrivi avvia la sessione cifrata.';

  @override
  String get chatInput => 'Messaggio';

  @override
  String get chatSend => 'Cifra';

  @override
  String get chatPaste => 'Apri una risposta dagli appunti';

  @override
  String get chatSealedTitle => 'Messaggio cifrato';

  @override
  String chatSealedHint(String name) {
    return 'Copia questo nella tua app di chat e invialo a $name. Solo questa persona può aprirlo.';
  }

  @override
  String get chatNewContact =>
      'Qualcuno che ha la tua scheda ti ha scritto. Dagli un nome e confrontate i numeri di sicurezza prima di fidarti.';

  @override
  String get chatOtherContact =>
      'È stato aperto anche un messaggio di un altro contatto; è nella sua conversazione.';

  @override
  String get chatDuplicate => 'Questo messaggio è già stato aperto.';

  @override
  String get chatUnknown =>
      'Questo messaggio non è di nessuno con cui hai una sessione.';

  @override
  String get chatDamaged => 'Il messaggio è danneggiato.';

  @override
  String get safetyTitle => 'Numero di sicurezza';

  @override
  String safetyHint(String name) {
    return 'Confronta queste 60 cifre con $name, di persona o al telefono. Se sono uguali su entrambi i telefoni, non c\'è nessuno nel mezzo.';
  }

  @override
  String get contactRename => 'Rinomina';

  @override
  String get contactRemove => 'Elimina contatto';

  @override
  String get contactRemoveTitle => 'Eliminare questo contatto?';

  @override
  String get contactRemoveBody =>
      'Vengono eliminate la sessione e tutta la conversazione. Per scrivervi di nuovo vi servono le vostre schede.';

  @override
  String get contactRemoveGo => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get cameraLater =>
      'Una fotocamera che non scrive mai dati in chiaro sulla memoria arriva nella fase 2.';

  @override
  String get vaultAddNote => 'Aggiungi nota';

  @override
  String get vaultCompose => 'Messaggio vettore';

  @override
  String get vaultOpenClipboard => 'Apri dagli appunti';

  @override
  String get vaultOpenPasted => 'Apri testo incollato';

  @override
  String get vaultSealFile => 'Cifra un file';

  @override
  String get vaultOpenKlt => 'Apri .klt';

  @override
  String get vaultEmpty =>
      'La tua cassaforte è vuota. Aggiungi una nota o cifra un file; tutto viene conservato come pacchetto .klt.';

  @override
  String get vaultSigned => 'Firmato';

  @override
  String get vaultFileTooLarge => 'Il file è troppo grande: massimo 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name è stato cifrato e aggiunto alla cassaforte.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name è stato cifrato e aggiunto alla cassaforte. Dati nascosti rimossi: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name è stato cifrato e aggiunto alla cassaforte. Kilit non può rimuovere i dati nascosti (come l\'autore) da questo tipo di file; controllalo prima di condividerlo.';
  }

  @override
  String get damagedPictureTitle => 'Immagine danneggiata';

  @override
  String get damagedPictureBody =>
      'Questa immagine è danneggiata, quindi Kilit non ha potuto rimuovere i suoi dati nascosti, come il luogo dello scatto. Aggiungerla così com\'è?';

  @override
  String get damagedPictureSeal => 'Aggiungi così com\'è';

  @override
  String get hiddenLocation => 'posizione';

  @override
  String get hiddenCamera => 'dati della fotocamera';

  @override
  String get hiddenAuthorNotes => 'autore e note';

  @override
  String get hiddenExtraImages => 'immagini aggiuntive';

  @override
  String get hiddenOther => 'altri metadati';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Nessun messaggio Kilit negli appunti. In WhatsApp, tieni premuto il messaggio e tocca Copia.';

  @override
  String get clipboardBanner => 'C\'è un messaggio Kilit negli appunti.';

  @override
  String get clipboardBannerOpen => 'Apri';

  @override
  String get clipboardBannerDismiss => 'Ignora';

  @override
  String get noteNew => 'Nuova nota';

  @override
  String get noteTitle => 'Titolo';

  @override
  String get noteText => 'Nota';

  @override
  String get sealAndSave => 'Cifra e salva';

  @override
  String get carrierTitle => 'Messaggio vettore';

  @override
  String get carrierIntro =>
      'Il messaggio viene cifrato e trasformato in testo da incollare in un\'app come WhatsApp.';

  @override
  String get carrierMessage => 'Messaggio';

  @override
  String get withPassphrase => 'Con una passphrase condivisa';

  @override
  String get carrierWithPassphraseHint =>
      'L\'altra persona lo apre con la stessa passphrase. Disattivato: solo tu puoi aprirlo.';

  @override
  String get passphrase => 'Passphrase condivisa';

  @override
  String get carrierPassphraseHelper =>
      'Almeno 12 caratteri. Non inviarla tramite lo stesso canale del messaggio.';

  @override
  String get carrierSeal => 'Cifra';

  @override
  String get carrierResultIntro =>
      'Copia e invia questo testo. Il canale vede solo dati cifrati.';

  @override
  String carrierChars(int count) {
    return '$count caratteri';
  }

  @override
  String get pasteTitle => 'Apri testo incollato';

  @override
  String get pasteInput => 'Testo copiato da una chat';

  @override
  String get pasteFromClipboard => 'Incolla dagli appunti';

  @override
  String get passphraseIfAny => 'Passphrase condivisa (se presente)';

  @override
  String get pasteOpen => 'Trova e apri';

  @override
  String get pasteNone => 'Nessun pacchetto KLT1 trovato nel testo.';

  @override
  String get pasteTruncated =>
      'Un pacchetto è stato troncato: l\'app di invio potrebbe aver accorciato il messaggio.';

  @override
  String get pasteMalformed => 'Un pacchetto è danneggiato.';

  @override
  String get openWrongKey =>
      'Questo pacchetto non si apre con questa passphrase o chiave.';

  @override
  String get openDamaged =>
      'Questo pacchetto è danneggiato o è stato modificato.';

  @override
  String get openIsFile =>
      'Questo pacchetto contiene un file; aggiungilo alla cassaforte con Apri .klt.';

  @override
  String get packetTitle => 'Analisi del pacchetto';

  @override
  String get packetFile => 'File';

  @override
  String get packetType => 'Tipo';

  @override
  String get packetSize => 'Dimensione';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (pacchetto $packet)';
  }

  @override
  String get packetFormat => 'Formato';

  @override
  String get packetFormatValue => 'KLT1 (basato su age v1)';

  @override
  String get packetRecipients => 'Destinatari';

  @override
  String get packetContent => 'Contenuto';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, blocchi da 64 KiB';

  @override
  String get packetSignature => 'Firma';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, verificata';

  @override
  String get sigUnsigned => 'Non firmato';

  @override
  String get sigInvalid => 'NON VALIDA';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (passphrase condivisa)';

  @override
  String get itemOpen => 'Apri';

  @override
  String get itemView => 'Visualizza';

  @override
  String get itemExport => 'Esporta come .klt';

  @override
  String get itemSavePlain => 'Salva senza cifratura';

  @override
  String get savePlainTitle => 'Salvare senza cifratura?';

  @override
  String get savePlainBody =>
      'Il file viene salvato decifrato. Chiunque abbia accesso al punto in cui lo salvi può leggerlo; Kilit non può più proteggerlo.';

  @override
  String get itemDelete => 'Elimina dalla cassaforte';

  @override
  String get exportTitle => 'Esporta come .klt';

  @override
  String get exportIntro =>
      'Il file viene cifrato di nuovo e firmato dalla tua cassaforte. Il nome del file è casuale; il nome reale resta nel pacchetto cifrato.';

  @override
  String get exportWithPassphraseHint =>
      'Chiunque abbia la passphrase può aprirlo. Disattivato: solo la tua cassaforte lo apre (per i backup).';

  @override
  String get exportPassphraseHelper =>
      'Almeno 12 caratteri. Non inviarla tramite lo stesso canale del file.';

  @override
  String get passphraseTooShort =>
      'La passphrase condivisa deve avere almeno 12 caratteri.';

  @override
  String get importTitle => 'Apri un file .klt';

  @override
  String get importPassphraseHelper =>
      'Lascia vuoto se è stato inviato alla tua cassaforte.';

  @override
  String get importGo => 'Apri e aggiungi alla cassaforte';

  @override
  String importAddedSigned(String name) {
    return '$name è stato aggiunto alla cassaforte (firmato).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name è stato aggiunto alla cassaforte (non firmato).';
  }

  @override
  String get importWrongKey =>
      'Questo file non si apre con questa passphrase o con la tua cassaforte.';

  @override
  String get importNotKlt => 'Questo non è un file .klt.';

  @override
  String get importDamaged => 'Il file è danneggiato o è stato modificato.';

  @override
  String get settingsProtections => 'Le tue protezioni';

  @override
  String get protPin => 'Protezione con PIN';

  @override
  String get protScreenshots => 'Blocco screenshot';

  @override
  String get protScreenshotsValue => 'Attivo, su ogni schermata';

  @override
  String get protAutoLock => 'Blocco automatico';

  @override
  String get protAutoLockValue => 'Quando esci dall\'app';

  @override
  String get protNetwork => 'Connessione Tor';

  @override
  String get protNetworkValue =>
      'Non connesso: la fase 1 non va mai online. Tor arriva nella fase 2.';

  @override
  String get hwStrongbox => 'Chip di sicurezza StrongBox';

  @override
  String get hwTee => 'Ambiente di esecuzione attendibile (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (nessun hardware sicuro)';

  @override
  String get hwSoftwareFile => 'Chiave software (accanto alla cassaforte)';

  @override
  String get hwNone => 'Nessuno';

  @override
  String get hwDev => 'Nessuno (nucleo di sviluppo)';

  @override
  String get hwBoundHint =>
      'Il tuo PIN è legato alla chiave hardware di questo dispositivo. Nemmeno una copia del file della cassaforte può essere provata su un altro dispositivo.';

  @override
  String get hwNotBoundHint =>
      'Nessuna chiave hardware: se il file della cassaforte viene copiato, il PIN può essere indovinato su un altro dispositivo.';

  @override
  String get settingsFingerprint => 'Il tuo numero di sicurezza';

  @override
  String get settingsFingerprintHint =>
      'Quando verifichi un contatto, deve essere uguale su entrambi i dispositivi.';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get clipboardCheck => 'Proponi il messaggio Kilit negli appunti';

  @override
  String get clipboardCheckHint =>
      'All\'apertura della cassaforte, propone di aprire un messaggio KLT1: presente negli appunti. Android mostra un avviso che gli appunti sono stati letti.';

  @override
  String get settingsPermissions => 'Autorizzazioni';

  @override
  String get permIntro =>
      'Al momento Kilit non usa alcuna autorizzazione sensibile.';

  @override
  String get permCamera => 'Fotocamera';

  @override
  String get permCameraValue => 'Non usata (la fotocamera arriva nella fase 2)';

  @override
  String get permNotifications => 'Notifiche';

  @override
  String get permNotificationsValue => 'Non usate';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Nessuno: la fase 1 funziona offline';

  @override
  String get permOpenSystem =>
      'Apri le impostazioni delle autorizzazioni di sistema';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get aboutVersion => 'Versione';

  @override
  String get aboutLicense => 'Licenza';

  @override
  String get aboutAlpha =>
      'Non verificato in modo indipendente. Alfa: adatto ai test, non a usi critici.';
}
