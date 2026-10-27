// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get share => 'Поделиться';

  @override
  String get lockNow => 'Заблокировать';

  @override
  String get panicTooltip =>
      'Нажмите, чтобы заблокировать; удерживайте для тревожного кода';

  @override
  String get panicNoCode => 'Сначала задайте тревожный код в настройках.';

  @override
  String get panicEnterTitle => 'Тревожный код';

  @override
  String get panicEnterHint =>
      'Введите тревожный код, чтобы стереть всё в Kilit.';

  @override
  String get panicWrong => 'Это не тревожный код.';

  @override
  String get settingsPanic => 'Тревожный код';

  @override
  String get panicExplain =>
      'Четыре цифры. Если ввести его на экране блокировки вместо PIN-кода или после удержания кнопки блокировки, он навсегда стирает все ключи, сообщения и файлы в Kilit, и Kilit начинает всё заново, как после установки.';

  @override
  String get panicStatusOn => 'Задан';

  @override
  String get panicStatusOff => 'Не задан';

  @override
  String get panicSet => 'Задать тревожный код';

  @override
  String get panicChange => 'Изменить тревожный код';

  @override
  String get panicRemove => 'Удалить тревожный код';

  @override
  String get panicCreateTitle => 'Выберите тревожный код';

  @override
  String get panicCreateHint =>
      'Четыре цифры. Любой, кто увидит, как вы его вводите, сможет стереть Kilit.';

  @override
  String get panicConfirmTitle => 'Повторите тревожный код';

  @override
  String get panicMismatch => 'Коды не совпали. Начните заново.';

  @override
  String get panicSaved => 'Тревожный код задан.';

  @override
  String get panicRemoved => 'Тревожный код удалён.';

  @override
  String get panicRejected => 'Этот код использовать нельзя. Выберите другой.';

  @override
  String get keptInVault => 'Сохранено в хранилище.';

  @override
  String get alreadyInVault => 'Уже в хранилище.';

  @override
  String get keptTitleFallback => 'Сообщение';

  @override
  String get devBanner => 'Ядро для разработки: настоящего шифрования нет.';

  @override
  String get lockTitleUnlock => 'Разблокировка';

  @override
  String get lockTitleCreate => 'Придумай PIN';

  @override
  String get lockTitleConfirm => 'Введи PIN ещё раз';

  @override
  String get lockHintUnlock => 'Введи PIN, чтобы открыть хранилище.';

  @override
  String lockHintCreate(int min) {
    return 'Минимум цифр: $min. Если забудешь PIN, хранилище не открыть: восстановления нет.';
  }

  @override
  String get lockHintConfirm => 'Введи тот же PIN ещё раз.';

  @override
  String get lockMismatch => 'PIN-коды не совпали. Начни заново.';

  @override
  String get lockWrongPin => 'Неверный PIN.';

  @override
  String get settingsChangePin => 'Изменить PIN-код';

  @override
  String get changePinCurrent => 'Введите текущий PIN-код';

  @override
  String get changePinNew => 'Выберите новый PIN-код';

  @override
  String get changePinDone => 'PIN-код изменён.';

  @override
  String lockWait(int seconds) {
    return 'Подожди $seconds с перед новой попыткой.';
  }

  @override
  String pinDigitsEntered(int count) {
    return 'Введено цифр: $count';
  }

  @override
  String get pinDelete => 'Удалить';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Чаты';

  @override
  String get navVault => 'Хранилище';

  @override
  String get navCamera => 'Камера';

  @override
  String get navSettings => 'Настройки';

  @override
  String get chatEmpty =>
      'Сообщений пока нет. Первое написанное вами сообщение начнёт зашифрованный сеанс.';

  @override
  String get chatInput => 'Сообщение';

  @override
  String get chatSend => 'Отправить';

  @override
  String get chatNewContact =>
      'Написал вам, не будучи добавленным. Примите, чтобы ответить, или заблокируйте. Сравните коды безопасности, прежде чем доверять.';

  @override
  String get safetyTitle => 'Код безопасности';

  @override
  String safetyHint(String name) {
    return 'Сравните эти 60 цифр с контактом $name лично или по телефону. Если на обоих телефонах они совпадают, посередине никого нет.';
  }

  @override
  String get attachCamera => 'Камера';

  @override
  String get attachFile => 'Фото или файл';

  @override
  String get chatFileTooLarge => 'Слишком большой файл: не более 5 МБ.';

  @override
  String get chatDelivered => 'Доставлено';

  @override
  String get fileComing => 'Получение…';

  @override
  String get fileToVault => 'Добавить в хранилище';

  @override
  String get fileSavedVault => 'Добавлено в хранилище.';

  @override
  String get timerTitle => 'Исчезающие сообщения';

  @override
  String get timerHint =>
      'Новые сообщения в этом чате исчезают через это время на обоих телефонах.';

  @override
  String get timerOff => 'Выкл.';

  @override
  String get timer5m => '5 минут';

  @override
  String get timer1h => '1 час';

  @override
  String get timer1d => '1 день';

  @override
  String get timer1w => '1 неделя';

  @override
  String get renewTitle => 'Обновить мой Kilit ID';

  @override
  String get renewBody =>
      'Вы получите новые слова, новую ссылку и новый QR-код. Ваши контакты продолжат писать вам как раньше; старые ID и ссылка перестанут работать для новых людей.';

  @override
  String get renewGo => 'Обновить';

  @override
  String renewDone(String id) {
    return 'Ваш новый ID: @$id';
  }

  @override
  String get cameraNoCamera =>
      'Не удалось открыть камеру. Проверьте разрешение камеры в настройках телефона.';

  @override
  String get cameraShutter => 'Сделать снимок';

  @override
  String get cameraRetake => 'Переснять';

  @override
  String get cameraUse => 'Использовать';

  @override
  String get cameraIntro =>
      'Снимки делаются только в памяти: на телефон ничего не записывается, и в них нет местоположения и данных камеры.';

  @override
  String get cameraSendTo => 'Отправить…';

  @override
  String get cameraToVault => 'Сохранить в хранилище';

  @override
  String get cameraSavedVault => 'Фото сохранено в хранилище.';

  @override
  String get cameraNoContacts => 'Пока некому отправить.';

  @override
  String cameraSent(String name) {
    return 'Отправлено: $name.';
  }

  @override
  String get chatsYourKilit => 'Ваш Kilit';

  @override
  String get chatsSearch => 'Поиск';

  @override
  String get chatsEmptyNew =>
      'Пока никого нет. Добавьте кого-нибудь или покажите свой код.';

  @override
  String get torChipReady => 'Tor готов';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor выключен';

  @override
  String get addTitle => 'Добавить контакт';

  @override
  String get addHint =>
      'Отсканируйте его код или вставьте то, что он дал: ссылку или @ID.';

  @override
  String get addScan => 'Сканировать его код';

  @override
  String get addField => 'Ссылка Kilit или @ID';

  @override
  String get addGo => 'Добавить';

  @override
  String get addSearching => 'Поиск через Tor…';

  @override
  String get addNotFound =>
      'Никто не найден по этому ID. Проверьте его или повторите чуть позже.';

  @override
  String get addOffline =>
      'Ещё нет подключения к Tor. Подождите, пока появится «Tor готов».';

  @override
  String get addNotInvite => 'Это не ссылка Kilit и не @ID.';

  @override
  String get addShowMine => 'Показать мой код';

  @override
  String get addShowMineHint => 'Ваш QR-код, ссылка и @ID';

  @override
  String get myTitle => 'Мой код';

  @override
  String get myHint =>
      'Любой, у кого есть этот код, ваша ссылка или @ID, может вам написать. Первое сообщение ждёт в «Запросах», пока вы не примете.';

  @override
  String get myCopyLink => 'Скопировать ссылку';

  @override
  String myShareText(String id, String link) {
    return 'Добавьте меня в Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'Сканировать код Kilit';

  @override
  String get scanHint => 'Наведите камеру на QR-код.';

  @override
  String get requestsTitle => 'Запросы';

  @override
  String get requestsEmpty => 'Запросов нет.';

  @override
  String get requestHint =>
      'Вам написали, не будучи добавленными. До них ничего не дойдёт, пока вы не примете и не ответите.';

  @override
  String get requestAccept => 'Принять';

  @override
  String get requestDecline => 'Отклонить';

  @override
  String get requestBlock => 'Заблокировать';

  @override
  String get chatOnRelay => 'На релеях';

  @override
  String get chatQueued => 'Ожидание сети';

  @override
  String get contactRename => 'Переименовать';

  @override
  String get contactRemove => 'Удалить контакт';

  @override
  String get contactRemoveTitle => 'Удалить этот контакт?';

  @override
  String get contactRemoveBody =>
      'Сеанс и вся переписка будут удалены. Чтобы снова писать друг другу, добавьтесь заново.';

  @override
  String get contactRemoveGo => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get vaultAddNote => 'Добавить заметку';

  @override
  String get vaultCompose => 'Сообщение-носитель';

  @override
  String get vaultOpenClipboard => 'Открыть из буфера обмена';

  @override
  String get vaultOpenPasted => 'Открыть вставленный текст';

  @override
  String get vaultSealFile => 'Зашифровать файл';

  @override
  String get vaultOpenKlt => 'Открыть .klt';

  @override
  String get vaultEmpty =>
      'Хранилище пусто. Добавь заметку или зашифруй файл; всё хранится в виде пакета .klt.';

  @override
  String get vaultSigned => 'Подписано';

  @override
  String get vaultFileTooLarge => 'Файл слишком большой: максимум 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name: зашифровано и добавлено в хранилище.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name: зашифровано и добавлено в хранилище. Удалены скрытые данные: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name: зашифровано и добавлено в хранилище. Kilit не может удалить скрытые данные (например, автора) из файлов этого типа; проверьте файл, прежде чем делиться им.';
  }

  @override
  String get damagedPictureTitle => 'Повреждённое изображение';

  @override
  String get damagedPictureBody =>
      'Изображение повреждено, поэтому Kilit не смог удалить его скрытые данные, например место съёмки. Добавить как есть?';

  @override
  String get damagedPictureSeal => 'Добавить как есть';

  @override
  String get hiddenLocation => 'местоположение';

  @override
  String get hiddenCamera => 'данные камеры';

  @override
  String get hiddenAuthorNotes => 'автор и заметки';

  @override
  String get hiddenExtraImages => 'дополнительные изображения';

  @override
  String get hiddenOther => 'прочие метаданные';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'В буфере обмена нет сообщения Kilit. В WhatsApp нажми и удерживай сообщение, затем выбери «Копировать».';

  @override
  String get clipboardBanner => 'В буфере обмена есть сообщение Kilit.';

  @override
  String get clipboardBannerOpen => 'Открыть';

  @override
  String get clipboardBannerDismiss => 'Игнорировать';

  @override
  String get noteNew => 'Новая заметка';

  @override
  String get noteTitle => 'Заголовок';

  @override
  String get noteText => 'Заметка';

  @override
  String get sealAndSave => 'Зашифровать и сохранить';

  @override
  String get carrierTitle => 'Сообщение-носитель';

  @override
  String get carrierIntro =>
      'Сообщение шифруется и превращается в текст, который можно вставить в приложение вроде WhatsApp.';

  @override
  String get carrierMessage => 'Сообщение';

  @override
  String get withPassphrase => 'С общей парольной фразой';

  @override
  String get carrierWithPassphraseHint =>
      'Собеседник откроет его той же фразой. Выкл.: открыть сможешь только ты.';

  @override
  String get passphrase => 'Общая парольная фраза';

  @override
  String get carrierPassphraseHelper =>
      'Минимум 12 символов. Не отправляй её по тому же каналу, что и сообщение.';

  @override
  String get carrierSeal => 'Зашифровать';

  @override
  String get carrierResultIntro =>
      'Скопируй и отправь этот текст. Канал видит только зашифрованные данные.';

  @override
  String carrierChars(int count) {
    return 'Символов: $count';
  }

  @override
  String get pasteTitle => 'Открыть вставленный текст';

  @override
  String get pasteInput => 'Текст, скопированный из чата';

  @override
  String get pasteFromClipboard => 'Вставить из буфера обмена';

  @override
  String get passphraseIfAny => 'Общая парольная фраза (если есть)';

  @override
  String get pasteOpen => 'Найти и открыть';

  @override
  String get pasteNone => 'В тексте не найден пакет KLT1.';

  @override
  String get pasteTruncated =>
      'Пакет обрезан: приложение-отправитель могло сократить сообщение.';

  @override
  String get pasteMalformed => 'Пакет повреждён.';

  @override
  String get openWrongKey =>
      'Этот пакет не открывается этой фразой или ключом.';

  @override
  String get openDamaged => 'Этот пакет повреждён или изменён.';

  @override
  String get openIsFile =>
      'В этом пакете файл; добавь его в хранилище через «Открыть .klt».';

  @override
  String get packetTitle => 'Анализ пакета';

  @override
  String get packetFile => 'Файл';

  @override
  String get packetType => 'Тип';

  @override
  String get packetSize => 'Размер';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (пакет $packet)';
  }

  @override
  String get packetFormat => 'Формат';

  @override
  String get packetFormatValue => 'KLT1 (на основе age v1)';

  @override
  String get packetRecipients => 'Получатели';

  @override
  String get packetContent => 'Содержимое';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, блоки по 64 KiB';

  @override
  String get packetSignature => 'Подпись';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, проверена';

  @override
  String get sigUnsigned => 'Без подписи';

  @override
  String get sigInvalid => 'НЕДЕЙСТВИТЕЛЬНА';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (общая парольная фраза)';

  @override
  String get itemOpen => 'Открыть';

  @override
  String get itemView => 'Просмотр';

  @override
  String get itemExport => 'Экспорт в .klt';

  @override
  String get itemSavePlain => 'Сохранить без шифрования';

  @override
  String get savePlainTitle => 'Сохранить без шифрования?';

  @override
  String get savePlainBody =>
      'Файл будет сохранён в расшифрованном виде. Его сможет прочитать любой, у кого есть доступ к месту сохранения; Kilit больше не сможет его защитить.';

  @override
  String get itemDelete => 'Удалить из хранилища';

  @override
  String get exportTitle => 'Экспорт в .klt';

  @override
  String get exportIntro =>
      'Файл снова шифруется и подписывается твоим хранилищем. Имя файла случайное; настоящее имя остаётся внутри зашифрованного пакета.';

  @override
  String get exportWithPassphraseHint =>
      'Открыть сможет любой, у кого есть фраза. Выкл.: откроет только твоё хранилище (для резервных копий).';

  @override
  String get exportPassphraseHelper =>
      'Минимум 12 символов. Не отправляй её по тому же каналу, что и файл.';

  @override
  String get passphraseTooShort =>
      'Общая парольная фраза должна быть не короче 12 символов.';

  @override
  String get importTitle => 'Открыть файл .klt';

  @override
  String get importPassphraseHelper =>
      'Оставь пустым, если файл отправлен в твоё собственное хранилище.';

  @override
  String get importGo => 'Открыть и добавить в хранилище';

  @override
  String importAddedSigned(String name) {
    return '$name: добавлено в хранилище (с подписью).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name: добавлено в хранилище (без подписи).';
  }

  @override
  String get importWrongKey =>
      'Этот файл не открывается этой фразой или твоим хранилищем.';

  @override
  String get importNotKlt => 'Это не файл .klt.';

  @override
  String get importDamaged => 'Файл повреждён или изменён.';

  @override
  String get settingsProtections => 'Твоя защита';

  @override
  String get protPin => 'Защита PIN-кодом';

  @override
  String get protScreenshots => 'Запрет скриншотов';

  @override
  String get protScreenshotsValue => 'Вкл., на всех экранах';

  @override
  String get protAutoLock => 'Автоблокировка';

  @override
  String get protAutoLockValue => 'При выходе из приложения';

  @override
  String get protNetwork => 'Подключение Tor';

  @override
  String get protNetworkValue =>
      'Нет подключения: на этапе 1 приложение не выходит в сеть. Tor появится на этапе 2.';

  @override
  String get torOff => 'Выключено: Kilit не выходит в сеть.';

  @override
  String torStarting(int progress) {
    return 'Подключение… $progress%';
  }

  @override
  String get torReady => 'Подключено через Tor.';

  @override
  String get torFailed => 'Не удалось подключиться к Tor.';

  @override
  String get torUnavailable => 'На этом устройстве пока недоступно.';

  @override
  String get torSwitch => 'Подключаться через Tor';

  @override
  String get torSwitchHint =>
      'Kilit выходит в сеть только через Tor. Если выключить, он остаётся офлайн.';

  @override
  String get hwStrongbox => 'Защищённый чип StrongBox';

  @override
  String get hwTee => 'Доверенная среда выполнения (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (без защищённого оборудования)';

  @override
  String get hwSoftwareFile => 'Программный ключ (рядом с хранилищем)';

  @override
  String get hwNone => 'Нет';

  @override
  String get hwDev => 'Нет (ядро для разработки)';

  @override
  String get hwBoundHint =>
      'Твой PIN привязан к аппаратному ключу этого устройства. Даже копию файла хранилища нельзя перебирать на другом устройстве.';

  @override
  String get hwNotBoundHint =>
      'Нет аппаратного ключа: если файл хранилища скопируют, PIN можно подобрать на другом устройстве.';

  @override
  String get settingsFingerprint => 'Твой код безопасности';

  @override
  String get settingsFingerprintHint =>
      'При проверке контакта он должен совпадать на обоих устройствах.';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Язык системы';

  @override
  String get settingsPrivacy => 'Конфиденциальность';

  @override
  String get clipboardCheck => 'Предлагать сообщение Kilit из буфера обмена';

  @override
  String get clipboardCheckHint =>
      'При открытии хранилища предлагает открыть сообщение KLT1: из буфера обмена. Android показывает уведомление о чтении буфера обмена.';

  @override
  String get settingsPermissions => 'Разрешения';

  @override
  String get permIntro =>
      'Сейчас Kilit не использует ни одного чувствительного разрешения.';

  @override
  String get permCamera => 'Камера';

  @override
  String get permCameraValue => 'Не используется (камера появится на этапе 2)';

  @override
  String get permNotifications => 'Уведомления';

  @override
  String get permNotificationsValue => 'Не используются';

  @override
  String get permInternet => 'Интернет';

  @override
  String get permInternetValue => 'Нет: этап 1 работает офлайн';

  @override
  String get permOpenSystem => 'Открыть системные настройки разрешений';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutLicense => 'Лицензия';

  @override
  String get aboutAlpha =>
      'Независимый аудит не проводился. Альфа-версия: подходит для тестов, но не для случаев с высокими ставками.';

  @override
  String get settingsBridges => 'Подключение к Tor';

  @override
  String get torRouteAuto => 'Автоматически';

  @override
  String get torRouteAutoHint =>
      'Напрямую к Tor; через мосты, если он заблокирован.';

  @override
  String get torRouteDirect => 'Напрямую к Tor';

  @override
  String get torRouteObfs4 => 'Мосты obfs4';

  @override
  String get torRouteObfs4Hint => 'Для сетей, где Tor заблокирован.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'При жёсткой цензуре. Медленнее.';

  @override
  String get torRouteCustom => 'Свои мосты';

  @override
  String get torRouteCustomHint =>
      'Строки мостов с bridges.torproject.org или от того, кому вы доверяете.';

  @override
  String get torRouteLinesHint => 'Одна строка моста на строку';
}
