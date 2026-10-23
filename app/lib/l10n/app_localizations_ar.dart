// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get lockNow => 'قفل الآن';

  @override
  String get devBanner => 'نواة تطوير: لا يوجد تشفير حقيقي.';

  @override
  String get lockTitleUnlock => 'فتح القفل';

  @override
  String get lockTitleCreate => 'اختر رمز PIN';

  @override
  String get lockTitleConfirm => 'أدخل رمز PIN مرة أخرى';

  @override
  String get lockHintUnlock => 'أدخل رمز PIN لفتح خزنتك.';

  @override
  String lockHintCreate(int min) {
    return '$min أرقام على الأقل. إذا نسيته فلن يمكن فتح خزنتك: لا توجد طريقة للاسترداد.';
  }

  @override
  String get lockHintConfirm => 'أدخل رمز PIN نفسه مرة أخرى.';

  @override
  String get lockMismatch => 'رمزا PIN غير متطابقين. ابدأ من جديد.';

  @override
  String get lockWrongPin => 'رمز PIN خاطئ.';

  @override
  String lockWait(int seconds) {
    return 'انتظر $seconds ثانية قبل المحاولة مرة أخرى.';
  }

  @override
  String pinDigitsEntered(int count) {
    return 'تم إدخال $count أرقام';
  }

  @override
  String get pinDelete => 'حذف';

  @override
  String get pinOk => 'موافق';

  @override
  String get navChats => 'المحادثات';

  @override
  String get navVault => 'الخزنة';

  @override
  String get navCamera => 'الكاميرا';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get chatsLater => 'المراسلة عبر Tor تأتي في المرحلة 2.';

  @override
  String get cameraLater =>
      'كاميرا لا تكتب أي بيانات غير مشفرة على القرص تأتي في المرحلة 2.';

  @override
  String get vaultAddNote => 'إضافة ملاحظة';

  @override
  String get vaultCompose => 'رسالة حاملة';

  @override
  String get vaultOpenClipboard => 'فتح من الحافظة';

  @override
  String get vaultOpenPasted => 'فتح نص ملصوق';

  @override
  String get vaultSealFile => 'تشفير ملف';

  @override
  String get vaultOpenKlt => 'فتح .klt';

  @override
  String get vaultEmpty =>
      'خزنتك فارغة. أضف ملاحظة أو شفّر ملفًا؛ يُحفظ كل شيء كحزمة .klt.';

  @override
  String get vaultSigned => 'موقّع';

  @override
  String get vaultFileTooLarge => 'الملف كبير جدًا: الحد الأقصى 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return 'تم تشفير $name وإضافته إلى الخزنة.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return 'تم تشفير $name وإضافته إلى الخزنة. البيانات المخفية التي أُزيلت: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return 'تم تشفير $name وإضافته إلى الخزنة. لا يستطيع Kilit إزالة البيانات المخفية (مثل اسم المؤلف) من هذا النوع من الملفات؛ تحقّق منه قبل مشاركته.';
  }

  @override
  String get damagedPictureTitle => 'صورة تالفة';

  @override
  String get damagedPictureBody =>
      'هذه الصورة تالفة، لذا تعذّر على Kilit إزالة بياناتها المخفية، مثل مكان التقاطها. هل تريد إضافتها كما هي؟';

  @override
  String get damagedPictureSeal => 'إضافة كما هي';

  @override
  String get hiddenLocation => 'الموقع';

  @override
  String get hiddenCamera => 'بيانات الكاميرا';

  @override
  String get hiddenAuthorNotes => 'المؤلف والملاحظات';

  @override
  String get hiddenExtraImages => 'صور إضافية';

  @override
  String get hiddenOther => 'بيانات وصفية أخرى';

  @override
  String get hiddenListSeparator => '، ';

  @override
  String get clipboardEmpty =>
      'لا توجد رسالة Kilit في الحافظة. في WhatsApp، اضغط مطولًا على الرسالة ثم اختر نسخ.';

  @override
  String get clipboardBanner => 'توجد رسالة Kilit في الحافظة.';

  @override
  String get clipboardBannerOpen => 'فتح';

  @override
  String get clipboardBannerDismiss => 'تجاهل';

  @override
  String get noteNew => 'ملاحظة جديدة';

  @override
  String get noteTitle => 'العنوان';

  @override
  String get noteText => 'الملاحظة';

  @override
  String get sealAndSave => 'تشفير وحفظ';

  @override
  String get carrierTitle => 'رسالة حاملة';

  @override
  String get carrierIntro =>
      'تُشفَّر الرسالة وتتحول إلى نص للصقه في تطبيق مثل WhatsApp.';

  @override
  String get carrierMessage => 'الرسالة';

  @override
  String get withPassphrase => 'بعبارة مرور مشتركة';

  @override
  String get carrierWithPassphraseHint =>
      'يفتحها الطرف الآخر بعبارة المرور نفسها. عند الإيقاف: لا يفتحها أحد غيرك.';

  @override
  String get passphrase => 'عبارة المرور المشتركة';

  @override
  String get carrierPassphraseHelper =>
      '12 حرفًا على الأقل. لا ترسلها عبر القناة نفسها التي ترسل بها الرسالة.';

  @override
  String get carrierSeal => 'تشفير';

  @override
  String get carrierResultIntro =>
      'انسخ هذا النص وأرسله. لا ترى القناة سوى بيانات مشفرة.';

  @override
  String carrierChars(int count) {
    return '$count حرف';
  }

  @override
  String get pasteTitle => 'فتح نص ملصوق';

  @override
  String get pasteInput => 'نص نسخته من محادثة';

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String get passphraseIfAny => 'عبارة المرور المشتركة (إن وجدت)';

  @override
  String get pasteOpen => 'البحث والفتح';

  @override
  String get pasteNone => 'لم يُعثر على حزمة KLT1 في النص.';

  @override
  String get pasteTruncated =>
      'حزمة مقطوعة: ربما اختصر التطبيق المرسِل الرسالة.';

  @override
  String get pasteMalformed => 'إحدى الحزم تالفة.';

  @override
  String get openWrongKey =>
      'لا تُفتح هذه الحزمة بعبارة المرور أو المفتاح هذا.';

  @override
  String get openDamaged => 'هذه الحزمة تالفة أو تم تغييرها.';

  @override
  String get openIsFile =>
      'تحتوي هذه الحزمة على ملف؛ أضفه إلى الخزنة عبر فتح .klt.';

  @override
  String get packetTitle => 'تحليل الحزمة';

  @override
  String get packetFile => 'الملف';

  @override
  String get packetType => 'النوع';

  @override
  String get packetSize => 'الحجم';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (الحزمة $packet)';
  }

  @override
  String get packetFormat => 'الصيغة';

  @override
  String get packetFormatValue => 'KLT1 (مبنية على age v1)';

  @override
  String get packetRecipients => 'المستلمون';

  @override
  String get packetContent => 'المحتوى';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305، أجزاء بحجم 64 KiB';

  @override
  String get packetSignature => 'التوقيع';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65، تم التحقق';

  @override
  String get sigUnsigned => 'غير موقّع';

  @override
  String get sigInvalid => 'غير صالح';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (عبارة مرور مشتركة)';

  @override
  String get itemOpen => 'فتح';

  @override
  String get itemView => 'عرض';

  @override
  String get itemExport => 'تصدير كـ .klt';

  @override
  String get itemSavePlain => 'حفظ دون تشفير';

  @override
  String get savePlainTitle => 'الحفظ دون تشفير؟';

  @override
  String get savePlainBody =>
      'سيُحفظ الملف مفكوك التشفير. يمكن لأي شخص لديه وصول إلى مكان الحفظ قراءته؛ ولن يتمكن Kilit من حمايته بعد ذلك.';

  @override
  String get itemDelete => 'حذف من الخزنة';

  @override
  String get exportTitle => 'تصدير كـ .klt';

  @override
  String get exportIntro =>
      'يُشفَّر الملف من جديد وتوقّعه خزنتك. اسم الملف عشوائي؛ ويبقى الاسم الحقيقي داخل الحزمة المشفرة.';

  @override
  String get exportWithPassphraseHint =>
      'يمكن لأي شخص لديه عبارة المرور فتحه. عند الإيقاف: لا تفتحه إلا خزنتك (للنسخ الاحتياطية).';

  @override
  String get exportPassphraseHelper =>
      '12 حرفًا على الأقل. لا ترسلها عبر القناة نفسها التي ترسل بها الملف.';

  @override
  String get passphraseTooShort =>
      'يجب أن تتكون عبارة المرور المشتركة من 12 حرفًا على الأقل.';

  @override
  String get importTitle => 'فتح ملف .klt';

  @override
  String get importPassphraseHelper =>
      'اتركها فارغة إذا أُرسل الملف إلى خزنتك.';

  @override
  String get importGo => 'فتح وإضافة إلى الخزنة';

  @override
  String importAddedSigned(String name) {
    return 'تمت إضافة $name إلى الخزنة (موقّع).';
  }

  @override
  String importAddedUnsigned(String name) {
    return 'تمت إضافة $name إلى الخزنة (غير موقّع).';
  }

  @override
  String get importWrongKey =>
      'لا يُفتح هذا الملف بعبارة المرور هذه أو بخزنتك.';

  @override
  String get importNotKlt => 'هذا ليس ملف .klt.';

  @override
  String get importDamaged => 'الملف تالف أو تم تغييره.';

  @override
  String get settingsProtections => 'وسائل الحماية';

  @override
  String get protPin => 'الحماية برمز PIN';

  @override
  String get protScreenshots => 'منع لقطات الشاشة';

  @override
  String get protScreenshotsValue => 'مفعّل في كل الشاشات';

  @override
  String get protAutoLock => 'القفل التلقائي';

  @override
  String get protAutoLockValue => 'عند مغادرة التطبيق';

  @override
  String get protNetwork => 'اتصال Tor';

  @override
  String get protNetworkValue =>
      'غير متصل: لا تتصل المرحلة 1 بالإنترنت أبدًا. يأتي Tor في المرحلة 2.';

  @override
  String get hwStrongbox => 'شريحة الأمان StrongBox';

  @override
  String get hwTee => 'بيئة التنفيذ الموثوقة (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (بلا عتاد آمن)';

  @override
  String get hwSoftwareFile => 'مفتاح برمجي (بجوار الخزنة)';

  @override
  String get hwNone => 'لا يوجد';

  @override
  String get hwDev => 'لا يوجد (نواة تطوير)';

  @override
  String get hwBoundHint =>
      'رمز PIN مرتبط بمفتاح العتاد في هذا الجهاز. حتى نسخة من ملف الخزنة لا يمكن تجربتها على جهاز آخر.';

  @override
  String get hwNotBoundHint =>
      'لا يوجد مفتاح عتاد: إذا نُسخ ملف الخزنة، يمكن تخمين رمز PIN على جهاز آخر.';

  @override
  String get settingsFingerprint => 'رقم الأمان الخاص بك';

  @override
  String get settingsFingerprintHint =>
      'عند التحقق من جهة اتصال يجب أن يكون متطابقًا على الجهازين.';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get settingsPrivacy => 'الخصوصية';

  @override
  String get clipboardCheck => 'اقتراح رسالة Kilit الموجودة في الحافظة';

  @override
  String get clipboardCheckHint =>
      'عند فتح الخزنة، يقترح فتح رسالة KLT1: الموجودة في الحافظة. يعرض Android إشعارًا بأن الحافظة قُرئت.';

  @override
  String get settingsPermissions => 'الأذونات';

  @override
  String get permIntro => 'لا يستخدم Kilit أي إذن حساس حاليًا.';

  @override
  String get permCamera => 'الكاميرا';

  @override
  String get permCameraValue => 'غير مستخدم (الكاميرا تأتي في المرحلة 2)';

  @override
  String get permNotifications => 'الإشعارات';

  @override
  String get permNotificationsValue => 'غير مستخدم';

  @override
  String get permInternet => 'الإنترنت';

  @override
  String get permInternetValue => 'لا يوجد: تعمل المرحلة 1 دون اتصال';

  @override
  String get permOpenSystem => 'فتح إعدادات أذونات النظام';

  @override
  String get settingsAbout => 'حول';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutLicense => 'الترخيص';

  @override
  String get aboutAlpha =>
      'لم يخضع لتدقيق مستقل. إصدار ألفا: مناسب للتجربة، لا للاستخدام عالي المخاطر.';
}
