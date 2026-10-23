// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get share => 'Compartir';

  @override
  String get lockNow => 'Bloquear ahora';

  @override
  String get devBanner => 'Núcleo de desarrollo: sin cifrado real.';

  @override
  String get lockTitleUnlock => 'Desbloquear';

  @override
  String get lockTitleCreate => 'Elige un PIN';

  @override
  String get lockTitleConfirm => 'Vuelve a introducir el PIN';

  @override
  String get lockHintUnlock => 'Introduce tu PIN para abrir tu bóveda.';

  @override
  String lockHintCreate(int min) {
    return 'Al menos $min dígitos. Si lo olvidas, tu bóveda no se podrá abrir: no hay recuperación.';
  }

  @override
  String get lockHintConfirm => 'Introduce el mismo PIN una vez más.';

  @override
  String get lockMismatch => 'Los PIN no coinciden. Empieza de nuevo.';

  @override
  String get lockWrongPin => 'PIN incorrecto.';

  @override
  String lockWait(int seconds) {
    return 'Espera $seconds s antes de volver a intentarlo.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count dígitos introducidos';
  }

  @override
  String get pinDelete => 'Borrar';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Chats';

  @override
  String get navVault => 'Bóveda';

  @override
  String get navCamera => 'Cámara';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get chatsLater => 'La mensajería a través de Tor llega en la fase 2.';

  @override
  String get cameraLater =>
      'Una cámara que nunca escribe texto sin cifrar en el almacenamiento llega en la fase 2.';

  @override
  String get vaultAddNote => 'Añadir nota';

  @override
  String get vaultCompose => 'Mensaje portador';

  @override
  String get vaultOpenClipboard => 'Abrir desde el portapapeles';

  @override
  String get vaultOpenPasted => 'Abrir texto pegado';

  @override
  String get vaultSealFile => 'Cifrar un archivo';

  @override
  String get vaultOpenKlt => 'Abrir .klt';

  @override
  String get vaultEmpty =>
      'Tu bóveda está vacía. Añade una nota o cifra un archivo; todo se guarda como un paquete .klt.';

  @override
  String get vaultSigned => 'Firmado';

  @override
  String get vaultFileTooLarge =>
      'El archivo es demasiado grande: 64 MB como máximo.';

  @override
  String vaultFileSealed(String name) {
    return '$name se cifró y se añadió a la bóveda.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name se cifró y se añadió a la bóveda. Datos ocultos eliminados: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name se cifró y se añadió a la bóveda. Kilit no puede eliminar datos ocultos (como el autor) de este tipo de archivo; revísalo antes de compartirlo.';
  }

  @override
  String get damagedPictureTitle => 'Imagen dañada';

  @override
  String get damagedPictureBody =>
      'Esta imagen está dañada, así que Kilit no pudo eliminar sus datos ocultos, como el lugar donde se tomó. ¿Añadirla tal como está?';

  @override
  String get damagedPictureSeal => 'Añadir tal cual';

  @override
  String get hiddenLocation => 'ubicación';

  @override
  String get hiddenCamera => 'datos de la cámara';

  @override
  String get hiddenAuthorNotes => 'autor y notas';

  @override
  String get hiddenExtraImages => 'imágenes adicionales';

  @override
  String get hiddenOther => 'otros metadatos';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'No hay ningún mensaje de Kilit en el portapapeles. En WhatsApp, mantén pulsado el mensaje y toca Copiar.';

  @override
  String get clipboardBanner => 'Hay un mensaje de Kilit en el portapapeles.';

  @override
  String get clipboardBannerOpen => 'Abrir';

  @override
  String get clipboardBannerDismiss => 'Ignorar';

  @override
  String get noteNew => 'Nueva nota';

  @override
  String get noteTitle => 'Título';

  @override
  String get noteText => 'Nota';

  @override
  String get sealAndSave => 'Cifrar y guardar';

  @override
  String get carrierTitle => 'Mensaje portador';

  @override
  String get carrierIntro =>
      'El mensaje se cifra y se convierte en texto para pegarlo en una app como WhatsApp.';

  @override
  String get carrierMessage => 'Mensaje';

  @override
  String get withPassphrase => 'Con una frase de contraseña compartida';

  @override
  String get carrierWithPassphraseHint =>
      'La otra persona lo abre con la misma frase de contraseña. Desactivado: solo tú puedes abrirlo.';

  @override
  String get passphrase => 'Frase de contraseña compartida';

  @override
  String get carrierPassphraseHelper =>
      'Al menos 12 caracteres. No la envíes por el mismo canal que el mensaje.';

  @override
  String get carrierSeal => 'Cifrar';

  @override
  String get carrierResultIntro =>
      'Copia y envía este texto. El canal solo ve datos cifrados.';

  @override
  String carrierChars(int count) {
    return '$count caracteres';
  }

  @override
  String get pasteTitle => 'Abrir texto pegado';

  @override
  String get pasteInput => 'Texto que copiaste de un chat';

  @override
  String get pasteFromClipboard => 'Pegar desde el portapapeles';

  @override
  String get passphraseIfAny => 'Frase de contraseña compartida (si la hay)';

  @override
  String get pasteOpen => 'Buscar y abrir';

  @override
  String get pasteNone => 'No se encontró ningún paquete KLT1 en el texto.';

  @override
  String get pasteTruncated =>
      'Un paquete quedó cortado: puede que la app de envío haya acortado el mensaje.';

  @override
  String get pasteMalformed => 'Un paquete está dañado.';

  @override
  String get openWrongKey =>
      'Este paquete no se abre con esta frase de contraseña o clave.';

  @override
  String get openDamaged => 'Este paquete está dañado o fue modificado.';

  @override
  String get openIsFile =>
      'Este paquete contiene un archivo; añádelo a la bóveda con Abrir .klt.';

  @override
  String get packetTitle => 'Análisis del paquete';

  @override
  String get packetFile => 'Archivo';

  @override
  String get packetType => 'Tipo';

  @override
  String get packetSize => 'Tamaño';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (paquete $packet)';
  }

  @override
  String get packetFormat => 'Formato';

  @override
  String get packetFormatValue => 'KLT1 (basado en age v1)';

  @override
  String get packetRecipients => 'Destinatarios';

  @override
  String get packetContent => 'Contenido';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, bloques de 64 KiB';

  @override
  String get packetSignature => 'Firma';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, verificada';

  @override
  String get sigUnsigned => 'Sin firmar';

  @override
  String get sigInvalid => 'NO VÁLIDA';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase =>
      'klt-argon2id (frase de contraseña compartida)';

  @override
  String get itemOpen => 'Abrir';

  @override
  String get itemView => 'Ver';

  @override
  String get itemExport => 'Exportar como .klt';

  @override
  String get itemSavePlain => 'Guardar sin cifrar';

  @override
  String get savePlainTitle => '¿Guardar sin cifrar?';

  @override
  String get savePlainBody =>
      'El archivo se guarda descifrado. Cualquiera con acceso al lugar donde lo guardes puede leerlo; Kilit ya no puede protegerlo.';

  @override
  String get itemDelete => 'Eliminar de la bóveda';

  @override
  String get exportTitle => 'Exportar como .klt';

  @override
  String get exportIntro =>
      'El archivo se vuelve a cifrar y tu bóveda lo firma. El nombre del archivo es aleatorio; el nombre real queda dentro del paquete cifrado.';

  @override
  String get exportWithPassphraseHint =>
      'Cualquiera con la frase de contraseña puede abrirlo. Desactivado: solo tu bóveda lo abre (para copias de seguridad).';

  @override
  String get exportPassphraseHelper =>
      'Al menos 12 caracteres. No la envíes por el mismo canal que el archivo.';

  @override
  String get passphraseTooShort =>
      'La frase de contraseña compartida debe tener al menos 12 caracteres.';

  @override
  String get importTitle => 'Abrir un archivo .klt';

  @override
  String get importPassphraseHelper =>
      'Déjalo vacío si se envió a tu propia bóveda.';

  @override
  String get importGo => 'Abrir y añadir a la bóveda';

  @override
  String importAddedSigned(String name) {
    return '$name se añadió a la bóveda (firmado).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name se añadió a la bóveda (sin firmar).';
  }

  @override
  String get importWrongKey =>
      'Este archivo no se abre con esta frase de contraseña ni con tu bóveda.';

  @override
  String get importNotKlt => 'Esto no es un archivo .klt.';

  @override
  String get importDamaged => 'El archivo está dañado o fue modificado.';

  @override
  String get settingsProtections => 'Tus protecciones';

  @override
  String get protPin => 'Protección con PIN';

  @override
  String get protScreenshots => 'Bloqueo de capturas de pantalla';

  @override
  String get protScreenshotsValue => 'Activado, en todas las pantallas';

  @override
  String get protAutoLock => 'Bloqueo automático';

  @override
  String get protAutoLockValue => 'Al salir de la app';

  @override
  String get protNetwork => 'Conexión Tor';

  @override
  String get protNetworkValue =>
      'Sin conexión: la fase 1 nunca se conecta a internet. Tor llega en la fase 2.';

  @override
  String get hwStrongbox => 'Chip de seguridad StrongBox';

  @override
  String get hwTee => 'Entorno de ejecución de confianza (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (sin hardware seguro)';

  @override
  String get hwSoftwareFile => 'Clave de software (junto a la bóveda)';

  @override
  String get hwNone => 'Ninguno';

  @override
  String get hwDev => 'Ninguno (núcleo de desarrollo)';

  @override
  String get hwBoundHint =>
      'Tu PIN está vinculado a la clave de hardware de este dispositivo. Ni siquiera una copia del archivo de la bóveda se puede probar en otro dispositivo.';

  @override
  String get hwNotBoundHint =>
      'Sin clave de hardware: si se copia el archivo de la bóveda, el PIN se puede adivinar en otro dispositivo.';

  @override
  String get settingsFingerprint => 'Tu número de seguridad';

  @override
  String get settingsFingerprintHint =>
      'Al verificar un contacto, debe ser el mismo en ambos dispositivos.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get clipboardCheck => 'Ofrecer el mensaje de Kilit del portapapeles';

  @override
  String get clipboardCheckHint =>
      'Al abrir la bóveda, ofrece abrir un mensaje KLT1: del portapapeles. Android muestra un aviso de que se leyó el portapapeles.';

  @override
  String get settingsPermissions => 'Permisos';

  @override
  String get permIntro => 'Kilit no usa ningún permiso sensible por ahora.';

  @override
  String get permCamera => 'Cámara';

  @override
  String get permCameraValue => 'Sin usar (la cámara llega en la fase 2)';

  @override
  String get permNotifications => 'Notificaciones';

  @override
  String get permNotificationsValue => 'Sin usar';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Ninguno: la fase 1 funciona sin conexión';

  @override
  String get permOpenSystem => 'Abrir los ajustes de permisos del sistema';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutLicense => 'Licencia';

  @override
  String get aboutAlpha =>
      'Sin auditoría independiente. Alfa: útil para pruebas, no para usos críticos.';
}
