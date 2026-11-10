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
  String get panicTooltip => '轻触锁定，长按输入紧急代码';

  @override
  String get panicNoCode => '请先在设置中设定紧急代码。';

  @override
  String get panicEnterTitle => '紧急代码';

  @override
  String get panicEnterHint => '输入紧急代码以清除 Kilit 中的所有内容。';

  @override
  String get panicWrong => '这不是紧急代码。';

  @override
  String get settingsPanic => '紧急代码';

  @override
  String get panicExplain =>
      '四位数字。在锁屏界面代替 PIN 输入，或长按锁定按钮后输入，它会永久清除 Kilit 中的所有密钥、消息和文件，Kilit 会像刚安装时一样重新开始。';

  @override
  String get panicStatusOn => '已设定';

  @override
  String get panicStatusOff => '未设定';

  @override
  String get panicSet => '设定紧急代码';

  @override
  String get panicChange => '更改紧急代码';

  @override
  String get panicRemove => '移除紧急代码';

  @override
  String get panicCreateTitle => '选择紧急代码';

  @override
  String get panicCreateHint => '四位数字。任何看到你输入此代码的人都能清除 Kilit。';

  @override
  String get panicConfirmTitle => '再次输入紧急代码';

  @override
  String get panicMismatch => '两次代码不一致，请重新开始。';

  @override
  String get panicSaved => '紧急代码已设定。';

  @override
  String get panicRemoved => '紧急代码已移除。';

  @override
  String get panicRejected => '此代码无法使用，请另选一个。';

  @override
  String get keptInVault => '已保存到保险库。';

  @override
  String get alreadyInVault => '已在保险库中。';

  @override
  String get keptTitleFallback => '消息';

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
  String get settingsChangePin => '更改 PIN';

  @override
  String get changePinCurrent => '输入当前 PIN';

  @override
  String get changePinNew => '选择新 PIN';

  @override
  String get changePinDone => 'PIN 已更改。';

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
  String get chatEmpty => '还没有消息。你写下的第一条消息会开启加密会话。';

  @override
  String get chatInput => '消息';

  @override
  String get chatSend => '发送';

  @override
  String get chatNewContact => '对方在未被添加的情况下给你发了消息。接受后即可回复，或将其屏蔽。在信任对方前请核对安全码。';

  @override
  String get safetyTitle => '安全码';

  @override
  String safetyHint(String name) {
    return '与 $name 当面或通话核对这 60 位数字。如果两部手机上一致，就说明中间没有他人。';
  }

  @override
  String get attachCamera => '相机';

  @override
  String get attachFile => '照片或文件';

  @override
  String get chatFileTooLarge => '文件过大，无法发送：最大 5 MB。';

  @override
  String get chatDelivered => '已送达';

  @override
  String get fileComing => '正在接收…';

  @override
  String get fileToVault => '添加到保险库';

  @override
  String get fileSavedVault => '已添加到保险库。';

  @override
  String get timerTitle => '阅后即焚消息';

  @override
  String get timerHint => '此对话中的新消息会在这段时间后从两部手机上消失。';

  @override
  String get timerOff => '关闭';

  @override
  String get timer5m => '5 分钟';

  @override
  String get timer1h => '1 小时';

  @override
  String get timer1d => '1 天';

  @override
  String get timer1w => '1 周';

  @override
  String get renewTitle => '更新我的 Kilit ID';

  @override
  String get renewBody =>
      '你会获得新的单词、新的链接和新的二维码。联系人仍可像以前一样与你交流；旧 ID 和旧链接对新的人不再有效。';

  @override
  String get renewGo => '更新';

  @override
  String renewDone(String id) {
    return '你的新 ID：@$id';
  }

  @override
  String get cameraNoCamera => '无法打开相机。请在手机设置中检查相机权限。';

  @override
  String get cameraShutter => '拍照';

  @override
  String get cameraRetake => '重拍';

  @override
  String get cameraUse => '使用';

  @override
  String get cameraIntro => '照片只在内存中拍摄：不会向手机写入任何内容，也不含位置或相机信息。';

  @override
  String get cameraSendTo => '发送给…';

  @override
  String get cameraToVault => '保存在保险库';

  @override
  String get cameraSavedVault => '照片已保存在保险库。';

  @override
  String get cameraNoContacts => '还没有可以发送的联系人。';

  @override
  String cameraSent(String name) {
    return '已发送给 $name。';
  }

  @override
  String get chatsYourKilit => '你的 Kilit';

  @override
  String get chatsSearch => '搜索';

  @override
  String get chatsEmptyNew => '这里还没有人。添加某人，或向对方展示你的二维码。';

  @override
  String get torChipReady => 'Tor 就绪';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor 已关闭';

  @override
  String get addTitle => '添加联系人';

  @override
  String get addHint => '扫描对方的二维码，或粘贴对方给你的链接或 @ID。';

  @override
  String get addScan => '扫描对方的二维码';

  @override
  String get addField => 'Kilit 链接或 @ID';

  @override
  String get addGo => '添加';

  @override
  String get addSearching => '正在通过 Tor 查找…';

  @override
  String get addNotFound => '未找到此 ID 对应的人。请检查后稍后再试。';

  @override
  String get addOffline => '尚未连接 Tor。请等到显示“Tor 就绪”。';

  @override
  String get addNotInvite => '这不是 Kilit 链接或 @ID。';

  @override
  String get addShowMine => '显示我的二维码';

  @override
  String get addShowMineHint => '你的二维码、链接和 @ID';

  @override
  String get myTitle => '我的二维码';

  @override
  String get myHint => '任何拥有此二维码、你的链接或 @ID 的人都可以给你发消息。对方的第一条消息会在“请求”中等待，直到你接受。';

  @override
  String get myCopyLink => '复制链接';

  @override
  String myShareText(String id, String link) {
    return '在 Kilit 上添加我：@$id\n$link';
  }

  @override
  String get scanTitle => '扫描 Kilit 二维码';

  @override
  String get scanHint => '将相机对准二维码。';

  @override
  String get requestsTitle => '请求';

  @override
  String get requestsEmpty => '没有请求。';

  @override
  String get requestHint => '对方在未被添加的情况下给你发了消息。在你接受并回复之前，对方收不到任何内容。';

  @override
  String get requestAccept => '接受';

  @override
  String get requestDecline => '拒绝';

  @override
  String get requestBlock => '屏蔽';

  @override
  String get chatOnRelay => '已存于中继';

  @override
  String get chatQueued => '等待网络';

  @override
  String get contactRename => '重命名';

  @override
  String get contactRemove => '删除联系人';

  @override
  String get contactRemoveTitle => '删除此联系人？';

  @override
  String get contactRemoveBody => '会话和整个对话都会被删除。要再次通信，请重新互相添加。';

  @override
  String get contactRemoveGo => '删除';

  @override
  String get save => '保存';

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
  String vaultFileCleaned(String name, String removed) {
    return '$name 已加密并添加到保险库。已移除的隐藏数据：$removed。';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name 已加密并添加到保险库。Kilit 无法从此类文件中移除隐藏数据（例如作者）；分享前请先检查。';
  }

  @override
  String get damagedPictureTitle => '图片已损坏';

  @override
  String get damagedPictureBody => '此图片已损坏，Kilit 无法移除其隐藏数据（例如拍摄地点）。仍要按原样添加吗？';

  @override
  String get damagedPictureSeal => '按原样添加';

  @override
  String get hiddenLocation => '位置';

  @override
  String get hiddenCamera => '相机信息';

  @override
  String get hiddenAuthorNotes => '作者和备注';

  @override
  String get hiddenExtraImages => '额外图片';

  @override
  String get hiddenOther => '其他元数据';

  @override
  String get hiddenListSeparator => '、';

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
  String get torOff => '已关闭：Kilit 不会联网。';

  @override
  String torStarting(int progress) {
    return '正在连接… $progress%';
  }

  @override
  String get torReady => '已通过 Tor 连接。';

  @override
  String get torFailed => '无法连接到 Tor。';

  @override
  String get torUnavailable => '此设备暂不可用。';

  @override
  String get torSwitch => '通过 Tor 连接';

  @override
  String get torSwitchHint => 'Kilit 只通过 Tor 访问网络。关闭时保持离线。';

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
  String get settingsFingerprint => '你的保险库签名号码';

  @override
  String get settingsFingerprintHint =>
      '这个号码属于你保险库的密钥，它们为你封装的数据包（携带模式）签名。收到你签名数据包的人会在其中看到签名者号码；如果与这里的号码一致（可当面或通话与你核对），数据包就来自你。核对聊天时，请比对每个对话里的安全码。';

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
  String get permIntro => 'Kilit 只请求所需的权限，并且只在需要时请求。';

  @override
  String get permCamera => '相机';

  @override
  String get permCameraValue => '用于聊天中的照片。首次打开相机时询问；不会存入相册。';

  @override
  String get permNotifications => '通知';

  @override
  String get permNotificationsValue => '未使用：你的消息内容不会显示在应用之外。';

  @override
  String get permInternet => '网络';

  @override
  String get permInternetValue => '仅用于内置的 Tor。所有连接都经过它。';

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

  @override
  String get settingsBridges => 'Tor 连接';

  @override
  String get torRouteAuto => '自动';

  @override
  String get torRouteAutoHint => '先直连 Tor；被封锁时改用网桥。';

  @override
  String get torRouteDirect => '直连 Tor';

  @override
  String get torRouteObfs4 => 'obfs4 网桥';

  @override
  String get torRouteObfs4Hint => '适用于封锁 Tor 的网络。';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => '适用于严格审查。较慢。';

  @override
  String get torRouteCustom => '我自己的网桥';

  @override
  String get torRouteCustomHint => '来自 bridges.torproject.org 或你信任之人的网桥行。';

  @override
  String get torRouteLinesHint => '每行一个网桥';

  @override
  String get resend => '重新发送';

  @override
  String get resendHint => '中继已收到这条消息，但对方手机尚未确认送达。在送达之前，Kilit 会在一周内每天重发一次。';

  @override
  String get resendDone => '已重新发送。';

  @override
  String get newGroup => '新建群组';

  @override
  String get groupName => '群组名称';

  @override
  String groupPick(int count) {
    return '最多选择 $count 人';
  }

  @override
  String get groupCreate => '创建';

  @override
  String groupMembers(int count) {
    return '$count 人';
  }

  @override
  String get groupInfo => '群组信息';

  @override
  String get groupAdmin => '管理员';

  @override
  String get groupYou => '你';

  @override
  String get groupAddPeople => '添加成员';

  @override
  String get groupRemove => '移出群组';

  @override
  String get groupRename => '重命名群组';

  @override
  String get groupEnd => '结束群组';

  @override
  String get groupEndConfirm => '要为所有人结束群组吗？之后任何人都不能再发言。';

  @override
  String get groupLeave => '退出群组';

  @override
  String get groupLeaveConfirm => '要退出此群组吗？之后不会再收到它的消息。';

  @override
  String get groupDelete => '删除群组';

  @override
  String get groupEnded => '此群组已结束。';

  @override
  String get groupGone => '你已不在此群组中。';

  @override
  String groupDeliveredTo(int n, int total) {
    return '已送达 $n/$total';
  }

  @override
  String get groupNoContacts => '请先添加联系人：群组由你添加的人组成。';

  @override
  String groupFull(int max) {
    return '一个群组最多 $max 人。';
  }

  @override
  String groupNoticeCreated(String who) {
    return '创建者：$who';
  }

  @override
  String groupNoticeJoined(String who) {
    return '$who 把你加入了群组';
  }

  @override
  String groupNoticeAdded(String who, String whom) {
    return '已加入：$whom（$who 添加）';
  }

  @override
  String groupNoticeRemoved(String who, String whom) {
    return '已移出：$whom（$who 操作）';
  }

  @override
  String groupNoticeLeft(String who) {
    return '已退出：$who';
  }

  @override
  String groupNoticeRenamed(String who, String name) {
    return '群组新名称“$name”（$who）';
  }

  @override
  String groupNoticeEnded(String who) {
    return '结束者：$who';
  }

  @override
  String groupNoticeRemovedYou(String who) {
    return '$who 把你移出了群组';
  }

  @override
  String get emojiButton => '表情和贴纸';

  @override
  String get stickers => '贴纸';

  @override
  String get stickerLine => '贴纸';

  @override
  String get devicesTitle => '已关联设备';

  @override
  String get devicesIntro =>
      '你的 Kilit ID 最多可在 5 台设备上使用：你的手机和你关联的电脑。每台设备有自己的密钥，消息会送达所有设备。';

  @override
  String get deviceThis => '此设备';

  @override
  String get devicePhone => '手机';

  @override
  String deviceNumber(int n) {
    return '设备 $n';
  }

  @override
  String get deviceLink => '关联电脑';

  @override
  String get deviceRemove => '移除';

  @override
  String get deviceRemoveConfirm => '移除此设备？它将不再收到你的消息。如果设备丢失，也请更新你的 Kilit ID。';

  @override
  String get linkToPhone => '关联到我的手机';

  @override
  String get linkToPhoneHint =>
      '让此设备成为你手机上 Kilit ID 的一台设备。在手机上：设置、已关联设备、关联电脑，然后扫描此代码。';

  @override
  String get linkOnlyNew => '只有尚无联系人的新 Kilit 才能关联到手机。';

  @override
  String get linkWaiting => '正在等待另一台设备。两台都需要 Tor。';

  @override
  String get linkCompare => '确认另一块屏幕显示相同的代码：';

  @override
  String get linkDone => '已关联。消息现在会送达两台设备。';

  @override
  String get linkNotCode => '这不是 Kilit 关联代码。';

  @override
  String get linkedToPhone => '此设备已关联到你手机上的 Kilit ID。';

  @override
  String get torChipFailed => 'Tor 错误';

  @override
  String get protScreenshotsOffHint => '关闭：可以对 Kilit 截屏和录屏，并会显示在最近使用的应用中。';

  @override
  String get torReconnect => '重新连接 Tor';

  @override
  String get torReconnectHint => '新的线路，Tor 重新连接';

  @override
  String get torReconnecting => '正在重新连接 Tor…';

  @override
  String get torRestartApp => '重启 Kilit';

  @override
  String get torRestartHint => 'Tor 在 Kilit 内部停止了。只有重启才能恢复；之后需要重新解锁。';

  @override
  String get torDetailsTitle => 'Tor 连接';

  @override
  String get torAnonTitle => '你的 IP 地址已隐藏';

  @override
  String get torAnonBody =>
      'Kilit 只通过 Tor 连接网络。没有人能看到你的 IP 地址，只有知道你 Kilit ID 的人才能联系到你。';

  @override
  String get torRouteTitle => '你的消息经过的路径';

  @override
  String get torRouteYou => '你';

  @override
  String get torRouteYouHint => '你的 IP 地址只留在这里';

  @override
  String get torHopGuard => '入口节点：能看到 IP，看不到内容';

  @override
  String get torHopMiddle => '中间节点：两者都看不到';

  @override
  String get torHopExit => '出口节点：能看到 Kilit 中继，看不到你';

  @override
  String get torHopUnknown => '一个 Tor 中继';

  @override
  String get torRouteRelays => 'Kilit 中继';

  @override
  String get torRouteRelaysHint => '保存加密封装的消息直到联系人取走；它们只看到 Tor，看不到你';

  @override
  String get torRouteLayers => '三层加密';

  @override
  String get torNotReadyDiagram => 'Tor 就绪后会显示它使用的中继。';

  @override
  String get torLog => 'Tor 日志';

  @override
  String get torLogEmpty => '暂无日志。';

  @override
  String get torLogRefresh => '刷新';

  @override
  String get torLogCopied => '已复制 Tor 日志';

  @override
  String get torBlockedTitle => '这里可能屏蔽了 Tor';

  @override
  String get torBlockedBody => 'Kilit 无法连接到 Tor 网络。网桥可以隐藏你在使用 Tor。请选择方式：';

  @override
  String get torBlockedOwn => '粘贴我自己的网桥';

  @override
  String get torBlockedOwnHint =>
      '可在 bridges.torproject.org 获取，或发邮件到 bridges@torproject.org。';

  @override
  String get torBlockedLater => '以后再说';

  @override
  String get selfNotes => '给自己的笔记';

  @override
  String get selfNotesHint => '在保险库中加密，仅保存在此设备';

  @override
  String selfNotesCount(int count) {
    return '笔记：$count';
  }

  @override
  String get selfNoteNew => '新笔记';

  @override
  String get selfNotesEmpty => '还没有笔记。你在这里写的内容会封存在保险库中，只有解锁后才能读取。';

  @override
  String get selfNoteDelete => '删除笔记';

  @override
  String get selfNoteDeleteConfirm => '删除这条笔记？删除后无法恢复。';

  @override
  String get selfNoteSaved => '笔记已加密保存';

  @override
  String get selfNoteUnsaved => '不保存更改就离开？';

  @override
  String get selfNoteDiscard => '放弃';

  @override
  String get linkTorWait => 'Tor 尚未连接，因此关联正在等待。两台设备都需要 Tor。';

  @override
  String linkFailed(String error) {
    return '关联未能开始：$error';
  }

  @override
  String get linkScanInDevices =>
      '这是用于关联电脑的代码。请在这部手机上打开 设置 → 已关联设备 → 关联电脑，并在那里扫描。';

  @override
  String get crashTitle => 'Kilit 意外关闭';

  @override
  String get crashBody =>
      '上次 Kilit 自行关闭了。下面的报告不含消息或密钥，只有出错的位置。请复制并发送给开发者，例如在 GitHub issue 中。';

  @override
  String get crashCopy => '复制报告';

  @override
  String get linkFetchingKey => '正在从中继获取电脑的密钥…';
}
