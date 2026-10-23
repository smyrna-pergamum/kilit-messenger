// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class LFa extends L {
  LFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'لغو';

  @override
  String get close => 'بستن';

  @override
  String get copy => 'کپی';

  @override
  String get copied => 'کپی شد';

  @override
  String get share => 'اشتراک‌گذاری';

  @override
  String get lockNow => 'قفل کن';

  @override
  String get panicTooltip =>
      'برای قفل کردن ضربه بزنید، برای کد اضطراری نگه دارید';

  @override
  String get panicNoCode => 'ابتدا در تنظیمات یک کد اضطراری تعیین کنید.';

  @override
  String get panicEnterTitle => 'کد اضطراری';

  @override
  String get panicEnterHint =>
      'برای پاک کردن همه چیز در Kilit کد اضطراری را وارد کنید.';

  @override
  String get panicWrong => 'این کد اضطراری نیست.';

  @override
  String get settingsPanic => 'کد اضطراری';

  @override
  String get panicExplain =>
      'چهار رقم. اگر در صفحهٔ قفل به جای PIN، یا پس از نگه داشتن دکمهٔ قفل وارد شود، همهٔ کلیدها، پیام‌ها و فایل‌های Kilit را برای همیشه پاک می‌کند و Kilit مثل تازه نصب‌شده از نو شروع می‌شود.';

  @override
  String get panicStatusOn => 'تعیین شده';

  @override
  String get panicStatusOff => 'تعیین نشده';

  @override
  String get panicSet => 'تعیین کد اضطراری';

  @override
  String get panicChange => 'تغییر کد اضطراری';

  @override
  String get panicRemove => 'حذف کد اضطراری';

  @override
  String get panicCreateTitle => 'یک کد اضطراری انتخاب کنید';

  @override
  String get panicCreateHint =>
      'چهار رقم. هر کسی که ببیند این کد را وارد می‌کنید می‌تواند Kilit را پاک کند.';

  @override
  String get panicConfirmTitle => 'کد اضطراری را دوباره وارد کنید';

  @override
  String get panicMismatch => 'کدها یکسان نبودند. از نو شروع کنید.';

  @override
  String get panicSaved => 'کد اضطراری تعیین شد.';

  @override
  String get panicRemoved => 'کد اضطراری حذف شد.';

  @override
  String get panicRejected => 'این کد قابل استفاده نیست. کد دیگری انتخاب کنید.';

  @override
  String get keptInVault => 'در گاوصندوق ذخیره شد.';

  @override
  String get alreadyInVault => 'از قبل در گاوصندوق است.';

  @override
  String get keptTitleFallback => 'پیام';

  @override
  String get devBanner => 'هسته توسعه: رمزگذاری واقعی ندارد.';

  @override
  String get lockTitleUnlock => 'باز کردن قفل';

  @override
  String get lockTitleCreate => 'یک PIN انتخاب کنید';

  @override
  String get lockTitleConfirm => 'PIN را دوباره وارد کنید';

  @override
  String get lockHintUnlock => 'برای باز کردن گاوصندوق، PIN خود را وارد کنید.';

  @override
  String lockHintCreate(int min) {
    return 'دست‌کم $min رقم. اگر آن را فراموش کنید گاوصندوق باز نمی‌شود: راه بازیابی وجود ندارد.';
  }

  @override
  String get lockHintConfirm => 'همان PIN را یک بار دیگر وارد کنید.';

  @override
  String get lockMismatch => 'PINها یکسان نبودند. از نو شروع کنید.';

  @override
  String get lockWrongPin => 'PIN اشتباه است.';

  @override
  String get settingsChangePin => 'تغییر PIN';

  @override
  String get changePinCurrent => 'PIN فعلی خود را وارد کنید';

  @override
  String get changePinNew => 'یک PIN تازه انتخاب کنید';

  @override
  String get changePinDone => 'PIN تغییر کرد.';

  @override
  String lockWait(int seconds) {
    return 'پیش از تلاش دوباره $seconds ثانیه صبر کنید.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count رقم وارد شد';
  }

  @override
  String get pinDelete => 'حذف';

  @override
  String get pinOk => 'تأیید';

  @override
  String get navChats => 'گفتگوها';

  @override
  String get navVault => 'گاوصندوق';

  @override
  String get navCamera => 'دوربین';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get chatsLater => 'پیام‌رسانی از طریق Tor در مرحله 2 می‌آید.';

  @override
  String get chatsIntro =>
      'پیام‌ها با پروتکل Signal ‏(PQXDH و SPQR، پساکوانتومی) سرتاسری رمزگذاری می‌شوند. تا وقتی شبکهٔ خود Kilit برسد، به‌صورت متنی منتقل می‌شوند که در هر برنامهٔ گفتگو کپی می‌کنید.';

  @override
  String get chatsEmpty =>
      'هنوز مخاطبی ندارید. کارت خود را به کسی بدهید یا کارت او را اضافه کنید.';

  @override
  String get chatsShareCard => 'کارت من';

  @override
  String get chatsAddContact => 'افزودن مخاطب';

  @override
  String get chatsOpenClipboard => 'باز کردن از کلیپ‌بورد';

  @override
  String get chatsNothingOnClipboard =>
      'در کلیپ‌بورد پیام Kilit یا کارت مخاطب نیست.';

  @override
  String get cardTitle => 'کارت مخاطب شما';

  @override
  String get cardName => 'نام نمایشی (اختیاری)';

  @override
  String get cardShow => 'ساخت کارت';

  @override
  String get cardHint =>
      'این متن را برای کسی بفرستید که می‌خواهید با او گفتگو کنید. هیچ رازی در آن نیست. پس از اتصال، شماره‌های امنیتی را مقایسه کنید.';

  @override
  String get addContactTitle => 'افزودن مخاطب';

  @override
  String get addContactCard => 'کارت مخاطب او (KLC1:…)';

  @override
  String get addContactName => 'نام (اختیاری)';

  @override
  String get addContactGo => 'افزودن';

  @override
  String get addContactRefused => 'این کارت مخاطب نیست، یا کارت خود شماست.';

  @override
  String get contactUnnamed => 'مخاطب بی‌نام';

  @override
  String get chatEmpty =>
      'هنوز پیامی نیست. نخستین پیامی که بنویسید نشست رمزگذاری‌شده را آغاز می‌کند.';

  @override
  String get chatInput => 'پیام';

  @override
  String get chatSend => 'رمزگذاری';

  @override
  String get chatPaste => 'باز کردن پاسخ از کلیپ‌بورد';

  @override
  String get chatSealedTitle => 'پیام رمزگذاری‌شده';

  @override
  String chatSealedHint(String name) {
    return 'این را در برنامهٔ گفتگو کپی کنید و برای $name بفرستید. فقط او می‌تواند بازش کند.';
  }

  @override
  String get chatNewContact =>
      'کسی که کارت شما را دارد برایتان نوشته است. نامی به او بدهید و پیش از اعتماد، شماره‌های امنیتی را مقایسه کنید.';

  @override
  String get chatOtherContact =>
      'پیامی از مخاطب دیگری هم باز شد؛ در گفتگوی با اوست.';

  @override
  String get chatDuplicate => 'این پیام پیش‌تر باز شده است.';

  @override
  String get chatUnknown => 'این پیام از کسی نیست که با او نشستی دارید.';

  @override
  String get chatDamaged => 'پیام آسیب دیده است.';

  @override
  String get safetyTitle => 'شمارهٔ امنیتی';

  @override
  String safetyHint(String name) {
    return 'این ۶۰ رقم را با $name حضوری یا در تماس مقایسه کنید. اگر در هر دو گوشی یکسان باشد، کسی در میان نیست.';
  }

  @override
  String get contactRename => 'تغییر نام';

  @override
  String get contactRemove => 'حذف مخاطب';

  @override
  String get contactRemoveTitle => 'این مخاطب حذف شود؟';

  @override
  String get contactRemoveBody =>
      'نشست و کل گفتگو حذف می‌شود. برای نوشتن دوباره به کارت‌های یکدیگر نیاز دارید.';

  @override
  String get contactRemoveGo => 'حذف';

  @override
  String get save => 'ذخیره';

  @override
  String get cameraLater =>
      'دوربینی که هرگز داده رمزنشده روی دیسک نمی‌نویسد در مرحله 2 می‌آید.';

  @override
  String get vaultAddNote => 'افزودن یادداشت';

  @override
  String get vaultCompose => 'پیام حامل';

  @override
  String get vaultOpenClipboard => 'باز کردن از کلیپ‌بورد';

  @override
  String get vaultOpenPasted => 'باز کردن متن چسبانده‌شده';

  @override
  String get vaultSealFile => 'رمزگذاری فایل';

  @override
  String get vaultOpenKlt => 'باز کردن .klt';

  @override
  String get vaultEmpty =>
      'گاوصندوق شما خالی است. یادداشتی اضافه کنید یا فایلی را رمزگذاری کنید؛ همه چیز به صورت بسته .klt نگهداری می‌شود.';

  @override
  String get vaultSigned => 'امضاشده';

  @override
  String get vaultFileTooLarge => 'فایل خیلی بزرگ است: حداکثر 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name رمزگذاری شد و به گاوصندوق افزوده شد.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name رمزگذاری شد و به گاوصندوق افزوده شد. داده‌های پنهانِ حذف‌شده: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name رمزگذاری شد و به گاوصندوق افزوده شد. Kilit نمی‌تواند داده‌های پنهان (مانند نام نویسنده) را از این نوع فایل حذف کند؛ پیش از هم‌رسانی آن را بررسی کنید.';
  }

  @override
  String get damagedPictureTitle => 'تصویر آسیب‌دیده';

  @override
  String get damagedPictureBody =>
      'این تصویر آسیب دیده است، بنابراین Kilit نتوانست داده‌های پنهان آن، مانند محل گرفتن عکس، را حذف کند. همان‌طور که هست افزوده شود؟';

  @override
  String get damagedPictureSeal => 'افزودن همان‌طور که هست';

  @override
  String get hiddenLocation => 'موقعیت مکانی';

  @override
  String get hiddenCamera => 'اطلاعات دوربین';

  @override
  String get hiddenAuthorNotes => 'نویسنده و یادداشت‌ها';

  @override
  String get hiddenExtraImages => 'تصاویر اضافی';

  @override
  String get hiddenOther => 'سایر فراداده‌ها';

  @override
  String get hiddenListSeparator => '، ';

  @override
  String get clipboardEmpty =>
      'پیام Kilit در کلیپ‌بورد نیست. در WhatsApp، پیام را لمس طولانی کنید و کپی را بزنید.';

  @override
  String get clipboardBanner => 'یک پیام Kilit در کلیپ‌بورد هست.';

  @override
  String get clipboardBannerOpen => 'باز کردن';

  @override
  String get clipboardBannerDismiss => 'نادیده گرفتن';

  @override
  String get noteNew => 'یادداشت جدید';

  @override
  String get noteTitle => 'عنوان';

  @override
  String get noteText => 'یادداشت';

  @override
  String get sealAndSave => 'رمزگذاری و ذخیره';

  @override
  String get carrierTitle => 'پیام حامل';

  @override
  String get carrierIntro =>
      'پیام رمزگذاری می‌شود و به متنی تبدیل می‌شود که می‌توانید در برنامه‌ای مثل WhatsApp بچسبانید.';

  @override
  String get carrierMessage => 'پیام';

  @override
  String get withPassphrase => 'با گذرواژه مشترک';

  @override
  String get carrierWithPassphraseHint =>
      'طرف مقابل آن را با همان گذرواژه باز می‌کند. خاموش: فقط خودتان می‌توانید بازش کنید.';

  @override
  String get passphrase => 'گذرواژه مشترک';

  @override
  String get carrierPassphraseHelper =>
      'دست‌کم 12 نویسه. آن را از همان کانالی که پیام را می‌فرستید نفرستید.';

  @override
  String get carrierSeal => 'رمزگذاری';

  @override
  String get carrierResultIntro =>
      'این متن را کپی کنید و بفرستید. کانال فقط داده رمزگذاری‌شده می‌بیند.';

  @override
  String carrierChars(int count) {
    return '$count نویسه';
  }

  @override
  String get pasteTitle => 'باز کردن متن چسبانده‌شده';

  @override
  String get pasteInput => 'متنی که از یک گفتگو کپی کرده‌اید';

  @override
  String get pasteFromClipboard => 'چسباندن از کلیپ‌بورد';

  @override
  String get passphraseIfAny => 'گذرواژه مشترک (در صورت وجود)';

  @override
  String get pasteOpen => 'یافتن و باز کردن';

  @override
  String get pasteNone => 'هیچ بسته KLT1 در متن پیدا نشد.';

  @override
  String get pasteTruncated =>
      'یک بسته ناقص است: شاید برنامه فرستنده پیام را کوتاه کرده باشد.';

  @override
  String get pasteMalformed => 'یک بسته آسیب دیده است.';

  @override
  String get openWrongKey => 'این بسته با این گذرواژه یا کلید باز نمی‌شود.';

  @override
  String get openDamaged => 'این بسته آسیب دیده یا تغییر کرده است.';

  @override
  String get openIsFile =>
      'این بسته حاوی یک فایل است؛ آن را با «باز کردن .klt» به گاوصندوق اضافه کنید.';

  @override
  String get packetTitle => 'تحلیل بسته';

  @override
  String get packetFile => 'فایل';

  @override
  String get packetType => 'نوع';

  @override
  String get packetSize => 'اندازه';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (بسته $packet)';
  }

  @override
  String get packetFormat => 'قالب';

  @override
  String get packetFormatValue => 'KLT1 (بر پایه age v1)';

  @override
  String get packetRecipients => 'گیرندگان';

  @override
  String get packetContent => 'محتوا';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305، تکه‌های 64 KiB';

  @override
  String get packetSignature => 'امضا';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65، تأییدشده';

  @override
  String get sigUnsigned => 'بدون امضا';

  @override
  String get sigInvalid => 'نامعتبر';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (گذرواژه مشترک)';

  @override
  String get itemOpen => 'باز کردن';

  @override
  String get itemView => 'نمایش';

  @override
  String get itemExport => 'صدور به صورت .klt';

  @override
  String get itemSavePlain => 'ذخیره بدون رمزگذاری';

  @override
  String get savePlainTitle => 'بدون رمزگذاری ذخیره شود؟';

  @override
  String get savePlainBody =>
      'فایل رمزگشایی‌شده ذخیره می‌شود. هر کسی که به محل ذخیره دسترسی داشته باشد می‌تواند آن را بخواند؛ Kilit دیگر نمی‌تواند از آن محافظت کند.';

  @override
  String get itemDelete => 'حذف از گاوصندوق';

  @override
  String get exportTitle => 'صدور به صورت .klt';

  @override
  String get exportIntro =>
      'فایل دوباره رمزگذاری و با گاوصندوق شما امضا می‌شود. نام فایل تصادفی است؛ نام واقعی درون بسته رمزگذاری‌شده می‌ماند.';

  @override
  String get exportWithPassphraseHint =>
      'هر کسی گذرواژه را داشته باشد می‌تواند بازش کند. خاموش: فقط گاوصندوق شما آن را باز می‌کند (برای پشتیبان‌گیری).';

  @override
  String get exportPassphraseHelper =>
      'دست‌کم 12 نویسه. آن را از همان کانالی که فایل را می‌فرستید نفرستید.';

  @override
  String get passphraseTooShort => 'گذرواژه مشترک باید دست‌کم 12 نویسه باشد.';

  @override
  String get importTitle => 'باز کردن فایل .klt';

  @override
  String get importPassphraseHelper =>
      'اگر برای گاوصندوق خودتان فرستاده شده، خالی بگذارید.';

  @override
  String get importGo => 'باز کردن و افزودن به گاوصندوق';

  @override
  String importAddedSigned(String name) {
    return '$name به گاوصندوق افزوده شد (امضاشده).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name به گاوصندوق افزوده شد (بدون امضا).';
  }

  @override
  String get importWrongKey =>
      'این فایل با این گذرواژه یا گاوصندوق شما باز نمی‌شود.';

  @override
  String get importNotKlt => 'این یک فایل .klt نیست.';

  @override
  String get importDamaged => 'فایل آسیب دیده یا تغییر کرده است.';

  @override
  String get settingsProtections => 'محافظت‌های شما';

  @override
  String get protPin => 'محافظت با PIN';

  @override
  String get protScreenshots => 'جلوگیری از اسکرین‌شات';

  @override
  String get protScreenshotsValue => 'روشن، در همه صفحه‌ها';

  @override
  String get protAutoLock => 'قفل خودکار';

  @override
  String get protAutoLockValue => 'هنگام خروج از برنامه';

  @override
  String get protNetwork => 'اتصال Tor';

  @override
  String get protNetworkValue =>
      'متصل نیست: مرحله 1 هرگز آنلاین نمی‌شود. Tor در مرحله 2 می‌آید.';

  @override
  String get hwStrongbox => 'تراشه امنیتی StrongBox';

  @override
  String get hwTee => 'محیط اجرای مورد اعتماد (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (بدون سخت‌افزار امن)';

  @override
  String get hwSoftwareFile => 'کلید نرم‌افزاری (کنار گاوصندوق)';

  @override
  String get hwNone => 'هیچ';

  @override
  String get hwDev => 'هیچ (هسته توسعه)';

  @override
  String get hwBoundHint =>
      'PIN شما به کلید سخت‌افزاری این دستگاه گره خورده است. حتی نسخه‌ای از فایل گاوصندوق را نمی‌توان روی دستگاه دیگری امتحان کرد.';

  @override
  String get hwNotBoundHint =>
      'کلید سخت‌افزاری وجود ندارد: اگر فایل گاوصندوق کپی شود، PIN را می‌توان روی دستگاه دیگری حدس زد.';

  @override
  String get settingsFingerprint => 'شماره امنیتی شما';

  @override
  String get settingsFingerprintHint =>
      'هنگام تأیید یک مخاطب، باید در هر دو دستگاه یکسان باشد.';

  @override
  String get settingsAppearance => 'ظاهر';

  @override
  String get themeSystem => 'سیستم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تیره';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get languageSystem => 'زبان سیستم';

  @override
  String get settingsPrivacy => 'حریم خصوصی';

  @override
  String get clipboardCheck => 'پیشنهاد پیام Kilit موجود در کلیپ‌بورد';

  @override
  String get clipboardCheckHint =>
      'هنگام باز شدن گاوصندوق، باز کردن پیام KLT1: موجود در کلیپ‌بورد را پیشنهاد می‌دهد. Android اعلانی نشان می‌دهد که کلیپ‌بورد خوانده شده است.';

  @override
  String get settingsPermissions => 'مجوزها';

  @override
  String get permIntro =>
      'Kilit در حال حاضر از هیچ مجوز حساسی استفاده نمی‌کند.';

  @override
  String get permCamera => 'دوربین';

  @override
  String get permCameraValue => 'استفاده نمی‌شود (دوربین در مرحله 2 می‌آید)';

  @override
  String get permNotifications => 'اعلان‌ها';

  @override
  String get permNotificationsValue => 'استفاده نمی‌شود';

  @override
  String get permInternet => 'اینترنت';

  @override
  String get permInternetValue => 'هیچ: مرحله 1 آفلاین کار می‌کند';

  @override
  String get permOpenSystem => 'باز کردن تنظیمات مجوزهای سیستم';

  @override
  String get settingsAbout => 'درباره';

  @override
  String get aboutVersion => 'نسخه';

  @override
  String get aboutLicense => 'مجوز';

  @override
  String get aboutAlpha =>
      'به طور مستقل ممیزی نشده است. نسخه آلفا: مناسب برای آزمایش، نه برای استفاده پرمخاطره.';
}
