// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class LVi extends L {
  LVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Hủy';

  @override
  String get close => 'Đóng';

  @override
  String get copy => 'Sao chép';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get share => 'Chia sẻ';

  @override
  String get lockNow => 'Khóa ngay';

  @override
  String get panicTooltip => 'Chạm để khóa, giữ để nhập mã khẩn cấp';

  @override
  String get panicNoCode => 'Hãy đặt mã khẩn cấp trong Cài đặt trước.';

  @override
  String get panicEnterTitle => 'Mã khẩn cấp';

  @override
  String get panicEnterHint => 'Nhập mã khẩn cấp để xóa mọi thứ trong Kilit.';

  @override
  String get panicWrong => 'Đó không phải mã khẩn cấp.';

  @override
  String get settingsPanic => 'Mã khẩn cấp';

  @override
  String get panicExplain =>
      'Bốn chữ số. Nếu được nhập ở màn hình khóa thay cho mã PIN, hoặc sau khi giữ nút khóa, mã này xóa vĩnh viễn mọi khóa, tin nhắn và tệp trong Kilit, và Kilit bắt đầu lại như vừa được cài đặt.';

  @override
  String get panicStatusOn => 'Đã đặt';

  @override
  String get panicStatusOff => 'Chưa đặt';

  @override
  String get panicSet => 'Đặt mã khẩn cấp';

  @override
  String get panicChange => 'Đổi mã khẩn cấp';

  @override
  String get panicRemove => 'Gỡ mã khẩn cấp';

  @override
  String get panicCreateTitle => 'Chọn mã khẩn cấp';

  @override
  String get panicCreateHint =>
      'Bốn chữ số. Ai thấy bạn nhập mã này đều có thể xóa Kilit.';

  @override
  String get panicConfirmTitle => 'Nhập lại mã khẩn cấp';

  @override
  String get panicMismatch => 'Hai mã không khớp. Hãy bắt đầu lại.';

  @override
  String get panicSaved => 'Đã đặt mã khẩn cấp.';

  @override
  String get panicRemoved => 'Đã gỡ mã khẩn cấp.';

  @override
  String get panicRejected => 'Không thể dùng mã này. Hãy chọn mã khác.';

  @override
  String get keptInVault => 'Đã lưu vào kho.';

  @override
  String get alreadyInVault => 'Đã có trong kho.';

  @override
  String get keptTitleFallback => 'Tin nhắn';

  @override
  String get devBanner => 'Lõi phát triển: không mã hóa thật.';

  @override
  String get lockTitleUnlock => 'Mở khóa';

  @override
  String get lockTitleCreate => 'Chọn mã PIN';

  @override
  String get lockTitleConfirm => 'Nhập lại mã PIN';

  @override
  String get lockHintUnlock => 'Nhập mã PIN để mở kho.';

  @override
  String lockHintCreate(int min) {
    return 'Ít nhất $min chữ số. Nếu quên, kho sẽ không thể mở được: không có cách khôi phục.';
  }

  @override
  String get lockHintConfirm => 'Nhập lại cùng mã PIN một lần nữa.';

  @override
  String get lockMismatch => 'Mã PIN không khớp. Hãy bắt đầu lại.';

  @override
  String get lockWrongPin => 'Sai mã PIN.';

  @override
  String get settingsChangePin => 'Đổi mã PIN';

  @override
  String get changePinCurrent => 'Nhập mã PIN hiện tại';

  @override
  String get changePinNew => 'Chọn mã PIN mới';

  @override
  String get changePinDone => 'Đã đổi mã PIN.';

  @override
  String lockWait(int seconds) {
    return 'Chờ $seconds giây rồi thử lại.';
  }

  @override
  String pinDigitsEntered(int count) {
    return 'Đã nhập $count chữ số';
  }

  @override
  String get pinDelete => 'Xóa';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Trò chuyện';

  @override
  String get navVault => 'Kho';

  @override
  String get navCamera => 'Máy ảnh';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get chatEmpty =>
      'Chưa có tin nhắn. Tin đầu tiên bạn viết sẽ bắt đầu phiên mã hóa.';

  @override
  String get chatInput => 'Tin nhắn';

  @override
  String get chatSend => 'Gửi';

  @override
  String get chatNewContact =>
      'Đã nhắn cho bạn mà chưa được thêm. Chấp nhận để trả lời, hoặc chặn. Hãy so sánh số an toàn trước khi tin tưởng.';

  @override
  String get safetyTitle => 'Số an toàn';

  @override
  String safetyHint(String name) {
    return 'So sánh 60 chữ số này với $name, trực tiếp hoặc qua cuộc gọi. Nếu giống nhau trên cả hai điện thoại thì không có ai ở giữa.';
  }

  @override
  String get attachCamera => 'Máy ảnh';

  @override
  String get attachFile => 'Ảnh hoặc tệp';

  @override
  String get chatFileTooLarge => 'Quá lớn để gửi: tối đa 5 MB.';

  @override
  String get chatDelivered => 'Đã nhận';

  @override
  String get fileComing => 'Đang nhận…';

  @override
  String get fileToVault => 'Thêm vào kho';

  @override
  String get fileSavedVault => 'Đã thêm vào kho.';

  @override
  String get timerTitle => 'Tin nhắn tự hủy';

  @override
  String get timerHint =>
      'Tin nhắn mới trong cuộc trò chuyện này biến mất sau thời gian này, trên cả hai điện thoại.';

  @override
  String get timerOff => 'Tắt';

  @override
  String get timer5m => '5 phút';

  @override
  String get timer1h => '1 giờ';

  @override
  String get timer1d => '1 ngày';

  @override
  String get timer1w => '1 tuần';

  @override
  String get renewTitle => 'Làm mới ID Kilit của tôi';

  @override
  String get renewBody =>
      'Bạn nhận được từ mới, liên kết mới và mã QR mới. Danh bạ vẫn trò chuyện với bạn như trước; ID và liên kết cũ không còn dùng được cho người mới.';

  @override
  String get renewGo => 'Làm mới';

  @override
  String renewDone(String id) {
    return 'ID mới của bạn: @$id';
  }

  @override
  String get cameraNoCamera =>
      'Không mở được máy ảnh. Hãy kiểm tra quyền máy ảnh trong cài đặt điện thoại.';

  @override
  String get cameraShutter => 'Chụp ảnh';

  @override
  String get cameraRetake => 'Chụp lại';

  @override
  String get cameraUse => 'Dùng';

  @override
  String get cameraIntro =>
      'Ảnh chỉ được chụp trong bộ nhớ: không có gì được ghi vào điện thoại và ảnh không chứa vị trí hay dữ liệu máy ảnh.';

  @override
  String get cameraSendTo => 'Gửi cho…';

  @override
  String get cameraToVault => 'Giữ trong kho';

  @override
  String get cameraSavedVault => 'Đã giữ ảnh trong kho.';

  @override
  String get cameraNoContacts => 'Chưa có liên hệ nào để gửi.';

  @override
  String cameraSent(String name) {
    return 'Đã gửi cho $name.';
  }

  @override
  String get chatsYourKilit => 'Kilit của bạn';

  @override
  String get chatsSearch => 'Tìm';

  @override
  String get chatsEmptyNew =>
      'Chưa có ai. Hãy thêm ai đó, hoặc cho họ xem mã của bạn.';

  @override
  String get torChipReady => 'Tor sẵn sàng';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor tắt';

  @override
  String get addTitle => 'Thêm người';

  @override
  String get addHint =>
      'Quét mã của họ, hoặc dán thứ họ đưa cho bạn: một liên kết hoặc một @ID.';

  @override
  String get addScan => 'Quét mã của họ';

  @override
  String get addField => 'Liên kết Kilit hoặc @ID';

  @override
  String get addGo => 'Thêm';

  @override
  String get addSearching => 'Đang tìm qua Tor…';

  @override
  String get addNotFound =>
      'Không tìm thấy ai với ID này. Hãy kiểm tra lại hoặc thử lại sau ít phút.';

  @override
  String get addOffline =>
      'Chưa kết nối Tor. Hãy đợi đến khi hiện Tor sẵn sàng.';

  @override
  String get addNotInvite => 'Đó không phải liên kết Kilit hay @ID.';

  @override
  String get addShowMine => 'Hiện mã của tôi';

  @override
  String get addShowMineHint => 'Mã QR, liên kết và @ID của bạn';

  @override
  String get myTitle => 'Mã của tôi';

  @override
  String get myHint =>
      'Ai có mã này, liên kết hoặc @ID của bạn đều có thể nhắn cho bạn. Tin đầu tiên chờ trong Yêu cầu cho đến khi bạn chấp nhận.';

  @override
  String get myCopyLink => 'Sao chép liên kết';

  @override
  String myShareText(String id, String link) {
    return 'Thêm tôi trên Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'Quét mã Kilit';

  @override
  String get scanHint => 'Hướng camera vào mã QR.';

  @override
  String get requestsTitle => 'Yêu cầu';

  @override
  String get requestsEmpty => 'Không có yêu cầu.';

  @override
  String get requestHint =>
      'Họ nhắn cho bạn mà chưa được thêm. Không gì đến được với họ cho đến khi bạn chấp nhận và trả lời.';

  @override
  String get requestAccept => 'Chấp nhận';

  @override
  String get requestDecline => 'Từ chối';

  @override
  String get requestBlock => 'Chặn';

  @override
  String get chatOnRelay => 'Trên relay';

  @override
  String get chatQueued => 'Đang chờ mạng';

  @override
  String get contactRename => 'Đổi tên';

  @override
  String get contactRemove => 'Xóa liên hệ';

  @override
  String get contactRemoveTitle => 'Xóa liên hệ này?';

  @override
  String get contactRemoveBody =>
      'Phiên và toàn bộ cuộc trò chuyện sẽ bị xóa. Để nhắn lại, hãy thêm nhau lần nữa.';

  @override
  String get contactRemoveGo => 'Xóa';

  @override
  String get save => 'Lưu';

  @override
  String get vaultAddNote => 'Thêm ghi chú';

  @override
  String get vaultCompose => 'Tin nhắn mang';

  @override
  String get vaultOpenClipboard => 'Mở từ bộ nhớ tạm';

  @override
  String get vaultOpenPasted => 'Mở văn bản đã dán';

  @override
  String get vaultSealFile => 'Mã hóa tệp';

  @override
  String get vaultOpenKlt => 'Mở .klt';

  @override
  String get vaultEmpty =>
      'Kho của bạn trống. Hãy thêm ghi chú hoặc mã hóa một tệp; mọi thứ đều được lưu dưới dạng gói .klt.';

  @override
  String get vaultSigned => 'Đã ký';

  @override
  String get vaultFileTooLarge => 'Tệp quá lớn: tối đa 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name đã được mã hóa và thêm vào kho.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name đã được mã hóa và thêm vào kho. Dữ liệu ẩn đã xóa: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name đã được mã hóa và thêm vào kho. Kilit không thể xóa dữ liệu ẩn (như tên tác giả) khỏi loại tệp này; hãy kiểm tra trước khi chia sẻ.';
  }

  @override
  String get damagedPictureTitle => 'Ảnh bị hỏng';

  @override
  String get damagedPictureBody =>
      'Ảnh này bị hỏng nên Kilit không thể xóa dữ liệu ẩn của nó, chẳng hạn nơi chụp. Vẫn thêm nguyên trạng?';

  @override
  String get damagedPictureSeal => 'Thêm nguyên trạng';

  @override
  String get hiddenLocation => 'vị trí';

  @override
  String get hiddenCamera => 'thông tin máy ảnh';

  @override
  String get hiddenAuthorNotes => 'tác giả và ghi chú';

  @override
  String get hiddenExtraImages => 'ảnh phụ';

  @override
  String get hiddenOther => 'siêu dữ liệu khác';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Không có tin nhắn Kilit trong bộ nhớ tạm. Trong WhatsApp, nhấn giữ tin nhắn rồi chạm Sao chép.';

  @override
  String get clipboardBanner => 'Có một tin nhắn Kilit trong bộ nhớ tạm.';

  @override
  String get clipboardBannerOpen => 'Mở';

  @override
  String get clipboardBannerDismiss => 'Bỏ qua';

  @override
  String get noteNew => 'Ghi chú mới';

  @override
  String get noteTitle => 'Tiêu đề';

  @override
  String get noteText => 'Ghi chú';

  @override
  String get sealAndSave => 'Mã hóa và lưu';

  @override
  String get carrierTitle => 'Tin nhắn mang';

  @override
  String get carrierIntro =>
      'Tin nhắn được mã hóa và chuyển thành văn bản để dán vào ứng dụng như WhatsApp.';

  @override
  String get carrierMessage => 'Tin nhắn';

  @override
  String get withPassphrase => 'Dùng cụm mật khẩu chung';

  @override
  String get carrierWithPassphraseHint =>
      'Người nhận mở bằng cùng cụm mật khẩu. Tắt: chỉ bạn mở được.';

  @override
  String get passphrase => 'Cụm mật khẩu chung';

  @override
  String get carrierPassphraseHelper =>
      'Ít nhất 12 ký tự. Đừng gửi qua cùng kênh với tin nhắn.';

  @override
  String get carrierSeal => 'Mã hóa';

  @override
  String get carrierResultIntro =>
      'Sao chép và gửi văn bản này. Kênh truyền chỉ thấy dữ liệu đã mã hóa.';

  @override
  String carrierChars(int count) {
    return '$count ký tự';
  }

  @override
  String get pasteTitle => 'Mở văn bản đã dán';

  @override
  String get pasteInput => 'Văn bản bạn đã sao chép từ cuộc trò chuyện';

  @override
  String get pasteFromClipboard => 'Dán từ bộ nhớ tạm';

  @override
  String get passphraseIfAny => 'Cụm mật khẩu chung (nếu có)';

  @override
  String get pasteOpen => 'Tìm và mở';

  @override
  String get pasteNone => 'Không tìm thấy gói KLT1 nào trong văn bản.';

  @override
  String get pasteTruncated =>
      'Một gói bị cắt mất: ứng dụng gửi có thể đã rút ngắn tin nhắn.';

  @override
  String get pasteMalformed => 'Một gói bị hỏng.';

  @override
  String get openWrongKey =>
      'Gói này không mở được bằng cụm mật khẩu hoặc khóa này.';

  @override
  String get openDamaged => 'Gói này bị hỏng hoặc đã bị thay đổi.';

  @override
  String get openIsFile =>
      'Gói này chứa một tệp; hãy thêm vào kho bằng Mở .klt.';

  @override
  String get packetTitle => 'Phân tích gói';

  @override
  String get packetFile => 'Tệp';

  @override
  String get packetType => 'Loại';

  @override
  String get packetSize => 'Kích thước';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (gói $packet)';
  }

  @override
  String get packetFormat => 'Định dạng';

  @override
  String get packetFormatValue => 'KLT1 (xây dựng trên age v1)';

  @override
  String get packetRecipients => 'Người nhận';

  @override
  String get packetContent => 'Nội dung';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, khối 64 KiB';

  @override
  String get packetSignature => 'Chữ ký';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, đã xác minh';

  @override
  String get sigUnsigned => 'Chưa ký';

  @override
  String get sigInvalid => 'KHÔNG HỢP LỆ';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (cụm mật khẩu chung)';

  @override
  String get itemOpen => 'Mở';

  @override
  String get itemView => 'Xem';

  @override
  String get itemExport => 'Xuất dạng .klt';

  @override
  String get itemSavePlain => 'Lưu không mã hóa';

  @override
  String get savePlainTitle => 'Lưu không mã hóa?';

  @override
  String get savePlainBody =>
      'Tệp sẽ được lưu ở dạng đã giải mã. Bất kỳ ai truy cập được nơi bạn lưu đều có thể đọc nó; Kilit không thể bảo vệ nó nữa.';

  @override
  String get itemDelete => 'Xóa khỏi kho';

  @override
  String get exportTitle => 'Xuất dạng .klt';

  @override
  String get exportIntro =>
      'Tệp được mã hóa lại và ký bởi kho của bạn. Tên tệp là ngẫu nhiên; tên thật được giữ bên trong gói đã mã hóa.';

  @override
  String get exportWithPassphraseHint =>
      'Ai có cụm mật khẩu đều mở được. Tắt: chỉ kho của bạn mở được (để sao lưu).';

  @override
  String get exportPassphraseHelper =>
      'Ít nhất 12 ký tự. Đừng gửi qua cùng kênh với tệp.';

  @override
  String get passphraseTooShort =>
      'Cụm mật khẩu chung phải có ít nhất 12 ký tự.';

  @override
  String get importTitle => 'Mở tệp .klt';

  @override
  String get importPassphraseHelper =>
      'Để trống nếu tệp được gửi đến kho của chính bạn.';

  @override
  String get importGo => 'Mở và thêm vào kho';

  @override
  String importAddedSigned(String name) {
    return '$name đã được thêm vào kho (đã ký).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name đã được thêm vào kho (chưa ký).';
  }

  @override
  String get importWrongKey =>
      'Tệp này không mở được bằng cụm mật khẩu này hoặc kho của bạn.';

  @override
  String get importNotKlt => 'Đây không phải tệp .klt.';

  @override
  String get importDamaged => 'Tệp bị hỏng hoặc đã bị thay đổi.';

  @override
  String get settingsProtections => 'Các lớp bảo vệ của bạn';

  @override
  String get protPin => 'Bảo vệ bằng PIN';

  @override
  String get protScreenshots => 'Chặn chụp màn hình';

  @override
  String get protScreenshotsValue => 'Bật, trên mọi màn hình';

  @override
  String get protAutoLock => 'Tự động khóa';

  @override
  String get protAutoLockValue => 'Khi bạn rời ứng dụng';

  @override
  String get protNetwork => 'Kết nối Tor';

  @override
  String get protNetworkValue =>
      'Chưa kết nối: giai đoạn 1 không bao giờ lên mạng. Tor sẽ có ở giai đoạn 2.';

  @override
  String get torOff => 'Tắt: Kilit không lên mạng.';

  @override
  String torStarting(int progress) {
    return 'Đang kết nối… $progress%';
  }

  @override
  String get torReady => 'Đã kết nối qua Tor.';

  @override
  String get torFailed => 'Không thể kết nối Tor.';

  @override
  String get torUnavailable => 'Chưa có trên thiết bị này.';

  @override
  String get torSwitch => 'Kết nối qua Tor';

  @override
  String get torSwitchHint =>
      'Kilit chỉ ra mạng qua Tor. Khi tắt, ứng dụng ở chế độ ngoại tuyến.';

  @override
  String get hwStrongbox => 'Chip bảo mật StrongBox';

  @override
  String get hwTee => 'Môi trường thực thi tin cậy (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (không có phần cứng bảo mật)';

  @override
  String get hwSoftwareFile => 'Khóa phần mềm (đặt cạnh kho)';

  @override
  String get hwNone => 'Không có';

  @override
  String get hwDev => 'Không có (lõi phát triển)';

  @override
  String get hwBoundHint =>
      'Mã PIN của bạn được gắn với khóa phần cứng của thiết bị này. Ngay cả bản sao tệp kho cũng không thể thử trên thiết bị khác.';

  @override
  String get hwNotBoundHint =>
      'Không có khóa phần cứng: nếu tệp kho bị sao chép, mã PIN có thể bị đoán trên thiết bị khác.';

  @override
  String get settingsFingerprint => 'Mã an toàn của bạn';

  @override
  String get settingsFingerprintHint =>
      'Khi xác minh một liên hệ, mã này phải giống nhau trên cả hai thiết bị.';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Ngôn ngữ hệ thống';

  @override
  String get settingsPrivacy => 'Quyền riêng tư';

  @override
  String get clipboardCheck => 'Gợi ý tin nhắn Kilit trong bộ nhớ tạm';

  @override
  String get clipboardCheckHint =>
      'Khi kho mở, đề nghị mở tin nhắn KLT1: trong bộ nhớ tạm. Android sẽ hiện thông báo rằng bộ nhớ tạm đã được đọc.';

  @override
  String get settingsPermissions => 'Quyền';

  @override
  String get permIntro => 'Hiện tại Kilit không dùng quyền nhạy cảm nào.';

  @override
  String get permCamera => 'Máy ảnh';

  @override
  String get permCameraValue => 'Không dùng (máy ảnh sẽ có ở giai đoạn 2)';

  @override
  String get permNotifications => 'Thông báo';

  @override
  String get permNotificationsValue => 'Không dùng';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Không: giai đoạn 1 hoạt động ngoại tuyến';

  @override
  String get permOpenSystem => 'Mở cài đặt quyền của hệ thống';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutLicense => 'Giấy phép';

  @override
  String get aboutAlpha =>
      'Chưa được kiểm toán độc lập. Bản alpha: phù hợp để thử nghiệm, không dùng cho mục đích quan trọng.';

  @override
  String get settingsBridges => 'Kết nối Tor';

  @override
  String get torRouteAuto => 'Tự động';

  @override
  String get torRouteAutoHint => 'Thẳng tới Tor; qua cầu nối nếu bị chặn.';

  @override
  String get torRouteDirect => 'Thẳng tới Tor';

  @override
  String get torRouteObfs4 => 'Cầu nối obfs4';

  @override
  String get torRouteObfs4Hint => 'Cho mạng chặn Tor.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'Cho kiểm duyệt nặng. Chậm hơn.';

  @override
  String get torRouteCustom => 'Cầu nối của tôi';

  @override
  String get torRouteCustomHint =>
      'Dòng cầu nối từ bridges.torproject.org hoặc người bạn tin tưởng.';

  @override
  String get torRouteLinesHint => 'Mỗi hàng một dòng cầu nối';
}
