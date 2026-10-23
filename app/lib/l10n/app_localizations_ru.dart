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
  String get chatsLater => 'Переписка через Tor появится на этапе 2.';

  @override
  String get cameraLater =>
      'Камера, которая никогда не пишет открытые данные на диск, появится на этапе 2.';

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
}
