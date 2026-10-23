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
  String get chatsLater => 'Nhắn tin qua Tor sẽ có ở giai đoạn 2.';

  @override
  String get cameraLater =>
      'Máy ảnh không bao giờ ghi dữ liệu chưa mã hóa ra bộ nhớ sẽ có ở giai đoạn 2.';

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
}
