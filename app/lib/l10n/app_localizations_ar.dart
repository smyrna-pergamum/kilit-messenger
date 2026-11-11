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
  String get panicTooltip => 'انقر للقفل، واضغط مطولًا لرمز الطوارئ';

  @override
  String get panicNoCode => 'عيّن رمز طوارئ من الإعدادات أولًا.';

  @override
  String get panicEnterTitle => 'رمز الطوارئ';

  @override
  String get panicEnterHint => 'أدخل رمز الطوارئ لمسح كل ما في Kilit.';

  @override
  String get panicWrong => 'هذا ليس رمز الطوارئ.';

  @override
  String get settingsPanic => 'رمز الطوارئ';

  @override
  String get panicExplain =>
      'أربعة أرقام. إذا أُدخل في شاشة القفل بدل رقم PIN، أو بعد الضغط مطولًا على زر القفل، يمسح نهائيًا كل المفاتيح والرسائل والملفات في Kilit، ويبدأ Kilit من جديد كأنه ثُبّت للتو.';

  @override
  String get panicStatusOn => 'مُعيَّن';

  @override
  String get panicStatusOff => 'غير مُعيَّن';

  @override
  String get panicSet => 'تعيين رمز الطوارئ';

  @override
  String get panicChange => 'تغيير رمز الطوارئ';

  @override
  String get panicRemove => 'إزالة رمز الطوارئ';

  @override
  String get panicCreateTitle => 'اختر رمز طوارئ';

  @override
  String get panicCreateHint =>
      'أربعة أرقام. أي شخص يراك تُدخله يمكنه مسح Kilit.';

  @override
  String get panicConfirmTitle => 'أعد إدخال رمز الطوارئ';

  @override
  String get panicMismatch => 'الرمزان غير متطابقين. ابدأ من جديد.';

  @override
  String get panicSaved => 'تم تعيين رمز الطوارئ.';

  @override
  String get panicRemoved => 'تمت إزالة رمز الطوارئ.';

  @override
  String get panicRejected => 'لا يمكن استخدام هذا الرمز. اختر رمزًا آخر.';

  @override
  String get keptInVault => 'حُفظت في الخزنة.';

  @override
  String get alreadyInVault => 'موجودة في الخزنة بالفعل.';

  @override
  String get keptTitleFallback => 'رسالة';

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
  String get settingsChangePin => 'تغيير رقم PIN';

  @override
  String get changePinCurrent => 'أدخل رقم PIN الحالي';

  @override
  String get changePinNew => 'اختر رقم PIN جديدًا';

  @override
  String get changePinDone => 'تم تغيير رقم PIN.';

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
  String get chatEmpty => 'لا رسائل بعد. أول رسالة تكتبها تبدأ الجلسة المشفرة.';

  @override
  String get chatInput => 'رسالة';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatNewContact =>
      'راسلك دون أن تضيفه. اقبل لتردّ، أو احظره. قارنا رقمي الأمان قبل أن تثق به.';

  @override
  String get safetyTitle => 'رقم الأمان';

  @override
  String safetyHint(String name) {
    return 'قارن هذه الأرقام الستين مع $name، وجهًا لوجه أو في مكالمة. إذا تطابقت على الجانبين فلا أحد بينكما.';
  }

  @override
  String get attachCamera => 'الكاميرا';

  @override
  String get attachFile => 'صورة أو ملف';

  @override
  String get chatFileTooLarge => 'أكبر من أن يُرسل: 5 ميغابايت كحد أقصى.';

  @override
  String get chatDelivered => 'تم التسليم';

  @override
  String get fileComing => 'جارٍ الاستلام…';

  @override
  String get fileToVault => 'إضافة إلى الخزنة';

  @override
  String get fileSavedVault => 'أُضيفت إلى الخزنة.';

  @override
  String get timerTitle => 'الرسائل المؤقتة';

  @override
  String get timerHint =>
      'تختفي الرسائل الجديدة في هذه المحادثة بعد هذه المدة، لدى كليكما.';

  @override
  String get timerOff => 'متوقفة';

  @override
  String get timer5m => '5 دقائق';

  @override
  String get timer1h => 'ساعة واحدة';

  @override
  String get timer1d => 'يوم واحد';

  @override
  String get timer1w => 'أسبوع واحد';

  @override
  String get renewTitle => 'تجديد معرّف Kilit الخاص بي';

  @override
  String get renewBody =>
      'تحصل على كلمات جديدة ورابط جديد ورمز QR جديد. تواصل جهات اتصالك الحديث معك كما من قبل؛ ويتوقف المعرّف والرابط القديمان عن العمل لأي شخص جديد.';

  @override
  String get renewGo => 'تجديد';

  @override
  String renewDone(String id) {
    return 'معرّفك الجديد: @$id';
  }

  @override
  String get cameraNoCamera =>
      'تعذّر فتح الكاميرا. اسمح لـ Kilit باستخدام الكاميرا من إعدادات الجهاز.';

  @override
  String get cameraShutter => 'التقاط صورة';

  @override
  String get cameraRetake => 'إعادة الالتقاط';

  @override
  String get cameraUse => 'استخدام';

  @override
  String get cameraIntro =>
      'تُلتقط الصور في الذاكرة فقط: لا يُكتب شيء على الجهاز، ولا تحمل موقعًا ولا بيانات كاميرا.';

  @override
  String get cameraSendTo => 'إرسال إلى…';

  @override
  String get cameraToVault => 'الاحتفاظ في الخزنة';

  @override
  String get cameraSavedVault => 'حُفظت الصورة في الخزنة.';

  @override
  String get cameraNoContacts => 'لا توجد جهات اتصال لإرسالها إليها بعد.';

  @override
  String cameraSent(String name) {
    return 'أُرسلت إلى $name.';
  }

  @override
  String get chatsYourKilit => 'Kilit الخاص بك';

  @override
  String get chatsSearch => 'بحث';

  @override
  String get chatsEmptyNew => 'لا أحد هنا بعد. أضف شخصًا، أو أرِه رمزك.';

  @override
  String get torChipReady => 'Tor جاهز';

  @override
  String torChipStarting(int progress) {
    return 'Tor ‏$progress٪';
  }

  @override
  String get torChipOff => 'Tor متوقف';

  @override
  String get addTitle => 'إضافة شخص';

  @override
  String get addHint => 'امسح رمزه، أو الصق ما أعطاك إياه: رابطًا أو @معرّفًا.';

  @override
  String get addScan => 'امسح رمزه';

  @override
  String get addField => 'رابط Kilit أو @معرّف';

  @override
  String get addGo => 'إضافة';

  @override
  String get addSearching => 'جارٍ البحث عبر Tor…';

  @override
  String get addNotFound =>
      'لم يُعثر على أحد بهذا المعرّف. تحقّق منه، أو أعد المحاولة بعد قليل.';

  @override
  String get addOffline =>
      'لم يتم الاتصال بـ Tor بعد. انتظر حتى تظهر عبارة Tor جاهز.';

  @override
  String get addNotInvite => 'هذا ليس رابط Kilit ولا @معرّفًا.';

  @override
  String get addShowMine => 'عرض رمزي';

  @override
  String get addShowMineHint => 'رمز QR ورابطك و@معرّفك';

  @override
  String get myTitle => 'رمزي';

  @override
  String get myHint =>
      'يمكن لأي شخص لديه هذا الرمز أو رابطك أو @معرّفك أن يراسلك. تنتظر رسالته الأولى في الطلبات حتى تقبل.';

  @override
  String get myCopyLink => 'نسخ الرابط';

  @override
  String myShareText(String id, String link) {
    return 'أضفني على Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'مسح رمز Kilit';

  @override
  String get scanHint => 'وجّه الكاميرا نحو رمز QR.';

  @override
  String get requestsTitle => 'الطلبات';

  @override
  String get requestsEmpty => 'لا توجد طلبات.';

  @override
  String get requestHint =>
      'راسلوك دون أن تتم إضافتهم. لن يصلهم شيء حتى تقبل وتردّ.';

  @override
  String get requestAccept => 'قبول';

  @override
  String get requestDecline => 'رفض';

  @override
  String get requestBlock => 'حظر';

  @override
  String get chatOnRelay => 'على المرحّلات';

  @override
  String get chatQueued => 'في انتظار الشبكة';

  @override
  String get contactRename => 'إعادة التسمية';

  @override
  String get contactRemove => 'حذف جهة الاتصال';

  @override
  String get contactRemoveTitle => 'هل تريد حذف جهة الاتصال هذه؟';

  @override
  String get contactRemoveBody =>
      'تُحذف الجلسة والمحادثة كلها. لتتراسلا من جديد، أضيفا بعضكما مرة أخرى.';

  @override
  String get contactRemoveGo => 'حذف';

  @override
  String get save => 'حفظ';

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
  String get torOff => 'متوقف: لا يتصل Kilit بالإنترنت.';

  @override
  String torStarting(int progress) {
    return 'جارٍ الاتصال… $progress٪';
  }

  @override
  String get torReady => 'متصل عبر Tor.';

  @override
  String get torFailed => 'تعذّر الاتصال بـ Tor.';

  @override
  String get torUnavailable => 'غير متاح على هذا الجهاز بعد.';

  @override
  String get torSwitch => 'الاتصال عبر Tor';

  @override
  String get torSwitchHint =>
      'لا يصل Kilit إلى الشبكة إلا عبر Tor. عند إيقافه يبقى دون اتصال.';

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
  String get settingsFingerprint => 'رقم توقيع خزنتك';

  @override
  String get settingsFingerprintHint =>
      'هذا الرقم يخص مفاتيح خزنتك التي توقّع الحِزم التي تختمها (وضع الناقل). من يتلقى منك حزمة موقّعة يرى رقم الموقّع فيها؛ فإن طابق هذا الرقم، ويمكنه التحقق منه معك وجهًا لوجه أو في مكالمة، فالحزمة منك. أما للمحادثات فقارن رقم الأمان داخل كل محادثة.';

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
  String get permIntro => 'لا يطلب Kilit إلا ما يحتاجه، وعند الحاجة فقط.';

  @override
  String get permCamera => 'الكاميرا';

  @override
  String get permCameraValue =>
      'لصور المحادثات. يُطلب عند فتح الكاميرا أول مرة؛ لا يُحفظ شيء في المعرض.';

  @override
  String get permNotifications => 'الإشعارات';

  @override
  String get permNotificationsValue =>
      'غير مستخدم: لا يظهر شيء عن رسائلك خارج التطبيق.';

  @override
  String get permInternet => 'الإنترنت';

  @override
  String get permInternetValue => 'لـ Tor المدمج فقط. كل اتصال يمر عبره.';

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

  @override
  String get settingsBridges => 'اتصال Tor';

  @override
  String get torRouteAuto => 'تلقائي';

  @override
  String get torRouteAutoHint => 'مباشرة إلى Tor؛ وعبر الجسور إذا كان محجوبًا.';

  @override
  String get torRouteDirect => 'مباشرة إلى Tor';

  @override
  String get torRouteObfs4 => 'جسور obfs4';

  @override
  String get torRouteObfs4Hint => 'للشبكات التي تحجب Tor.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'للرقابة الشديدة. أبطأ.';

  @override
  String get torRouteCustom => 'جسوري الخاصة';

  @override
  String get torRouteCustomHint =>
      'أسطر جسور من bridges.torproject.org أو من شخص تثق به.';

  @override
  String get torRouteLinesHint => 'سطر جسر واحد في كل صف';

  @override
  String get resend => 'إرسال مرة أخرى';

  @override
  String get resendHint =>
      'الرسالة لدى أحد المرحِّلات، لكن جهاز الطرف الآخر لم يُبلغ بوصولها بعد. يعيد Kilit إرسالها مرة يوميًا لمدة أسبوع حتى تصل.';

  @override
  String get resendDone => 'أُعيد الإرسال.';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String groupPick(int count) {
    return 'اختر حتى $count أشخاص';
  }

  @override
  String get groupCreate => 'إنشاء';

  @override
  String groupMembers(int count) {
    return '$count أشخاص';
  }

  @override
  String get groupInfo => 'معلومات المجموعة';

  @override
  String get groupAdmin => 'المشرف';

  @override
  String get groupYou => 'أنت';

  @override
  String get groupAddPeople => 'إضافة أشخاص';

  @override
  String get groupRemove => 'إزالة من المجموعة';

  @override
  String get groupRename => 'إعادة تسمية المجموعة';

  @override
  String get groupEnd => 'إنهاء المجموعة';

  @override
  String get groupEndConfirm =>
      'إنهاء المجموعة للجميع؟ لن يستطيع أحد الكتابة فيها بعد ذلك.';

  @override
  String get groupLeave => 'مغادرة المجموعة';

  @override
  String get groupLeaveConfirm =>
      'مغادرة هذه المجموعة؟ لن تصلك رسائلها بعد الآن.';

  @override
  String get groupDelete => 'حذف المجموعة';

  @override
  String get groupEnded => 'انتهت هذه المجموعة.';

  @override
  String get groupGone => 'لم تعد في هذه المجموعة.';

  @override
  String groupDeliveredTo(int n, int total) {
    return 'وصلت إلى $n من $total';
  }

  @override
  String get groupNoContacts =>
      'أضف جهات اتصال أولًا: تتكوّن المجموعة من أشخاص أضفتهم.';

  @override
  String groupFull(int max) {
    return 'تتسع المجموعة لـ $max شخصًا كحد أقصى.';
  }

  @override
  String groupNoticeCreated(String who) {
    return 'أنشأ المجموعة: $who';
  }

  @override
  String groupNoticeJoined(String who) {
    return 'أضافك $who';
  }

  @override
  String groupNoticeAdded(String who, String whom) {
    return 'أُضيف: $whom · بواسطة: $who';
  }

  @override
  String groupNoticeRemoved(String who, String whom) {
    return 'أُزيل: $whom · بواسطة: $who';
  }

  @override
  String groupNoticeLeft(String who) {
    return 'غادر: $who';
  }

  @override
  String groupNoticeRenamed(String who, String name) {
    return 'الاسم الجديد للمجموعة «$name» · $who';
  }

  @override
  String groupNoticeEnded(String who) {
    return 'أنهى المجموعة: $who';
  }

  @override
  String groupNoticeRemovedYou(String who) {
    return 'أزالك $who';
  }

  @override
  String get emojiButton => 'الرموز التعبيرية والملصقات';

  @override
  String get stickers => 'الملصقات';

  @override
  String get stickerLine => 'ملصق';

  @override
  String get devicesTitle => 'الأجهزة المرتبطة';

  @override
  String get devicesIntro =>
      'يمكن أن تكون هوية Kilit على 5 أجهزة كحد أقصى: هاتفك وأجهزة الكمبيوتر التي تربطها. لكل منها مفاتيحه، والرسائل تصل إليها كلها.';

  @override
  String get deviceThis => 'هذا الجهاز';

  @override
  String get devicePhone => 'الهاتف';

  @override
  String deviceNumber(int n) {
    return 'الجهاز $n';
  }

  @override
  String get deviceLink => 'ربط كمبيوتر';

  @override
  String get deviceRemove => 'إزالة';

  @override
  String get deviceRemoveConfirm =>
      'إزالة هذا الجهاز؟ لن تصله رسائلك بعد الآن. إن فُقد، جدّد هوية Kilit أيضًا.';

  @override
  String get linkToPhone => 'الربط بهاتفي';

  @override
  String get linkToPhoneHint =>
      'اجعل هذا الجهاز جهازًا لهوية Kilit على هاتفك. على الهاتف: الإعدادات، الأجهزة المرتبطة، ربط كمبيوتر. ثم امسح هذا الرمز.';

  @override
  String get linkOnlyNew => 'لا يمكن ربط إلا Kilit جديد بلا جهات اتصال بهاتف.';

  @override
  String get linkWaiting => 'في انتظار الجهاز الآخر. كلاهما يحتاج إلى Tor.';

  @override
  String get linkCompare => 'تحقق من أن الشاشة الأخرى تعرض الرمز نفسه:';

  @override
  String get linkDone => 'تم الربط. تصل الرسائل الآن إلى الجهازين.';

  @override
  String get linkNotCode => 'هذا ليس رمز ربط Kilit.';

  @override
  String get linkedToPhone => 'هذا الجهاز مرتبط بهوية Kilit على هاتفك.';

  @override
  String get torChipFailed => 'خطأ Tor';

  @override
  String get protScreenshotsOffHint =>
      'متوقف: يمكن التقاط صور الشاشة وتسجيلها لـ Kilit، ويظهر في التطبيقات الأخيرة.';

  @override
  String get torReconnect => 'إعادة اتصال Tor';

  @override
  String get torReconnectHint => 'دوائر جديدة، ويتصل Tor من جديد';

  @override
  String get torReconnecting => 'جارٍ إعادة اتصال Tor…';

  @override
  String get torRestartApp => 'أعد تشغيل Kilit';

  @override
  String get torRestartHint =>
      'توقف Tor داخل Kilit. لا يعيده إلا إعادة التشغيل؛ وستفتح القفل من جديد.';

  @override
  String get torDetailsTitle => 'اتصال Tor';

  @override
  String get torAnonTitle => 'عنوان IP الخاص بك مخفي';

  @override
  String get torAnonBody =>
      'لا يتصل Kilit بالشبكة إلا عبر Tor. لا أحد يرى عنوان IP الخاص بك، ولا يصل إليك إلا من يعرف معرّف Kilit الخاص بك.';

  @override
  String get torRouteTitle => 'الطريق الذي تسلكه رسائلك';

  @override
  String get torRouteYou => 'أنت';

  @override
  String get torRouteYouHint => 'يبقى عنوان IP الخاص بك هنا';

  @override
  String get torHopGuard => 'الحارس: يرى عنوان IP، لا ما ترسله';

  @override
  String get torHopMiddle => 'المرحّل الأوسط: لا يرى أيًّا منهما';

  @override
  String get torHopExit => 'المخرج: يرى مرحّل Kilit، ولا يراك أبدًا';

  @override
  String get torHopUnknown => 'مرحّل Tor';

  @override
  String get torRouteRelays => 'مرحّلات Kilit';

  @override
  String get torRouteRelaysHint =>
      'تحتفظ بالرسائل المختومة حتى يجلبها جهة اتصالك؛ ترى Tor لا أنت';

  @override
  String get torRouteLayers => 'ثلاث طبقات تشفير';

  @override
  String get torNotReadyDiagram =>
      'تظهر المرحّلات التي يستخدمها Tor عندما يصبح جاهزًا.';

  @override
  String get torLog => 'سجل Tor';

  @override
  String get torLogEmpty => 'لا شيء في السجل بعد.';

  @override
  String get torLogRefresh => 'تحديث';

  @override
  String get torLogCopied => 'نُسخ سجل Tor';

  @override
  String get torBlockedTitle => 'ربما يكون Tor محجوبًا هنا';

  @override
  String get torBlockedBody =>
      'لم يتمكن Kilit من الوصول إلى شبكة Tor. الجسر يخفي أنك تستخدم Tor. اختر طريقة:';

  @override
  String get torBlockedOwn => 'ألصق جسوري الخاصة';

  @override
  String get torBlockedOwnHint =>
      'احصل عليها من bridges.torproject.org أو بالبريد من bridges@torproject.org.';

  @override
  String get torBlockedLater => 'ليس الآن';

  @override
  String get selfNotes => 'ملاحظات لنفسي';

  @override
  String get selfNotesHint => 'مشفّرة في الخزنة، على هذا الجهاز فقط';

  @override
  String selfNotesCount(int count) {
    return 'الملاحظات: $count';
  }

  @override
  String get selfNoteNew => 'ملاحظة جديدة';

  @override
  String get selfNotesEmpty =>
      'لا ملاحظات بعد. ما تكتبه هنا يُختم في الخزنة ولا يُقرأ إلا بعد فتح القفل.';

  @override
  String get selfNoteDelete => 'حذف الملاحظة';

  @override
  String get selfNoteDeleteConfirm => 'حذف هذه الملاحظة؟ لا يمكن استعادتها.';

  @override
  String get selfNoteSaved => 'خُتمت الملاحظة';

  @override
  String get selfNoteUnsaved => 'المغادرة دون حفظ التغييرات؟';

  @override
  String get selfNoteDiscard => 'تجاهل';

  @override
  String get linkTorWait =>
      'Tor غير متصل بعد، لذا ينتظر الربط. يحتاج الجهازان إلى Tor.';

  @override
  String linkFailed(String error) {
    return 'لم يبدأ الربط: $error';
  }

  @override
  String get linkScanInDevices =>
      'هذا رمز لربط حاسوب. افتح على الهاتف الإعدادات، الأجهزة المرتبطة، ربط كمبيوتر، وامسحه هناك.';

  @override
  String get crashTitle => 'أُغلق Kilit بشكل غير متوقع';

  @override
  String get crashBody =>
      'أُغلق Kilit من تلقاء نفسه في المرة الماضية. لا يحوي التقرير أدناه رسائل ولا مفاتيح، بل مكان الخلل فقط. انسخه وأرسله إلى المطوّر، مثلًا في بلاغ على GitHub.';

  @override
  String get crashCopy => 'انسخ التقرير';

  @override
  String get linkFetchingKey => 'جارٍ جلب مفتاح الحاسوب من المرحّلات…';

  @override
  String get deviceLinkById => 'اربط حاسوبًا بمعرّف Kilit';

  @override
  String get linkById => 'بمعرّف Kilit';

  @override
  String get linkByQr => 'برمز QR';

  @override
  String get linkIdField => 'معرّف Kilit على هاتفك';

  @override
  String get linkIdHelp =>
      'اكتب معرّف Kilit الخاص بهاتفك. على الهاتف افتح الإعدادات، الأجهزة المرتبطة، اربط حاسوبًا بمعرّف Kilit: يعرض المعرّف وينتظر هذا الحاسوب.';

  @override
  String get linkIdSend => 'أرسل الطلب';

  @override
  String get linkIdSent =>
      'أُرسل الطلب. على الهاتف وافق على الطلب الذي يعرض هذا الرمز:';

  @override
  String get linkIdOrScan => 'أو امسح هذا الرمز بالهاتف من الشاشة نفسها:';

  @override
  String get linkListenHelp =>
      'على الحاسوب اختر اربط بهاتفي، بمعرّف Kilit، واكتب هذا المعرّف:';

  @override
  String get linkListenWaiting => 'بانتظار طلب الحاسوب…';

  @override
  String get linkListenScan => 'أو امسح رمز الحاسوب';

  @override
  String get linkRequestCode => 'حاسوب يطلب الربط. هل هذا هو الرمز على شاشته؟';

  @override
  String get linkRequestApprove => 'الرمز نفسه: اربطه';

  @override
  String get linkRequestOther => 'رمز مختلف؟ لا توافق: أرسل الطلبَ شخصٌ آخر.';

  @override
  String get deviceLeave => 'مغادرة معرّف Kilit هذا';

  @override
  String get deviceLeaveConfirm =>
      'سيغادر هذا الحاسوب معرّف Kilit الخاص بهاتفك. تُحذف المحادثات وجهات الاتصال والمجموعات من هذا الحاسوب؛ ويحتفظ الهاتف بها كلها. تبقى ملفات خزنتك وملاحظاتها هنا. يمكنك ربط هذا الحاسوب مجددًا لاحقًا.';

  @override
  String get deviceLeaveDone =>
      'غادر هذا الحاسوب معرّف Kilit. أصبح الآن Kilit جديدًا.';

  @override
  String get deviceLeftTitle => 'أُزيل من معرّف Kilit الخاص بهاتفك';

  @override
  String get deviceLeft =>
      'أزال هاتفك هذا الحاسوب من معرّف Kilit الخاص به. حُذفت المحادثات وجهات الاتصال والمجموعات من هذا الحاسوب؛ وبقيت ملفات خزنتك وملاحظاتها. لاستخدامه مجددًا، اربطه من الإعدادات، الأجهزة المرتبطة.';

  @override
  String get cameraOpenSettings => 'فتح إعدادات الكاميرا';

  @override
  String get cameraIntroDesktop =>
      'على Windows تسلّم الكاميرا كل صورة كملف: يقرؤه Kilit إلى الذاكرة فورًا، ثم يكتب فوق الملف ويحذفه. لا تحمل الصور موقعًا ولا بيانات كاميرا.';

  @override
  String get voiceRecord => 'تسجيل رسالة صوتية';

  @override
  String get voiceRecording => 'جارٍ التسجيل…';

  @override
  String get voiceStopped => 'توقف التسجيل';

  @override
  String get voiceLimitHint =>
      'يبقى الصوت في الذاكرة ويُرسل مشفّرًا. تتوقف الرسالة الصوتية عند 5 دقائق.';

  @override
  String get voiceNoMic =>
      'تعذّر فتح الميكروفون. اسمح لـ Kilit باستخدام الميكروفون من إعدادات الجهاز.';

  @override
  String get voiceOpenSettings => 'فتح إعدادات الميكروفون';

  @override
  String get voiceMessage => 'رسالة صوتية';

  @override
  String get voicePlay => 'تشغيل';

  @override
  String get voicePause => 'إيقاف مؤقت';

  @override
  String get voiceCannotPlay => 'تعذّر التشغيل';
}
