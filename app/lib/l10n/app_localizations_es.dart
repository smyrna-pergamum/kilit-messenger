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
  String get panicTooltip =>
      'Toca para bloquear, mantén pulsado para el código de pánico';

  @override
  String get panicNoCode => 'Primero define un código de pánico en Ajustes.';

  @override
  String get panicEnterTitle => 'Código de pánico';

  @override
  String get panicEnterHint =>
      'Introduce el código de pánico para borrar todo lo que hay en Kilit.';

  @override
  String get panicWrong => 'Ese no es el código de pánico.';

  @override
  String get settingsPanic => 'Código de pánico';

  @override
  String get panicExplain =>
      'Cuatro dígitos. Si se introduce en la pantalla de bloqueo en lugar de tu PIN, o tras mantener pulsado el botón de bloqueo, borra para siempre todas las claves, mensajes y archivos de Kilit, y Kilit vuelve a empezar como recién instalado.';

  @override
  String get panicStatusOn => 'Definido';

  @override
  String get panicStatusOff => 'Sin definir';

  @override
  String get panicSet => 'Definir código de pánico';

  @override
  String get panicChange => 'Cambiar código de pánico';

  @override
  String get panicRemove => 'Quitar código de pánico';

  @override
  String get panicCreateTitle => 'Elige un código de pánico';

  @override
  String get panicCreateHint =>
      'Cuatro dígitos. Quien vea cómo lo introduces puede borrar Kilit.';

  @override
  String get panicConfirmTitle => 'Repite el código de pánico';

  @override
  String get panicMismatch => 'Los códigos no coinciden. Empieza de nuevo.';

  @override
  String get panicSaved => 'Código de pánico definido.';

  @override
  String get panicRemoved => 'Código de pánico quitado.';

  @override
  String get panicRejected => 'No se puede usar este código. Elige otro.';

  @override
  String get keptInVault => 'Guardado en la bóveda.';

  @override
  String get alreadyInVault => 'Ya está en la bóveda.';

  @override
  String get keptTitleFallback => 'Mensaje';

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
  String get settingsChangePin => 'Cambiar PIN';

  @override
  String get changePinCurrent => 'Introduce tu PIN actual';

  @override
  String get changePinNew => 'Elige un PIN nuevo';

  @override
  String get changePinDone => 'PIN cambiado.';

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
  String get chatEmpty =>
      'Aún no hay mensajes. El primero que escribas inicia la sesión cifrada.';

  @override
  String get chatInput => 'Mensaje';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatNewContact =>
      'Te escribió sin añadirte. Acepta para responder o bloquéalo. Comparad los números de seguridad antes de confiar.';

  @override
  String get safetyTitle => 'Número de seguridad';

  @override
  String safetyHint(String name) {
    return 'Compara estos 60 dígitos con $name, en persona o por teléfono. Si coinciden en ambos teléfonos, no hay nadie en medio.';
  }

  @override
  String get attachCamera => 'Cámara';

  @override
  String get attachFile => 'Foto o archivo';

  @override
  String get chatFileTooLarge =>
      'Demasiado grande para enviar: 5 MB como máximo.';

  @override
  String get chatDelivered => 'Entregado';

  @override
  String get fileComing => 'Recibiendo…';

  @override
  String get fileToVault => 'Añadir a la bóveda';

  @override
  String get fileSavedVault => 'Añadido a la bóveda.';

  @override
  String get timerTitle => 'Mensajes temporales';

  @override
  String get timerHint =>
      'Los mensajes nuevos de este chat desaparecen tras este tiempo, en ambos teléfonos.';

  @override
  String get timerOff => 'Desactivado';

  @override
  String get timer5m => '5 minutos';

  @override
  String get timer1h => '1 hora';

  @override
  String get timer1d => '1 día';

  @override
  String get timer1w => '1 semana';

  @override
  String get renewTitle => 'Renovar mi ID de Kilit';

  @override
  String get renewBody =>
      'Recibes palabras nuevas, un enlace nuevo y un código QR nuevo. Tus contactos siguen hablando contigo como antes; el ID y el enlace antiguos dejan de servir para alguien nuevo.';

  @override
  String get renewGo => 'Renovar';

  @override
  String renewDone(String id) {
    return 'Tu nuevo ID: @$id';
  }

  @override
  String get cameraNoCamera =>
      'No se pudo abrir la cámara. Revisa el permiso de cámara en los ajustes del teléfono.';

  @override
  String get cameraShutter => 'Hacer una foto';

  @override
  String get cameraRetake => 'Repetir';

  @override
  String get cameraUse => 'Usar';

  @override
  String get cameraIntro =>
      'Las fotos se toman solo en memoria: no se escribe nada en el teléfono y no llevan ubicación ni datos de la cámara.';

  @override
  String get cameraSendTo => 'Enviar a…';

  @override
  String get cameraToVault => 'Guardar en la bóveda';

  @override
  String get cameraSavedVault => 'Foto guardada en la bóveda.';

  @override
  String get cameraNoContacts => 'Aún no hay contactos a quien enviar.';

  @override
  String cameraSent(String name) {
    return 'Enviado a $name.';
  }

  @override
  String get chatsYourKilit => 'Tu Kilit';

  @override
  String get chatsSearch => 'Buscar';

  @override
  String get chatsEmptyNew =>
      'Aún no hay nadie. Añade a alguien o muéstrale tu código.';

  @override
  String get torChipReady => 'Tor listo';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress %';
  }

  @override
  String get torChipOff => 'Tor desactivado';

  @override
  String get addTitle => 'Añadir a alguien';

  @override
  String get addHint =>
      'Escanea su código o pega lo que te dio: un enlace o un @ID.';

  @override
  String get addScan => 'Escanear su código';

  @override
  String get addField => 'Un enlace de Kilit o un @ID';

  @override
  String get addGo => 'Añadir';

  @override
  String get addSearching => 'Buscando a través de Tor…';

  @override
  String get addNotFound =>
      'No se encontró a nadie con este ID. Revísalo o inténtalo de nuevo en un momento.';

  @override
  String get addOffline =>
      'Aún no hay conexión con Tor. Espera a que diga Tor listo.';

  @override
  String get addNotInvite => 'Eso no es un enlace de Kilit ni un @ID.';

  @override
  String get addShowMine => 'Mostrar mi código';

  @override
  String get addShowMineHint => 'Tu código QR, tu enlace, tu @ID';

  @override
  String get myTitle => 'Mi código';

  @override
  String get myHint =>
      'Quien tenga este código, tu enlace o tu @ID puede escribirte. Su primer mensaje espera en Solicitudes hasta que aceptes.';

  @override
  String get myCopyLink => 'Copiar enlace';

  @override
  String myShareText(String id, String link) {
    return 'Añádeme en Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'Escanear un código de Kilit';

  @override
  String get scanHint => 'Apunta la cámara al código QR.';

  @override
  String get requestsTitle => 'Solicitudes';

  @override
  String get requestsEmpty => 'No hay solicitudes.';

  @override
  String get requestHint =>
      'Te escribieron sin haberte añadido. No les llega nada hasta que aceptes y respondas.';

  @override
  String get requestAccept => 'Aceptar';

  @override
  String get requestDecline => 'Rechazar';

  @override
  String get requestBlock => 'Bloquear';

  @override
  String get chatOnRelay => 'En los relés';

  @override
  String get chatQueued => 'Esperando la red';

  @override
  String get contactRename => 'Renombrar';

  @override
  String get contactRemove => 'Eliminar contacto';

  @override
  String get contactRemoveTitle => '¿Eliminar este contacto?';

  @override
  String get contactRemoveBody =>
      'Se eliminan la sesión y toda la conversación. Para volver a escribiros, añadíos de nuevo.';

  @override
  String get contactRemoveGo => 'Eliminar';

  @override
  String get save => 'Guardar';

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
  String get torOff => 'Desactivado: Kilit no se conecta.';

  @override
  String torStarting(int progress) {
    return 'Conectando… $progress %';
  }

  @override
  String get torReady => 'Conectado a través de Tor.';

  @override
  String get torFailed => 'No se pudo conectar a Tor.';

  @override
  String get torUnavailable => 'Aún no disponible en este dispositivo.';

  @override
  String get torSwitch => 'Conectar mediante Tor';

  @override
  String get torSwitchHint =>
      'Kilit solo sale a la red a través de Tor. Desactivado, permanece sin conexión.';

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

  @override
  String get settingsBridges => 'Conexión a Tor';

  @override
  String get torRouteAuto => 'Automática';

  @override
  String get torRouteAutoHint =>
      'Directo a Tor; mediante puentes si está bloqueado.';

  @override
  String get torRouteDirect => 'Directo a Tor';

  @override
  String get torRouteObfs4 => 'Puentes obfs4';

  @override
  String get torRouteObfs4Hint => 'Para redes que bloquean Tor.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'Para censura fuerte. Más lento.';

  @override
  String get torRouteCustom => 'Mis propios puentes';

  @override
  String get torRouteCustomHint =>
      'Líneas de puente de bridges.torproject.org o de alguien de confianza.';

  @override
  String get torRouteLinesHint => 'Una línea de puente por fila';
}
