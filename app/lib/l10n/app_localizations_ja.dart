// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class LJa extends L {
  LJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get copy => 'コピー';

  @override
  String get copied => 'コピーしました';

  @override
  String get share => '共有';

  @override
  String get lockNow => '今すぐロック';

  @override
  String get panicTooltip => 'タップでロック、長押しでパニックコード';

  @override
  String get panicNoCode => '先に設定でパニックコードを設定してください。';

  @override
  String get panicEnterTitle => 'パニックコード';

  @override
  String get panicEnterHint => 'Kilit のすべてを消去するにはパニックコードを入力してください。';

  @override
  String get panicWrong => 'パニックコードではありません。';

  @override
  String get settingsPanic => 'パニックコード';

  @override
  String get panicExplain =>
      '4桁の数字です。ロック画面で PIN の代わりに入力するか、ロックボタンを長押ししてから入力すると、Kilit のすべての鍵・メッセージ・ファイルを完全に消去し、Kilit はインストール直後の状態からやり直します。';

  @override
  String get panicStatusOn => '設定済み';

  @override
  String get panicStatusOff => '未設定';

  @override
  String get panicSet => 'パニックコードを設定';

  @override
  String get panicChange => 'パニックコードを変更';

  @override
  String get panicRemove => 'パニックコードを削除';

  @override
  String get panicCreateTitle => 'パニックコードを選んでください';

  @override
  String get panicCreateHint => '4桁。入力するところを見た人は誰でも Kilit を消去できます。';

  @override
  String get panicConfirmTitle => 'パニックコードをもう一度入力';

  @override
  String get panicMismatch => 'コードが一致しません。最初からやり直してください。';

  @override
  String get panicSaved => 'パニックコードを設定しました。';

  @override
  String get panicRemoved => 'パニックコードを削除しました。';

  @override
  String get panicRejected => 'このコードは使えません。別のコードを選んでください。';

  @override
  String get keptInVault => '金庫に保存しました。';

  @override
  String get alreadyInVault => 'すでに金庫にあります。';

  @override
  String get keptTitleFallback => 'メッセージ';

  @override
  String get devBanner => '開発用コア：実際の暗号化は行われません。';

  @override
  String get lockTitleUnlock => 'ロック解除';

  @override
  String get lockTitleCreate => 'PINを設定';

  @override
  String get lockTitleConfirm => 'PINをもう一度入力';

  @override
  String get lockHintUnlock => '金庫を開くにはPINを入力してください。';

  @override
  String lockHintCreate(int min) {
    return '$min桁以上。忘れると金庫は開けません。復旧手段はありません。';
  }

  @override
  String get lockHintConfirm => '同じPINをもう一度入力してください。';

  @override
  String get lockMismatch => 'PINが一致しませんでした。最初からやり直してください。';

  @override
  String get lockWrongPin => 'PINが違います。';

  @override
  String get settingsChangePin => 'PIN を変更';

  @override
  String get changePinCurrent => '現在の PIN を入力';

  @override
  String get changePinNew => '新しい PIN を選択';

  @override
  String get changePinDone => 'PIN を変更しました。';

  @override
  String lockWait(int seconds) {
    return '$seconds秒待ってから再試行してください。';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count桁入力済み';
  }

  @override
  String get pinDelete => '削除';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'チャット';

  @override
  String get navVault => '金庫';

  @override
  String get navCamera => 'カメラ';

  @override
  String get navSettings => '設定';

  @override
  String get chatEmpty => 'まだメッセージはありません。最初に書いたメッセージで暗号化セッションが始まります。';

  @override
  String get chatInput => 'メッセージ';

  @override
  String get chatSend => '送信';

  @override
  String get chatNewContact =>
      '追加されていない相手からのメッセージです。返信するには承認、または相手をブロックしてください。信頼する前に安全番号を照合してください。';

  @override
  String get safetyTitle => '安全番号';

  @override
  String safetyHint(String name) {
    return 'この60桁を $name と、会って、または通話で照合してください。両方の電話で同じなら、間に誰もいません。';
  }

  @override
  String get attachCamera => 'カメラ';

  @override
  String get attachFile => '写真またはファイル';

  @override
  String get chatFileTooLarge => '大きすぎて送れません：最大 5 MB。';

  @override
  String get chatDelivered => '配信済み';

  @override
  String get fileComing => '受信中…';

  @override
  String get fileToVault => '金庫に追加';

  @override
  String get fileSavedVault => '金庫に追加しました。';

  @override
  String get timerTitle => '消えるメッセージ';

  @override
  String get timerHint => 'このチャットの新しいメッセージは、この時間が過ぎると両方の電話から消えます。';

  @override
  String get timerOff => 'オフ';

  @override
  String get timer5m => '5 分';

  @override
  String get timer1h => '1 時間';

  @override
  String get timer1d => '1 日';

  @override
  String get timer1w => '1 週間';

  @override
  String get renewTitle => 'Kilit ID を更新';

  @override
  String get renewBody =>
      '新しい単語、新しいリンク、新しい QR コードになります。連絡先とはこれまでどおりやり取りできます。古い ID とリンクは新しい相手には使えなくなります。';

  @override
  String get renewGo => '更新';

  @override
  String renewDone(String id) {
    return '新しい ID：@$id';
  }

  @override
  String get cameraNoCamera => 'カメラを開けませんでした。電話の設定でカメラの権限を確認してください。';

  @override
  String get cameraShutter => '写真を撮る';

  @override
  String get cameraRetake => '撮り直す';

  @override
  String get cameraUse => '使う';

  @override
  String get cameraIntro => '写真はメモリ上でのみ撮影されます。電話には何も書き込まれず、位置情報やカメラの情報も含まれません。';

  @override
  String get cameraSendTo => '送信先…';

  @override
  String get cameraToVault => '金庫に保管';

  @override
  String get cameraSavedVault => '写真を金庫に保管しました。';

  @override
  String get cameraNoContacts => 'まだ送信できる連絡先がいません。';

  @override
  String cameraSent(String name) {
    return '$name に送信しました。';
  }

  @override
  String get chatsYourKilit => 'あなたの Kilit';

  @override
  String get chatsSearch => '検索';

  @override
  String get chatsEmptyNew => 'まだ誰もいません。誰かを追加するか、自分のコードを見せてください。';

  @override
  String get torChipReady => 'Tor 準備完了';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor オフ';

  @override
  String get addTitle => '連絡先を追加';

  @override
  String get addHint => '相手のコードを読み取るか、もらったリンクや @ID を貼り付けてください。';

  @override
  String get addScan => '相手のコードを読み取る';

  @override
  String get addField => 'Kilit のリンクまたは @ID';

  @override
  String get addGo => '追加';

  @override
  String get addSearching => 'Tor 経由で検索中…';

  @override
  String get addNotFound => 'この ID の人は見つかりませんでした。確認するか、少ししてからもう一度試してください。';

  @override
  String get addOffline => 'まだ Tor に接続していません。「Tor 準備完了」になるまでお待ちください。';

  @override
  String get addNotInvite => 'Kilit のリンクでも @ID でもありません。';

  @override
  String get addShowMine => '自分のコードを表示';

  @override
  String get addShowMineHint => 'QR コード、リンク、@ID';

  @override
  String get myTitle => '自分のコード';

  @override
  String get myHint =>
      'このコード、リンク、@ID を知っている人なら誰でもあなたに書けます。最初のメッセージは、承認するまで「リクエスト」で待ちます。';

  @override
  String get myCopyLink => 'リンクをコピー';

  @override
  String myShareText(String id, String link) {
    return 'Kilit で追加してください：@$id\n$link';
  }

  @override
  String get scanTitle => 'Kilit コードを読み取る';

  @override
  String get scanHint => 'カメラを QR コードに向けてください。';

  @override
  String get requestsTitle => 'リクエスト';

  @override
  String get requestsEmpty => 'リクエストはありません。';

  @override
  String get requestHint => '追加されていない相手からのメッセージです。承認して返信するまで、相手には何も届きません。';

  @override
  String get requestAccept => '承認';

  @override
  String get requestDecline => '拒否';

  @override
  String get requestBlock => 'ブロック';

  @override
  String get chatOnRelay => 'リレーに保存済み';

  @override
  String get chatQueued => 'ネットワーク待ち';

  @override
  String get contactRename => '名前を変更';

  @override
  String get contactRemove => '連絡先を削除';

  @override
  String get contactRemoveTitle => 'この連絡先を削除しますか？';

  @override
  String get contactRemoveBody =>
      'セッションと会話全体が削除されます。再びやり取りするには、もう一度追加し合ってください。';

  @override
  String get contactRemoveGo => '削除';

  @override
  String get save => '保存';

  @override
  String get vaultAddNote => 'メモを追加';

  @override
  String get vaultCompose => 'キャリアメッセージ';

  @override
  String get vaultOpenClipboard => 'クリップボードから開く';

  @override
  String get vaultOpenPasted => '貼り付けたテキストを開く';

  @override
  String get vaultSealFile => 'ファイルを暗号化';

  @override
  String get vaultOpenKlt => '.kltを開く';

  @override
  String get vaultEmpty =>
      '金庫は空です。メモを追加するかファイルを暗号化してください。すべて.kltパケットとして保管されます。';

  @override
  String get vaultSigned => '署名済み';

  @override
  String get vaultFileTooLarge => 'ファイルが大きすぎます。上限は64 MBです。';

  @override
  String vaultFileSealed(String name) {
    return '$nameを暗号化して金庫に追加しました。';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$nameを暗号化して金庫に追加しました。削除した隠しデータ：$removed。';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$nameを暗号化して金庫に追加しました。この種類のファイルからは隠しデータ（作成者など）を削除できません。共有する前に確認してください。';
  }

  @override
  String get damagedPictureTitle => '破損した画像';

  @override
  String get damagedPictureBody =>
      'この画像は破損しているため、撮影場所などの隠しデータを削除できませんでした。このまま追加しますか？';

  @override
  String get damagedPictureSeal => 'このまま追加';

  @override
  String get hiddenLocation => '位置情報';

  @override
  String get hiddenCamera => 'カメラ情報';

  @override
  String get hiddenAuthorNotes => '作成者とメモ';

  @override
  String get hiddenExtraImages => '追加の画像';

  @override
  String get hiddenOther => 'その他のメタデータ';

  @override
  String get hiddenListSeparator => '、';

  @override
  String get clipboardEmpty =>
      'クリップボードにKilitメッセージがありません。WhatsAppでメッセージを長押しし、［コピー］をタップしてください。';

  @override
  String get clipboardBanner => 'クリップボードにKilitメッセージがあります。';

  @override
  String get clipboardBannerOpen => '開く';

  @override
  String get clipboardBannerDismiss => '無視';

  @override
  String get noteNew => '新しいメモ';

  @override
  String get noteTitle => 'タイトル';

  @override
  String get noteText => 'メモ';

  @override
  String get sealAndSave => '暗号化して保存';

  @override
  String get carrierTitle => 'キャリアメッセージ';

  @override
  String get carrierIntro => 'メッセージを暗号化し、WhatsAppなどのアプリに貼り付けられるテキストに変換します。';

  @override
  String get carrierMessage => 'メッセージ';

  @override
  String get withPassphrase => '共有パスフレーズを使う';

  @override
  String get carrierWithPassphraseHint => '相手は同じパスフレーズで開きます。オフの場合は自分だけが開けます。';

  @override
  String get passphrase => '共有パスフレーズ';

  @override
  String get carrierPassphraseHelper => '12文字以上。メッセージと同じ経路で送らないでください。';

  @override
  String get carrierSeal => '暗号化';

  @override
  String get carrierResultIntro =>
      'このテキストをコピーして送信してください。経路上では暗号化されたデータしか見えません。';

  @override
  String carrierChars(int count) {
    return '$count文字';
  }

  @override
  String get pasteTitle => '貼り付けたテキストを開く';

  @override
  String get pasteInput => 'チャットからコピーしたテキスト';

  @override
  String get pasteFromClipboard => 'クリップボードから貼り付け';

  @override
  String get passphraseIfAny => '共有パスフレーズ（ある場合）';

  @override
  String get pasteOpen => '検出して開く';

  @override
  String get pasteNone => 'テキストにKLT1パケットが見つかりません。';

  @override
  String get pasteTruncated => 'パケットが途中で切れています。送信元のアプリがメッセージを短縮した可能性があります。';

  @override
  String get pasteMalformed => 'パケットが破損しています。';

  @override
  String get openWrongKey => 'このパスフレーズまたは鍵ではこのパケットを開けません。';

  @override
  String get openDamaged => 'このパケットは破損しているか、改変されています。';

  @override
  String get openIsFile => 'このパケットにはファイルが含まれています。［.kltを開く］で金庫に追加してください。';

  @override
  String get packetTitle => 'パケット解析';

  @override
  String get packetFile => 'ファイル';

  @override
  String get packetType => '種類';

  @override
  String get packetSize => 'サイズ';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content（パケット $packet）';
  }

  @override
  String get packetFormat => '形式';

  @override
  String get packetFormatValue => 'KLT1（age v1ベース）';

  @override
  String get packetRecipients => '受信者';

  @override
  String get packetContent => '内容';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305、64 KiBチャンク';

  @override
  String get packetSignature => '署名';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65、検証済み';

  @override
  String get sigUnsigned => '署名なし';

  @override
  String get sigInvalid => '無効';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id（共有パスフレーズ）';

  @override
  String get itemOpen => '開く';

  @override
  String get itemView => '表示';

  @override
  String get itemExport => '.kltとして書き出す';

  @override
  String get itemSavePlain => '暗号化せずに保存';

  @override
  String get savePlainTitle => '暗号化せずに保存しますか？';

  @override
  String get savePlainBody =>
      'ファイルは復号された状態で保存されます。保存先にアクセスできる人は誰でも読むことができ、Kilitでは保護できなくなります。';

  @override
  String get itemDelete => '金庫から削除';

  @override
  String get exportTitle => '.kltとして書き出す';

  @override
  String get exportIntro =>
      'ファイルは再度暗号化され、あなたの金庫で署名されます。ファイル名はランダムで、本来の名前は暗号化されたパケット内に保持されます。';

  @override
  String get exportWithPassphraseHint =>
      'パスフレーズを知っている人なら誰でも開けます。オフの場合は自分の金庫だけが開けます（バックアップ用）。';

  @override
  String get exportPassphraseHelper => '12文字以上。ファイルと同じ経路で送らないでください。';

  @override
  String get passphraseTooShort => '共有パスフレーズは12文字以上にしてください。';

  @override
  String get importTitle => '.kltファイルを開く';

  @override
  String get importPassphraseHelper => '自分の金庫宛てに送られた場合は空欄のままにしてください。';

  @override
  String get importGo => '開いて金庫に追加';

  @override
  String importAddedSigned(String name) {
    return '$nameを金庫に追加しました（署名済み）。';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$nameを金庫に追加しました（署名なし）。';
  }

  @override
  String get importWrongKey => 'このパスフレーズまたはあなたの金庫ではこのファイルを開けません。';

  @override
  String get importNotKlt => '.kltファイルではありません。';

  @override
  String get importDamaged => 'ファイルが破損しているか、改変されています。';

  @override
  String get settingsProtections => '保護機能';

  @override
  String get protPin => 'PIN保護';

  @override
  String get protScreenshots => 'スクリーンショットのブロック';

  @override
  String get protScreenshotsValue => 'オン（すべての画面）';

  @override
  String get protAutoLock => '自動ロック';

  @override
  String get protAutoLockValue => 'アプリを離れたとき';

  @override
  String get protNetwork => 'Tor接続';

  @override
  String get protNetworkValue => '未接続：ステージ1はオンラインになりません。Torはステージ2で提供されます。';

  @override
  String get torOff => 'オフ：Kilit はオンラインになりません。';

  @override
  String torStarting(int progress) {
    return '接続中… $progress%';
  }

  @override
  String get torReady => 'Tor 経由で接続しました。';

  @override
  String get torFailed => 'Tor に接続できませんでした。';

  @override
  String get torUnavailable => 'このデバイスではまだ使えません。';

  @override
  String get torSwitch => 'Tor 経由で接続';

  @override
  String get torSwitchHint =>
      'Kilit は Tor を通してのみネットワークに接続します。オフのときはオフラインのままです。';

  @override
  String get hwStrongbox => 'StrongBoxセキュリティチップ';

  @override
  String get hwTee => '信頼できる実行環境（TEE）';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore（セキュアハードウェアなし）';

  @override
  String get hwSoftwareFile => 'ソフトウェア鍵（金庫と同じ場所）';

  @override
  String get hwNone => 'なし';

  @override
  String get hwDev => 'なし（開発用コア）';

  @override
  String get hwBoundHint =>
      'PINはこの端末のハードウェア鍵に結び付けられています。金庫ファイルをコピーされても、別の端末では試行できません。';

  @override
  String get hwNotBoundHint =>
      'ハードウェア鍵がありません。金庫ファイルがコピーされると、別の端末でPINを推測される可能性があります。';

  @override
  String get settingsFingerprint => '安全番号';

  @override
  String get settingsFingerprintHint => '連絡先を確認する際は、両方の端末で同じである必要があります。';

  @override
  String get settingsAppearance => '外観';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystem => 'システムの言語';

  @override
  String get settingsPrivacy => 'プライバシー';

  @override
  String get clipboardCheck => 'クリップボードのKilitメッセージを提案';

  @override
  String get clipboardCheckHint =>
      '金庫を開いたとき、クリップボードにあるKLT1:メッセージを開くよう提案します。Androidではクリップボードが読み取られたことが通知されます。';

  @override
  String get settingsPermissions => '権限';

  @override
  String get permIntro => 'Kilitは現在、機密性の高い権限を使用していません。';

  @override
  String get permCamera => 'カメラ';

  @override
  String get permCameraValue => '未使用（カメラはステージ2で提供）';

  @override
  String get permNotifications => '通知';

  @override
  String get permNotificationsValue => '未使用';

  @override
  String get permInternet => 'インターネット';

  @override
  String get permInternetValue => 'なし：ステージ1はオフラインで動作します';

  @override
  String get permOpenSystem => 'システムの権限設定を開く';

  @override
  String get settingsAbout => 'このアプリについて';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutLicense => 'ライセンス';

  @override
  String get aboutAlpha => '独立した監査は受けていません。アルファ版：テスト用であり、重要な用途には適していません。';

  @override
  String get settingsBridges => 'Tor 接続';

  @override
  String get torRouteAuto => '自動';

  @override
  String get torRouteAutoHint => 'まず Tor に直接接続し、遮断されていればブリッジを使います。';

  @override
  String get torRouteDirect => 'Tor に直接';

  @override
  String get torRouteObfs4 => 'obfs4 ブリッジ';

  @override
  String get torRouteObfs4Hint => 'Tor を遮断するネットワーク向け。';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => '厳しい検閲向け。低速です。';

  @override
  String get torRouteCustom => '自分のブリッジ';

  @override
  String get torRouteCustomHint => 'bridges.torproject.org または信頼できる人から得たブリッジ行。';

  @override
  String get torRouteLinesHint => '1 行に 1 つのブリッジ';

  @override
  String get resend => 'もう一度送る';

  @override
  String get resendHint =>
      'メッセージはリレーにありますが、相手の端末から到着の知らせがまだありません。届くまで、Kilit は 1 週間、1 日 1 回再送します。';

  @override
  String get resendDone => '再送しました。';
}
