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
    return 'قارن هذه الأرقام الستين مع $name، وجهًا لوجه أو في مكالمة. إذا تطابقت على الهاتفين فلا أحد بينكما.';
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
      'تختفي الرسائل الجديدة في هذه المحادثة بعد هذه المدة، على الهاتفين.';

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
      'تعذّر فتح الكاميرا. تحقّق من إذن الكاميرا في إعدادات الهاتف.';

  @override
  String get cameraShutter => 'التقاط صورة';

  @override
  String get cameraRetake => 'إعادة الالتقاط';

  @override
  String get cameraUse => 'استخدام';

  @override
  String get cameraIntro =>
      'تُلتقط الصور في الذاكرة فقط: لا يُكتب شيء على الهاتف، ولا تحمل موقعًا ولا بيانات كاميرا.';

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
