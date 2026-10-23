// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LZh extends L {
  LZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get share => '分享';

  @override
  String get lockNow => '立即锁定';

  @override
  String get devBanner => '开发版核心：未进行真正的加密。';

  @override
  String get lockTitleUnlock => '解锁';

  @override
  String get lockTitleCreate => '设置 PIN';

  @override
  String get lockTitleConfirm => '再次输入 PIN';

  @override
  String get lockHintUnlock => '输入 PIN 以打开保险库。';

  @override
  String lockHintCreate(int min) {
    return '至少 $min 位数字。忘记后将无法打开保险库，且无法找回。';
  }

  @override
  String get lockHintConfirm => '请再次输入相同的 PIN。';

  @override
  String get lockMismatch => '两次输入的 PIN 不一致，请重新开始。';

  @override
  String get lockWrongPin => 'PIN 错误。';

  @override
  String lockWait(int seconds) {
    return '请等待 $seconds 秒后重试。';
  }

  @override
  String pinDigitsEntered(int count) {
    return '已输入 $count 位';
  }

  @override
  String get pinDelete => '删除';

  @override
  String get pinOk => '确定';

  @override
  String get navChats => '聊天';

  @override
  String get navVault => '保险库';

  @override
  String get navCamera => '相机';

  @override
  String get navSettings => '设置';

  @override
  String get chatsLater => '通过 Tor 收发消息将在第 2 阶段推出。';

  @override
  String get cameraLater => '从不将明文写入磁盘的相机将在第 2 阶段推出。';

  @override
  String get vaultAddNote => '添加笔记';

  @override
  String get vaultCompose => '载体消息';

  @override
  String get vaultOpenClipboard => '从剪贴板打开';

  @override
  String get vaultOpenPasted => '打开粘贴的文本';

  @override
  String get vaultSealFile => '加密文件';

  @override
  String get vaultOpenKlt => '打开 .klt';

  @override
  String get vaultEmpty => '保险库为空。添加笔记或加密文件；所有内容都以 .klt 数据包保存。';

  @override
  String get vaultSigned => '已签名';

  @override
  String get vaultFileTooLarge => '文件过大：最大 64 MB。';

  @override
  String vaultFileSealed(String name) {
    return '$name 已加密并添加到保险库。';
  }

  @override
  String get clipboardEmpty => '剪贴板中没有 Kilit 消息。在 WhatsApp 中长按消息并点按“复制”。';

  @override
  String get clipboardBanner => '剪贴板中有一条 Kilit 消息。';

  @override
  String get clipboardBannerOpen => '打开';

  @override
  String get clipboardBannerDismiss => '忽略';

  @override
  String get noteNew => '新建笔记';

  @override
  String get noteTitle => '标题';

  @override
  String get noteText => '笔记';

  @override
  String get sealAndSave => '加密并保存';

  @override
  String get carrierTitle => '载体消息';

  @override
  String get carrierIntro => '消息会被加密并转换为文本，可粘贴到 WhatsApp 等应用中。';

  @override
  String get carrierMessage => '消息';

  @override
  String get withPassphrase => '使用共享口令';

  @override
  String get carrierWithPassphraseHint => '对方使用相同的口令打开。关闭时：只有你能打开。';

  @override
  String get passphrase => '共享口令';

  @override
  String get carrierPassphraseHelper => '至少 12 个字符。不要通过发送消息的同一渠道发送口令。';

  @override
  String get carrierSeal => '加密';

  @override
  String get carrierResultIntro => '复制并发送此文本。渠道只能看到加密数据。';

  @override
  String carrierChars(int count) {
    return '$count 个字符';
  }

  @override
  String get pasteTitle => '打开粘贴的文本';

  @override
  String get pasteInput => '从聊天中复制的文本';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get passphraseIfAny => '共享口令（如有）';

  @override
  String get pasteOpen => '查找并打开';

  @override
  String get pasteNone => '文本中未找到 KLT1 数据包。';

  @override
  String get pasteTruncated => '数据包不完整：发送应用可能截断了消息。';

  @override
  String get pasteMalformed => '数据包已损坏。';

  @override
  String get openWrongKey => '无法用此口令或密钥打开该数据包。';

  @override
  String get openDamaged => '该数据包已损坏或被篡改。';

  @override
  String get openIsFile => '该数据包包含文件；请通过“打开 .klt”将其添加到保险库。';

  @override
  String get packetTitle => '数据包分析';

  @override
  String get packetFile => '文件';

  @override
  String get packetType => '类型';

  @override
  String get packetSize => '大小';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content（数据包 $packet）';
  }

  @override
  String get packetFormat => '格式';

  @override
  String get packetFormatValue => 'KLT1（基于 age v1）';

  @override
  String get packetRecipients => '接收者';

  @override
  String get packetContent => '内容';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305，64 KiB 分块';

  @override
  String get packetSignature => '签名';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65，已验证';

  @override
  String get sigUnsigned => '未签名';

  @override
  String get sigInvalid => '无效';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id（共享口令）';

  @override
  String get itemOpen => '打开';

  @override
  String get itemView => '查看';

  @override
  String get itemExport => '导出为 .klt';

  @override
  String get itemSavePlain => '不加密保存';

  @override
  String get savePlainTitle => '不加密保存？';

  @override
  String get savePlainBody => '文件将以解密状态保存。任何能访问保存位置的人都可以读取它；Kilit 将无法再保护它。';

  @override
  String get itemDelete => '从保险库删除';

  @override
  String get exportTitle => '导出为 .klt';

  @override
  String get exportIntro => '文件会被重新加密并由你的保险库签名。文件名是随机的；真实名称保存在加密数据包内。';

  @override
  String get exportWithPassphraseHint => '任何知道口令的人都能打开。关闭时：只有你的保险库能打开（用于备份）。';

  @override
  String get exportPassphraseHelper => '至少 12 个字符。不要通过发送文件的同一渠道发送口令。';

  @override
  String get passphraseTooShort => '共享口令至少需要 12 个字符。';

  @override
  String get importTitle => '打开 .klt 文件';

  @override
  String get importPassphraseHelper => '如果是发送到你自己保险库的，请留空。';

  @override
  String get importGo => '打开并添加到保险库';

  @override
  String importAddedSigned(String name) {
    return '$name 已添加到保险库（已签名）。';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name 已添加到保险库（未签名）。';
  }

  @override
  String get importWrongKey => '无法用此口令或你的保险库打开该文件。';

  @override
  String get importNotKlt => '这不是 .klt 文件。';

  @override
  String get importDamaged => '文件已损坏或被篡改。';

  @override
  String get settingsProtections => '你的保护措施';

  @override
  String get protPin => 'PIN 保护';

  @override
  String get protScreenshots => '阻止截屏';

  @override
  String get protScreenshotsValue => '已开启，适用于所有界面';

  @override
  String get protAutoLock => '自动锁定';

  @override
  String get protAutoLockValue => '离开应用时';

  @override
  String get protNetwork => 'Tor 连接';

  @override
  String get protNetworkValue => '未连接：第 1 阶段从不联网。Tor 将在第 2 阶段推出。';

  @override
  String get hwStrongbox => 'StrongBox 安全芯片';

  @override
  String get hwTee => '可信执行环境 (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore（无安全硬件）';

  @override
  String get hwSoftwareFile => '软件密钥（与保险库存放在一起）';

  @override
  String get hwNone => '无';

  @override
  String get hwDev => '无（开发版核心）';

  @override
  String get hwBoundHint => '你的 PIN 已绑定到本设备的硬件密钥。即使保险库文件被复制，也无法在其他设备上尝试破解。';

  @override
  String get hwNotBoundHint => '没有硬件密钥：如果保险库文件被复制，PIN 可能在其他设备上被猜出。';

  @override
  String get settingsFingerprint => '你的安全码';

  @override
  String get settingsFingerprintHint => '验证联系人时，两台设备上的安全码必须相同。';

  @override
  String get settingsAppearance => '外观';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystem => '系统语言';

  @override
  String get settingsPrivacy => '隐私';

  @override
  String get clipboardCheck => '提示剪贴板中的 Kilit 消息';

  @override
  String get clipboardCheckHint =>
      '保险库打开时，提示打开剪贴板中的 KLT1: 消息。Android 会显示剪贴板已被读取的通知。';

  @override
  String get settingsPermissions => '权限';

  @override
  String get permIntro => 'Kilit 目前未使用任何敏感权限。';

  @override
  String get permCamera => '相机';

  @override
  String get permCameraValue => '未使用（相机将在第 2 阶段推出）';

  @override
  String get permNotifications => '通知';

  @override
  String get permNotificationsValue => '未使用';

  @override
  String get permInternet => '网络';

  @override
  String get permInternetValue => '无：第 1 阶段离线运行';

  @override
  String get permOpenSystem => '打开系统权限设置';

  @override
  String get settingsAbout => '关于';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutLicense => '许可证';

  @override
  String get aboutAlpha => '未经独立审计。Alpha 版：适合测试，不适合高风险用途。';
}
