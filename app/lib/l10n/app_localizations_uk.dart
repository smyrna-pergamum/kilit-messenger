// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class LUk extends L {
  LUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Скасувати';

  @override
  String get close => 'Закрити';

  @override
  String get copy => 'Копіювати';

  @override
  String get copied => 'Скопійовано';

  @override
  String get share => 'Поділитися';

  @override
  String get lockNow => 'Заблокувати';

  @override
  String get panicTooltip =>
      'Торкніться, щоб заблокувати; утримуйте для тривожного коду';

  @override
  String get panicNoCode => 'Спершу задайте тривожний код у налаштуваннях.';

  @override
  String get panicEnterTitle => 'Тривожний код';

  @override
  String get panicEnterHint => 'Введіть тривожний код, щоб стерти все в Kilit.';

  @override
  String get panicWrong => 'Це не тривожний код.';

  @override
  String get settingsPanic => 'Тривожний код';

  @override
  String get panicExplain =>
      'Чотири цифри. Якщо ввести його на екрані блокування замість PIN-коду або після утримання кнопки блокування, він назавжди стирає всі ключі, повідомлення й файли в Kilit, і Kilit починає все спочатку, як щойно встановлений.';

  @override
  String get panicStatusOn => 'Задано';

  @override
  String get panicStatusOff => 'Не задано';

  @override
  String get panicSet => 'Задати тривожний код';

  @override
  String get panicChange => 'Змінити тривожний код';

  @override
  String get panicRemove => 'Видалити тривожний код';

  @override
  String get panicCreateTitle => 'Виберіть тривожний код';

  @override
  String get panicCreateHint =>
      'Чотири цифри. Будь-хто, хто побачить, як ви його вводите, зможе стерти Kilit.';

  @override
  String get panicConfirmTitle => 'Повторіть тривожний код';

  @override
  String get panicMismatch => 'Коди не збіглися. Почніть спочатку.';

  @override
  String get panicSaved => 'Тривожний код задано.';

  @override
  String get panicRemoved => 'Тривожний код видалено.';

  @override
  String get panicRejected => 'Цей код використати не можна. Виберіть інший.';

  @override
  String get keptInVault => 'Збережено у сховищі.';

  @override
  String get alreadyInVault => 'Уже у сховищі.';

  @override
  String get keptTitleFallback => 'Повідомлення';

  @override
  String get devBanner => 'Ядро для розробки: справжнього шифрування немає.';

  @override
  String get lockTitleUnlock => 'Розблокування';

  @override
  String get lockTitleCreate => 'Придумай PIN';

  @override
  String get lockTitleConfirm => 'Введи PIN ще раз';

  @override
  String get lockHintUnlock => 'Введи PIN, щоб відкрити сховище.';

  @override
  String lockHintCreate(int min) {
    return 'Мінімум цифр: $min. Якщо забудеш PIN, сховище не відкрити: відновлення немає.';
  }

  @override
  String get lockHintConfirm => 'Введи той самий PIN ще раз.';

  @override
  String get lockMismatch => 'PIN-коди не збіглися. Почни знову.';

  @override
  String get lockWrongPin => 'Неправильний PIN.';

  @override
  String get settingsChangePin => 'Змінити PIN-код';

  @override
  String get changePinCurrent => 'Введіть поточний PIN-код';

  @override
  String get changePinNew => 'Виберіть новий PIN-код';

  @override
  String get changePinDone => 'PIN-код змінено.';

  @override
  String lockWait(int seconds) {
    return 'Зачекай $seconds с перед новою спробою.';
  }

  @override
  String pinDigitsEntered(int count) {
    return 'Введено цифр: $count';
  }

  @override
  String get pinDelete => 'Видалити';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Чати';

  @override
  String get navVault => 'Сховище';

  @override
  String get navCamera => 'Камера';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get chatsLater => 'Листування через Tor з\'явиться на етапі 2.';

  @override
  String get chatsIntro =>
      'Повідомлення наскрізно шифруються протоколом Signal (PQXDH і SPQR, постквантові). Поки Kilit не має власної мережі, вони передаються як текст, який ви копіюєте в будь-який месенджер.';

  @override
  String get chatsEmpty =>
      'Контактів поки немає. Дайте комусь свою картку або додайте чужу.';

  @override
  String get chatsShareCard => 'Моя картка';

  @override
  String get chatsAddContact => 'Додати контакт';

  @override
  String get chatsOpenClipboard => 'Відкрити з буфера обміну';

  @override
  String get chatsNothingOnClipboard =>
      'У буфері обміну немає повідомлення Kilit чи картки контакту.';

  @override
  String get cardTitle => 'Ваша картка контакту';

  @override
  String get cardName => 'Ім\'я для показу (необов\'язково)';

  @override
  String get cardShow => 'Створити картку';

  @override
  String get cardHint =>
      'Надішліть цей текст тому, з ким хочете спілкуватися. У ньому немає секретів. Після з\'єднання порівняйте коди безпеки.';

  @override
  String get addContactTitle => 'Додати контакт';

  @override
  String get addContactCard => 'Його картка контакту (KLC1:…)';

  @override
  String get addContactName => 'Ім\'я (необов\'язково)';

  @override
  String get addContactGo => 'Додати';

  @override
  String get addContactRefused => 'Це не картка контакту або це ваша власна.';

  @override
  String get contactUnnamed => 'Контакт без імені';

  @override
  String get chatEmpty =>
      'Повідомлень поки немає. Перше, яке ви напишете, почне зашифрований сеанс.';

  @override
  String get chatInput => 'Повідомлення';

  @override
  String get chatSend => 'Зашифрувати';

  @override
  String get chatPaste => 'Відкрити відповідь із буфера обміну';

  @override
  String get chatSealedTitle => 'Зашифроване повідомлення';

  @override
  String chatSealedHint(String name) {
    return 'Скопіюйте це в месенджер і надішліть контакту $name. Відкрити його зможе лише він.';
  }

  @override
  String get chatNewContact =>
      'Вам написав хтось, у кого є ваша картка. Дайте йому ім\'я та порівняйте коди безпеки, перш ніж довіряти.';

  @override
  String get chatOtherContact =>
      'Також відкрито повідомлення від іншого контакту; воно в листуванні з ним.';

  @override
  String get chatDuplicate => 'Це повідомлення вже відкривали.';

  @override
  String get chatUnknown => 'Це повідомлення не від того, з ким у вас є сеанс.';

  @override
  String get chatDamaged => 'Повідомлення пошкоджене.';

  @override
  String get safetyTitle => 'Код безпеки';

  @override
  String safetyHint(String name) {
    return 'Порівняйте ці 60 цифр із контактом $name особисто або телефоном. Якщо на обох телефонах вони однакові, посередині нікого немає.';
  }

  @override
  String get contactRename => 'Перейменувати';

  @override
  String get contactRemove => 'Видалити контакт';

  @override
  String get contactRemoveTitle => 'Видалити цей контакт?';

  @override
  String get contactRemoveBody =>
      'Сеанс і все листування буде видалено. Щоб знову писати одне одному, потрібні ваші картки.';

  @override
  String get contactRemoveGo => 'Видалити';

  @override
  String get save => 'Зберегти';

  @override
  String get cameraLater =>
      'Камера, яка ніколи не записує відкриті дані на диск, з\'явиться на етапі 2.';

  @override
  String get vaultAddNote => 'Додати нотатку';

  @override
  String get vaultCompose => 'Повідомлення-носій';

  @override
  String get vaultOpenClipboard => 'Відкрити з буфера обміну';

  @override
  String get vaultOpenPasted => 'Відкрити вставлений текст';

  @override
  String get vaultSealFile => 'Зашифрувати файл';

  @override
  String get vaultOpenKlt => 'Відкрити .klt';

  @override
  String get vaultEmpty =>
      'Сховище порожнє. Додай нотатку або зашифруй файл; усе зберігається як пакет .klt.';

  @override
  String get vaultSigned => 'Підписано';

  @override
  String get vaultFileTooLarge => 'Файл завеликий: максимум 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name: зашифровано й додано до сховища.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name: зашифровано й додано до сховища. Видалено приховані дані: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name: зашифровано й додано до сховища. Kilit не може видалити приховані дані (наприклад, автора) з файлів цього типу; перевірте файл, перш ніж ділитися ним.';
  }

  @override
  String get damagedPictureTitle => 'Пошкоджене зображення';

  @override
  String get damagedPictureBody =>
      'Зображення пошкоджене, тому Kilit не зміг видалити його приховані дані, як-от місце зйомки. Додати як є?';

  @override
  String get damagedPictureSeal => 'Додати як є';

  @override
  String get hiddenLocation => 'місцезнаходження';

  @override
  String get hiddenCamera => 'дані камери';

  @override
  String get hiddenAuthorNotes => 'автор і нотатки';

  @override
  String get hiddenExtraImages => 'додаткові зображення';

  @override
  String get hiddenOther => 'інші метадані';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'У буфері обміну немає повідомлення Kilit. У WhatsApp натисни й утримуй повідомлення, потім вибери «Копіювати».';

  @override
  String get clipboardBanner => 'У буфері обміну є повідомлення Kilit.';

  @override
  String get clipboardBannerOpen => 'Відкрити';

  @override
  String get clipboardBannerDismiss => 'Ігнорувати';

  @override
  String get noteNew => 'Нова нотатка';

  @override
  String get noteTitle => 'Заголовок';

  @override
  String get noteText => 'Нотатка';

  @override
  String get sealAndSave => 'Зашифрувати й зберегти';

  @override
  String get carrierTitle => 'Повідомлення-носій';

  @override
  String get carrierIntro =>
      'Повідомлення шифрується й перетворюється на текст, який можна вставити в застосунок на кшталт WhatsApp.';

  @override
  String get carrierMessage => 'Повідомлення';

  @override
  String get withPassphrase => 'Зі спільною парольною фразою';

  @override
  String get carrierWithPassphraseHint =>
      'Співрозмовник відкриє його тією самою фразою. Вимк.: відкрити зможеш лише ти.';

  @override
  String get passphrase => 'Спільна парольна фраза';

  @override
  String get carrierPassphraseHelper =>
      'Мінімум 12 символів. Не надсилай її тим самим каналом, що й повідомлення.';

  @override
  String get carrierSeal => 'Зашифрувати';

  @override
  String get carrierResultIntro =>
      'Скопіюй і надішли цей текст. Канал бачить лише зашифровані дані.';

  @override
  String carrierChars(int count) {
    return 'Символів: $count';
  }

  @override
  String get pasteTitle => 'Відкрити вставлений текст';

  @override
  String get pasteInput => 'Текст, скопійований із чату';

  @override
  String get pasteFromClipboard => 'Вставити з буфера обміну';

  @override
  String get passphraseIfAny => 'Спільна парольна фраза (якщо є)';

  @override
  String get pasteOpen => 'Знайти й відкрити';

  @override
  String get pasteNone => 'У тексті не знайдено пакета KLT1.';

  @override
  String get pasteTruncated =>
      'Пакет обрізано: застосунок-відправник міг скоротити повідомлення.';

  @override
  String get pasteMalformed => 'Пакет пошкоджено.';

  @override
  String get openWrongKey =>
      'Цей пакет не відкривається цією фразою чи ключем.';

  @override
  String get openDamaged => 'Цей пакет пошкоджено або змінено.';

  @override
  String get openIsFile =>
      'У цьому пакеті файл; додай його до сховища через «Відкрити .klt».';

  @override
  String get packetTitle => 'Аналіз пакета';

  @override
  String get packetFile => 'Файл';

  @override
  String get packetType => 'Тип';

  @override
  String get packetSize => 'Розмір';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (пакет $packet)';
  }

  @override
  String get packetFormat => 'Формат';

  @override
  String get packetFormatValue => 'KLT1 (на основі age v1)';

  @override
  String get packetRecipients => 'Одержувачі';

  @override
  String get packetContent => 'Вміст';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, блоки по 64 KiB';

  @override
  String get packetSignature => 'Підпис';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, перевірено';

  @override
  String get sigUnsigned => 'Без підпису';

  @override
  String get sigInvalid => 'НЕДІЙСНИЙ';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (спільна парольна фраза)';

  @override
  String get itemOpen => 'Відкрити';

  @override
  String get itemView => 'Переглянути';

  @override
  String get itemExport => 'Експорт у .klt';

  @override
  String get itemSavePlain => 'Зберегти без шифрування';

  @override
  String get savePlainTitle => 'Зберегти без шифрування?';

  @override
  String get savePlainBody =>
      'Файл буде збережено в розшифрованому вигляді. Його зможе прочитати будь-хто з доступом до місця збереження; Kilit більше не зможе його захистити.';

  @override
  String get itemDelete => 'Видалити зі сховища';

  @override
  String get exportTitle => 'Експорт у .klt';

  @override
  String get exportIntro =>
      'Файл знову шифрується й підписується твоїм сховищем. Ім\'я файлу випадкове; справжнє ім\'я лишається всередині зашифрованого пакета.';

  @override
  String get exportWithPassphraseHint =>
      'Відкрити зможе будь-хто, хто має фразу. Вимк.: відкриє лише твоє сховище (для резервних копій).';

  @override
  String get exportPassphraseHelper =>
      'Мінімум 12 символів. Не надсилай її тим самим каналом, що й файл.';

  @override
  String get passphraseTooShort =>
      'Спільна парольна фраза має містити щонайменше 12 символів.';

  @override
  String get importTitle => 'Відкрити файл .klt';

  @override
  String get importPassphraseHelper =>
      'Залиш порожнім, якщо файл надіслано до твого власного сховища.';

  @override
  String get importGo => 'Відкрити й додати до сховища';

  @override
  String importAddedSigned(String name) {
    return '$name: додано до сховища (з підписом).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name: додано до сховища (без підпису).';
  }

  @override
  String get importWrongKey =>
      'Цей файл не відкривається цією фразою чи твоїм сховищем.';

  @override
  String get importNotKlt => 'Це не файл .klt.';

  @override
  String get importDamaged => 'Файл пошкоджено або змінено.';

  @override
  String get settingsProtections => 'Твій захист';

  @override
  String get protPin => 'Захист PIN-кодом';

  @override
  String get protScreenshots => 'Заборона знімків екрана';

  @override
  String get protScreenshotsValue => 'Увімк., на всіх екранах';

  @override
  String get protAutoLock => 'Автоблокування';

  @override
  String get protAutoLockValue => 'Коли виходиш із застосунку';

  @override
  String get protNetwork => 'З\'єднання Tor';

  @override
  String get protNetworkValue =>
      'Не під\'єднано: на етапі 1 застосунок не виходить у мережу. Tor з\'явиться на етапі 2.';

  @override
  String get hwStrongbox => 'Захищений чип StrongBox';

  @override
  String get hwTee => 'Довірене середовище виконання (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (без захищеного обладнання)';

  @override
  String get hwSoftwareFile => 'Програмний ключ (поруч зі сховищем)';

  @override
  String get hwNone => 'Немає';

  @override
  String get hwDev => 'Немає (ядро для розробки)';

  @override
  String get hwBoundHint =>
      'Твій PIN прив\'язано до апаратного ключа цього пристрою. Навіть копію файлу сховища не можна перебирати на іншому пристрої.';

  @override
  String get hwNotBoundHint =>
      'Немає апаратного ключа: якщо файл сховища скопіюють, PIN можна підібрати на іншому пристрої.';

  @override
  String get settingsFingerprint => 'Твій код безпеки';

  @override
  String get settingsFingerprintHint =>
      'Під час перевірки контакту він має збігатися на обох пристроях.';

  @override
  String get settingsAppearance => 'Вигляд';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get languageSystem => 'Мова системи';

  @override
  String get settingsPrivacy => 'Конфіденційність';

  @override
  String get clipboardCheck =>
      'Пропонувати повідомлення Kilit із буфера обміну';

  @override
  String get clipboardCheckHint =>
      'Коли сховище відкривається, пропонує відкрити повідомлення KLT1: з буфера обміну. Android показує сповіщення, що буфер обміну прочитано.';

  @override
  String get settingsPermissions => 'Дозволи';

  @override
  String get permIntro =>
      'Зараз Kilit не використовує жодного чутливого дозволу.';

  @override
  String get permCamera => 'Камера';

  @override
  String get permCameraValue =>
      'Не використовується (камера з\'явиться на етапі 2)';

  @override
  String get permNotifications => 'Сповіщення';

  @override
  String get permNotificationsValue => 'Не використовуються';

  @override
  String get permInternet => 'Інтернет';

  @override
  String get permInternetValue => 'Немає: етап 1 працює офлайн';

  @override
  String get permOpenSystem => 'Відкрити системні налаштування дозволів';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String get aboutVersion => 'Версія';

  @override
  String get aboutLicense => 'Ліцензія';

  @override
  String get aboutAlpha =>
      'Незалежного аудиту не проводилося. Альфа-версія: підходить для тестів, але не для випадків із високими ставками.';
}
