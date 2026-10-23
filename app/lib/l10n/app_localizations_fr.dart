// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié';

  @override
  String get share => 'Partager';

  @override
  String get lockNow => 'Verrouiller';

  @override
  String get panicTooltip =>
      'Touchez pour verrouiller, maintenez pour le code de panique';

  @override
  String get panicNoCode =>
      'Définissez d\'abord un code de panique dans les Réglages.';

  @override
  String get panicEnterTitle => 'Code de panique';

  @override
  String get panicEnterHint =>
      'Saisissez le code de panique pour tout effacer dans Kilit.';

  @override
  String get panicWrong => 'Ce n\'est pas le code de panique.';

  @override
  String get settingsPanic => 'Code de panique';

  @override
  String get panicExplain =>
      'Quatre chiffres. Saisi sur l\'écran de verrouillage à la place de votre PIN, ou après un appui long sur le bouton de verrouillage, il efface définitivement toutes les clés, tous les messages et fichiers de Kilit, et Kilit repart comme s\'il venait d\'être installé.';

  @override
  String get panicStatusOn => 'Défini';

  @override
  String get panicStatusOff => 'Non défini';

  @override
  String get panicSet => 'Définir le code de panique';

  @override
  String get panicChange => 'Changer le code de panique';

  @override
  String get panicRemove => 'Supprimer le code de panique';

  @override
  String get panicCreateTitle => 'Choisissez un code de panique';

  @override
  String get panicCreateHint =>
      'Quatre chiffres. Quiconque vous voit le saisir peut effacer Kilit.';

  @override
  String get panicConfirmTitle => 'Répétez le code de panique';

  @override
  String get panicMismatch => 'Les codes ne correspondent pas. Recommencez.';

  @override
  String get panicSaved => 'Code de panique défini.';

  @override
  String get panicRemoved => 'Code de panique supprimé.';

  @override
  String get panicRejected =>
      'Ce code ne peut pas être utilisé. Choisissez-en un autre.';

  @override
  String get keptInVault => 'Enregistré dans le coffre.';

  @override
  String get alreadyInVault => 'Déjà dans le coffre.';

  @override
  String get keptTitleFallback => 'Message';

  @override
  String get devBanner => 'Noyau de développement : aucun vrai chiffrement.';

  @override
  String get lockTitleUnlock => 'Déverrouiller';

  @override
  String get lockTitleCreate => 'Choisissez un PIN';

  @override
  String get lockTitleConfirm => 'Saisissez à nouveau le PIN';

  @override
  String get lockHintUnlock => 'Saisissez votre PIN pour ouvrir votre coffre.';

  @override
  String lockHintCreate(int min) {
    return 'Au moins $min chiffres. Si vous l\'oubliez, votre coffre ne pourra plus être ouvert : aucune récupération n\'est possible.';
  }

  @override
  String get lockHintConfirm => 'Saisissez le même PIN encore une fois.';

  @override
  String get lockMismatch => 'Les PIN ne correspondent pas. Recommencez.';

  @override
  String get lockWrongPin => 'PIN incorrect.';

  @override
  String get settingsChangePin => 'Changer le PIN';

  @override
  String get changePinCurrent => 'Saisissez votre PIN actuel';

  @override
  String get changePinNew => 'Choisissez un nouveau PIN';

  @override
  String get changePinDone => 'PIN modifié.';

  @override
  String lockWait(int seconds) {
    return 'Attendez $seconds s avant de réessayer.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count chiffres saisis';
  }

  @override
  String get pinDelete => 'Effacer';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Discussions';

  @override
  String get navVault => 'Coffre';

  @override
  String get navCamera => 'Caméra';

  @override
  String get navSettings => 'Réglages';

  @override
  String get chatsLater => 'La messagerie via Tor arrive à l\'étape 2.';

  @override
  String get chatsIntro =>
      'Les messages sont chiffrés de bout en bout avec le protocole Signal (PQXDH et SPQR, post-quantique). En attendant le réseau propre à Kilit, ils voyagent sous forme de texte que vous copiez dans n\'importe quelle messagerie.';

  @override
  String get chatsEmpty =>
      'Aucun contact pour l\'instant. Donnez votre carte à quelqu\'un ou ajoutez la sienne.';

  @override
  String get chatsShareCard => 'Ma carte';

  @override
  String get chatsAddContact => 'Ajouter un contact';

  @override
  String get chatsOpenClipboard => 'Ouvrir depuis le presse-papiers';

  @override
  String get chatsNothingOnClipboard =>
      'Aucun message Kilit ni carte de contact dans le presse-papiers.';

  @override
  String get cardTitle => 'Votre carte de contact';

  @override
  String get cardName => 'Nom à afficher (facultatif)';

  @override
  String get cardShow => 'Créer la carte';

  @override
  String get cardHint =>
      'Envoyez ce texte à la personne avec qui vous voulez échanger. Il ne contient aucun secret. Une fois connectés, comparez vos numéros de sécurité.';

  @override
  String get addContactTitle => 'Ajouter un contact';

  @override
  String get addContactCard => 'Sa carte de contact (KLC1:…)';

  @override
  String get addContactName => 'Nom (facultatif)';

  @override
  String get addContactGo => 'Ajouter';

  @override
  String get addContactRefused =>
      'Ce n\'est pas une carte de contact, ou c\'est la vôtre.';

  @override
  String get contactUnnamed => 'Contact sans nom';

  @override
  String get chatEmpty =>
      'Aucun message pour l\'instant. Le premier que vous écrivez ouvre la session chiffrée.';

  @override
  String get chatInput => 'Message';

  @override
  String get chatSend => 'Chiffrer';

  @override
  String get chatPaste => 'Ouvrir une réponse depuis le presse-papiers';

  @override
  String get chatSealedTitle => 'Message chiffré';

  @override
  String chatSealedHint(String name) {
    return 'Copiez ceci dans votre messagerie et envoyez-le à $name. Seule cette personne peut l\'ouvrir.';
  }

  @override
  String get chatNewContact =>
      'Quelqu\'un qui a votre carte vous a écrit. Donnez-lui un nom et comparez vos numéros de sécurité avant de lui faire confiance.';

  @override
  String get chatOtherContact =>
      'Un message d\'un autre contact a aussi été ouvert ; il est dans sa conversation.';

  @override
  String get chatDuplicate => 'Ce message a déjà été ouvert.';

  @override
  String get chatUnknown =>
      'Ce message ne vient de personne avec qui vous avez une session.';

  @override
  String get chatDamaged => 'Le message est endommagé.';

  @override
  String get safetyTitle => 'Numéro de sécurité';

  @override
  String safetyHint(String name) {
    return 'Comparez ces 60 chiffres avec $name, en personne ou par téléphone. S\'ils sont identiques sur les deux téléphones, personne n\'est entre vous.';
  }

  @override
  String get contactRename => 'Renommer';

  @override
  String get contactRemove => 'Supprimer le contact';

  @override
  String get contactRemoveTitle => 'Supprimer ce contact ?';

  @override
  String get contactRemoveBody =>
      'La session et toute la conversation sont supprimées. Pour vous réécrire, il vous faudra vos cartes.';

  @override
  String get contactRemoveGo => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get cameraLater =>
      'Une caméra qui n\'écrit jamais de données en clair sur le stockage arrive à l\'étape 2.';

  @override
  String get vaultAddNote => 'Ajouter une note';

  @override
  String get vaultCompose => 'Message porteur';

  @override
  String get vaultOpenClipboard => 'Ouvrir depuis le presse-papiers';

  @override
  String get vaultOpenPasted => 'Ouvrir un texte collé';

  @override
  String get vaultSealFile => 'Chiffrer un fichier';

  @override
  String get vaultOpenKlt => 'Ouvrir un .klt';

  @override
  String get vaultEmpty =>
      'Votre coffre est vide. Ajoutez une note ou chiffrez un fichier ; tout est conservé sous forme de paquet .klt.';

  @override
  String get vaultSigned => 'Signé';

  @override
  String get vaultFileTooLarge =>
      'Le fichier est trop volumineux : 64 MB maximum.';

  @override
  String vaultFileSealed(String name) {
    return '$name a été chiffré et ajouté au coffre.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name a été chiffré et ajouté au coffre. Données cachées supprimées : $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name a été chiffré et ajouté au coffre. Kilit ne peut pas supprimer les données cachées (comme l\'auteur) de ce type de fichier ; vérifiez-le avant de le partager.';
  }

  @override
  String get damagedPictureTitle => 'Image endommagée';

  @override
  String get damagedPictureBody =>
      'Cette image est endommagée : Kilit n\'a pas pu supprimer ses données cachées, comme le lieu de la prise de vue. L\'ajouter telle quelle ?';

  @override
  String get damagedPictureSeal => 'Ajouter telle quelle';

  @override
  String get hiddenLocation => 'position';

  @override
  String get hiddenCamera => 'infos de l\'appareil photo';

  @override
  String get hiddenAuthorNotes => 'auteur et notes';

  @override
  String get hiddenExtraImages => 'images supplémentaires';

  @override
  String get hiddenOther => 'autres métadonnées';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Aucun message Kilit dans le presse-papiers. Dans WhatsApp, appuyez longuement sur le message puis sur Copier.';

  @override
  String get clipboardBanner => 'Le presse-papiers contient un message Kilit.';

  @override
  String get clipboardBannerOpen => 'Ouvrir';

  @override
  String get clipboardBannerDismiss => 'Ignorer';

  @override
  String get noteNew => 'Nouvelle note';

  @override
  String get noteTitle => 'Titre';

  @override
  String get noteText => 'Note';

  @override
  String get sealAndSave => 'Chiffrer et enregistrer';

  @override
  String get carrierTitle => 'Message porteur';

  @override
  String get carrierIntro =>
      'Le message est chiffré et transformé en texte à coller dans une application comme WhatsApp.';

  @override
  String get carrierMessage => 'Message';

  @override
  String get withPassphrase => 'Avec une phrase secrète partagée';

  @override
  String get carrierWithPassphraseHint =>
      'Votre correspondant l\'ouvre avec la même phrase secrète. Désactivé : vous seul pouvez l\'ouvrir.';

  @override
  String get passphrase => 'Phrase secrète partagée';

  @override
  String get carrierPassphraseHelper =>
      'Au moins 12 caractères. Ne l\'envoyez pas par le même canal que le message.';

  @override
  String get carrierSeal => 'Chiffrer';

  @override
  String get carrierResultIntro =>
      'Copiez et envoyez ce texte. Le canal ne voit que des données chiffrées.';

  @override
  String carrierChars(int count) {
    return '$count caractères';
  }

  @override
  String get pasteTitle => 'Ouvrir un texte collé';

  @override
  String get pasteInput => 'Texte copié depuis une discussion';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get passphraseIfAny => 'Phrase secrète partagée (le cas échéant)';

  @override
  String get pasteOpen => 'Rechercher et ouvrir';

  @override
  String get pasteNone => 'Aucun paquet KLT1 trouvé dans le texte.';

  @override
  String get pasteTruncated =>
      'Un paquet a été coupé : l\'application d\'envoi a peut-être raccourci le message.';

  @override
  String get pasteMalformed => 'Un paquet est endommagé.';

  @override
  String get openWrongKey =>
      'Ce paquet ne s\'ouvre pas avec cette phrase secrète ou cette clé.';

  @override
  String get openDamaged => 'Ce paquet est endommagé ou a été modifié.';

  @override
  String get openIsFile =>
      'Ce paquet contient un fichier ; ajoutez-le au coffre avec Ouvrir un .klt.';

  @override
  String get packetTitle => 'Analyse du paquet';

  @override
  String get packetFile => 'Fichier';

  @override
  String get packetType => 'Type';

  @override
  String get packetSize => 'Taille';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (paquet $packet)';
  }

  @override
  String get packetFormat => 'Format';

  @override
  String get packetFormatValue => 'KLT1 (basé sur age v1)';

  @override
  String get packetRecipients => 'Destinataires';

  @override
  String get packetContent => 'Contenu';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, blocs de 64 KiB';

  @override
  String get packetSignature => 'Signature';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, vérifiée';

  @override
  String get sigUnsigned => 'Non signé';

  @override
  String get sigInvalid => 'INVALIDE';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (phrase secrète partagée)';

  @override
  String get itemOpen => 'Ouvrir';

  @override
  String get itemView => 'Afficher';

  @override
  String get itemExport => 'Exporter en .klt';

  @override
  String get itemSavePlain => 'Enregistrer sans chiffrement';

  @override
  String get savePlainTitle => 'Enregistrer sans chiffrement ?';

  @override
  String get savePlainBody =>
      'Le fichier est enregistré déchiffré. Toute personne ayant accès à l\'emplacement choisi peut le lire ; Kilit ne peut plus le protéger.';

  @override
  String get itemDelete => 'Supprimer du coffre';

  @override
  String get exportTitle => 'Exporter en .klt';

  @override
  String get exportIntro =>
      'Le fichier est à nouveau chiffré et signé par votre coffre. Le nom du fichier est aléatoire ; le vrai nom reste dans le paquet chiffré.';

  @override
  String get exportWithPassphraseHint =>
      'Toute personne disposant de la phrase secrète peut l\'ouvrir. Désactivé : seul votre coffre peut l\'ouvrir (pour les sauvegardes).';

  @override
  String get exportPassphraseHelper =>
      'Au moins 12 caractères. Ne l\'envoyez pas par le même canal que le fichier.';

  @override
  String get passphraseTooShort =>
      'La phrase secrète partagée doit comporter au moins 12 caractères.';

  @override
  String get importTitle => 'Ouvrir un fichier .klt';

  @override
  String get importPassphraseHelper =>
      'Laissez vide s\'il a été envoyé à votre propre coffre.';

  @override
  String get importGo => 'Ouvrir et ajouter au coffre';

  @override
  String importAddedSigned(String name) {
    return '$name a été ajouté au coffre (signé).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name a été ajouté au coffre (non signé).';
  }

  @override
  String get importWrongKey =>
      'Ce fichier ne s\'ouvre pas avec cette phrase secrète ou votre coffre.';

  @override
  String get importNotKlt => 'Ce n\'est pas un fichier .klt.';

  @override
  String get importDamaged => 'Le fichier est endommagé ou a été modifié.';

  @override
  String get settingsProtections => 'Vos protections';

  @override
  String get protPin => 'Protection par PIN';

  @override
  String get protScreenshots => 'Blocage des captures d\'écran';

  @override
  String get protScreenshotsValue => 'Activé, sur tous les écrans';

  @override
  String get protAutoLock => 'Verrouillage automatique';

  @override
  String get protAutoLockValue => 'Quand vous quittez l\'application';

  @override
  String get protNetwork => 'Connexion Tor';

  @override
  String get protNetworkValue =>
      'Non connecté : l\'étape 1 ne se connecte jamais. Tor arrive à l\'étape 2.';

  @override
  String get hwStrongbox => 'Puce de sécurité StrongBox';

  @override
  String get hwTee => 'Environnement d\'exécution de confiance (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (pas de matériel sécurisé)';

  @override
  String get hwSoftwareFile => 'Clé logicielle (à côté du coffre)';

  @override
  String get hwNone => 'Aucun';

  @override
  String get hwDev => 'Aucun (noyau de développement)';

  @override
  String get hwBoundHint =>
      'Votre PIN est lié à la clé matérielle de cet appareil. Même une copie du fichier du coffre ne peut pas être testée sur un autre appareil.';

  @override
  String get hwNotBoundHint =>
      'Pas de clé matérielle : si le fichier du coffre est copié, le PIN peut être deviné sur un autre appareil.';

  @override
  String get settingsFingerprint => 'Votre numéro de sécurité';

  @override
  String get settingsFingerprintHint =>
      'Lors de la vérification d\'un contact, il doit être identique sur les deux appareils.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get clipboardCheck => 'Proposer le message Kilit du presse-papiers';

  @override
  String get clipboardCheckHint =>
      'À l\'ouverture du coffre, propose d\'ouvrir un message KLT1: présent dans le presse-papiers. Android affiche un avis indiquant que le presse-papiers a été lu.';

  @override
  String get settingsPermissions => 'Autorisations';

  @override
  String get permIntro =>
      'Kilit n\'utilise actuellement aucune autorisation sensible.';

  @override
  String get permCamera => 'Caméra';

  @override
  String get permCameraValue => 'Non utilisée (la caméra arrive à l\'étape 2)';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permNotificationsValue => 'Non utilisées';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Aucun : l\'étape 1 fonctionne hors ligne';

  @override
  String get permOpenSystem => 'Ouvrir les autorisations du système';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicense => 'Licence';

  @override
  String get aboutAlpha =>
      'Pas d\'audit indépendant. Alpha : idéal pour tester, pas pour un usage critique.';
}
