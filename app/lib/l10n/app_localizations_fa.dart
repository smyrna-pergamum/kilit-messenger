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
  String get chatEmpty =>
      'هنوز پیامی نیست. نخستین پیامی که بنویسید نشست رمزگذاری‌شده را آغاز می‌کند.';

  @override
  String get chatInput => 'پیام';

  @override
  String get chatSend => 'ارسال';

  @override
  String get chatNewContact =>
      'بدون اینکه اضافه‌اش کرده باشی برایت نوشته. برای پاسخ بپذیر یا مسدودش کن. پیش از اعتماد، شماره‌های امنیتی را مقایسه کنید.';

  @override
  String get safetyTitle => 'شمارهٔ امنیتی';

  @override
  String safetyHint(String name) {
    return 'این ۶۰ رقم را با $name حضوری یا در تماس مقایسه کنید. اگر در هر دو گوشی یکسان باشد، کسی در میان نیست.';
  }

  @override
  String get attachCamera => 'دوربین';

  @override
  String get attachFile => 'عکس یا فایل';

  @override
  String get chatFileTooLarge =>
      'برای ارسال بیش از حد بزرگ است: حداکثر ۵ مگابایت.';

  @override
  String get chatDelivered => 'تحویل شد';

  @override
  String get fileComing => 'در حال دریافت…';

  @override
  String get fileToVault => 'افزودن به گاوصندوق';

  @override
  String get fileSavedVault => 'به گاوصندوق افزوده شد.';

  @override
  String get timerTitle => 'پیام‌های ناپدیدشونده';

  @override
  String get timerHint =>
      'پیام‌های تازهٔ این گفتگو پس از این زمان، در هر دو گوشی ناپدید می‌شوند.';

  @override
  String get timerOff => 'خاموش';

  @override
  String get timer5m => '۵ دقیقه';

  @override
  String get timer1h => '۱ ساعت';

  @override
  String get timer1d => '۱ روز';

  @override
  String get timer1w => '۱ هفته';

  @override
  String get renewTitle => 'تازه کردن شناسهٔ Kilit من';

  @override
  String get renewBody =>
      'واژه‌های تازه، پیوند تازه و کد QR تازه می‌گیری. مخاطبانت مثل قبل با تو گفتگو می‌کنند؛ شناسه و پیوند قدیمی برای افراد تازه دیگر کار نمی‌کند.';

  @override
  String get renewGo => 'تازه کردن';

  @override
  String renewDone(String id) {
    return 'شناسهٔ تازه‌ات: @$id';
  }

  @override
  String get cameraNoCamera =>
      'دوربین باز نشد. مجوز دوربین را در تنظیمات گوشی بررسی کن.';

  @override
  String get cameraShutter => 'گرفتن عکس';

  @override
  String get cameraRetake => 'گرفتن دوباره';

  @override
  String get cameraUse => 'استفاده';

  @override
  String get cameraIntro =>
      'عکس‌ها فقط در حافظه گرفته می‌شوند: چیزی روی گوشی نوشته نمی‌شود و اطلاعات مکان یا دوربین ندارند.';

  @override
  String get cameraSendTo => 'ارسال برای…';

  @override
  String get cameraToVault => 'نگه‌داری در گاوصندوق';

  @override
  String get cameraSavedVault => 'عکس در گاوصندوق نگه داشته شد.';

  @override
  String get cameraNoContacts => 'هنوز مخاطبی برای ارسال نیست.';

  @override
  String cameraSent(String name) {
    return 'برای $name ارسال شد.';
  }

  @override
  String get chatsYourKilit => 'Kilit تو';

  @override
  String get chatsSearch => 'جستجو';

  @override
  String get chatsEmptyNew =>
      'هنوز کسی اینجا نیست. کسی را اضافه کن یا کدت را به او نشان بده.';

  @override
  String get torChipReady => 'Tor آماده است';

  @override
  String torChipStarting(int progress) {
    return 'Tor ‏$progress٪';
  }

  @override
  String get torChipOff => 'Tor خاموش';

  @override
  String get addTitle => 'افزودن کسی';

  @override
  String get addHint =>
      'کدش را اسکن کن یا آنچه به تو داده را بچسبان: یک پیوند یا یک @شناسه.';

  @override
  String get addScan => 'اسکن کد او';

  @override
  String get addField => 'پیوند Kilit یا @شناسه';

  @override
  String get addGo => 'افزودن';

  @override
  String get addSearching => 'در حال جستجو از طریق Tor…';

  @override
  String get addNotFound =>
      'کسی با این شناسه پیدا نشد. بررسی کن یا کمی بعد دوباره امتحان کن.';

  @override
  String get addOffline =>
      'هنوز به Tor وصل نیست. صبر کن تا «Tor آماده است» نمایش داده شود.';

  @override
  String get addNotInvite => 'این پیوند Kilit یا @شناسه نیست.';

  @override
  String get addShowMine => 'نمایش کد من';

  @override
  String get addShowMineHint => 'کد QR، پیوند و @شناسهٔ تو';

  @override
  String get myTitle => 'کد من';

  @override
  String get myHint =>
      'هر کس این کد، پیوند یا @شناسهٔ تو را داشته باشد می‌تواند برایت بنویسد. نخستین پیامش تا وقتی بپذیری در درخواست‌ها می‌ماند.';

  @override
  String get myCopyLink => 'کپی پیوند';

  @override
  String myShareText(String id, String link) {
    return 'مرا در Kilit اضافه کن: @$id\n$link';
  }

  @override
  String get scanTitle => 'اسکن کد Kilit';

  @override
  String get scanHint => 'دوربین را به سمت کد QR بگیر.';

  @override
  String get requestsTitle => 'درخواست‌ها';

  @override
  String get requestsEmpty => 'درخواستی نیست.';

  @override
  String get requestHint =>
      'بدون اینکه اضافه شده باشند برایت نوشته‌اند. تا نپذیری و پاسخ ندهی چیزی به آن‌ها نمی‌رسد.';

  @override
  String get requestAccept => 'پذیرفتن';

  @override
  String get requestDecline => 'رد کردن';

  @override
  String get requestBlock => 'مسدود کردن';

  @override
  String get chatOnRelay => 'روی رله‌ها';

  @override
  String get chatQueued => 'در انتظار شبکه';

  @override
  String get contactRename => 'تغییر نام';

  @override
  String get contactRemove => 'حذف مخاطب';

  @override
  String get contactRemoveTitle => 'این مخاطب حذف شود؟';

  @override
  String get contactRemoveBody =>
      'نشست و کل گفتگو حذف می‌شود. برای نوشتن دوباره، یکدیگر را دوباره اضافه کنید.';

  @override
  String get contactRemoveGo => 'حذف';

  @override
  String get save => 'ذخیره';

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
  String get torOff => 'خاموش: Kilit آنلاین نمی‌شود.';

  @override
  String torStarting(int progress) {
    return 'در حال اتصال… $progress٪';
  }

  @override
  String get torReady => 'از طریق Tor وصل است.';

  @override
  String get torFailed => 'اتصال به Tor ممکن نشد.';

  @override
  String get torUnavailable => 'هنوز روی این دستگاه در دسترس نیست.';

  @override
  String get torSwitch => 'اتصال از طریق Tor';

  @override
  String get torSwitchHint =>
      'Kilit فقط از طریق Tor به شبکه می‌رود. خاموش که باشد، آفلاین می‌ماند.';

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
