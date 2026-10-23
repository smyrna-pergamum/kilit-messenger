// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class LTr extends L {
  LTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get close => 'Kapat';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get share => 'Paylaş';

  @override
  String get lockNow => 'Şimdi kilitle';

  @override
  String get panicTooltip =>
      'Kilitlemek için dokunun, panik kodu için basılı tutun';

  @override
  String get panicNoCode => 'Önce Ayarlar\'dan bir panik kodu belirleyin.';

  @override
  String get panicEnterTitle => 'Panik kodu';

  @override
  String get panicEnterHint =>
      'Kilit\'teki her şeyi silmek için panik kodunu girin.';

  @override
  String get panicWrong => 'Bu panik kodu değil.';

  @override
  String get settingsPanic => 'Panik kodu';

  @override
  String get panicExplain =>
      'Dört haneli bir kod. Kilit ekranında PIN yerine ya da kilit düğmesine basılı tuttuktan sonra girilirse Kilit\'teki tüm anahtarları, mesajları ve dosyaları kalıcı olarak siler ve hiç içinde bir şey olmamış gibi boş bir kasa açar.';

  @override
  String get panicStatusOn => 'Belirlendi';

  @override
  String get panicStatusOff => 'Belirlenmedi';

  @override
  String get panicSet => 'Panik kodu belirle';

  @override
  String get panicChange => 'Panik kodunu değiştir';

  @override
  String get panicRemove => 'Panik kodunu kaldır';

  @override
  String get panicCreateTitle => 'Bir panik kodu seçin';

  @override
  String get panicCreateHint =>
      'Dört hane. Bu kodu girerken gören herkes Kilit\'i silebilir.';

  @override
  String get panicConfirmTitle => 'Panik kodunu tekrar girin';

  @override
  String get panicMismatch => 'Kodlar eşleşmedi. Baştan başlayın.';

  @override
  String get panicSaved => 'Panik kodu belirlendi.';

  @override
  String get panicRemoved => 'Panik kodu kaldırıldı.';

  @override
  String get panicRejected => 'Bu kod kullanılamaz. Başka bir kod seçin.';

  @override
  String get keptInVault => 'Kasaya kaydedildi.';

  @override
  String get alreadyInVault => 'Zaten kasada.';

  @override
  String get keptTitleFallback => 'Mesaj';

  @override
  String get devBanner => 'Geliştirme çekirdeği: gerçek şifreleme yok.';

  @override
  String get lockTitleUnlock => 'Kilidi aç';

  @override
  String get lockTitleCreate => 'Bir PIN belirle';

  @override
  String get lockTitleConfirm => 'PIN\'i tekrar gir';

  @override
  String get lockHintUnlock => 'Kasanı açmak için PIN\'ini gir.';

  @override
  String lockHintCreate(int min) {
    return 'En az $min rakam. Unutursan kasan açılamaz: kurtarma yolu yok.';
  }

  @override
  String get lockHintConfirm => 'Aynı PIN\'i bir kez daha gir.';

  @override
  String get lockMismatch => 'PIN\'ler eşleşmedi. Baştan başla.';

  @override
  String get lockWrongPin => 'PIN yanlış.';

  @override
  String lockWait(int seconds) {
    return 'Tekrar denemek için $seconds sn bekle.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count rakam girildi';
  }

  @override
  String get pinDelete => 'Sil';

  @override
  String get pinOk => 'Tamam';

  @override
  String get navChats => 'Sohbetler';

  @override
  String get navVault => 'Kasa';

  @override
  String get navCamera => 'Kamera';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get chatsLater => 'Tor üzerinden mesajlaşma Aşama 2\'de geliyor.';

  @override
  String get cameraLater =>
      'Diske şifresiz yazmayan kamera Aşama 2\'de geliyor.';

  @override
  String get vaultAddNote => 'Not ekle';

  @override
  String get vaultCompose => 'Taşıyıcı mesajı';

  @override
  String get vaultOpenClipboard => 'Panodan aç';

  @override
  String get vaultOpenPasted => 'Yapıştırılanı aç';

  @override
  String get vaultSealFile => 'Dosya şifrele';

  @override
  String get vaultOpenKlt => '.klt aç';

  @override
  String get vaultEmpty =>
      'Kasan boş. Bir not ekle ya da bir dosya şifrele; hepsi .klt paketi olarak saklanır.';

  @override
  String get vaultSigned => 'İmzalı';

  @override
  String get vaultFileTooLarge => 'Dosya çok büyük: en fazla 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name şifrelendi ve kasaya eklendi.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name şifrelendi ve kasaya eklendi. Kaldırılan gizli veriler: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name şifrelendi ve kasaya eklendi. Kilit bu dosya türünden gizli verileri (yazar adı gibi) kaldıramaz; paylaşmadan önce kontrol edin.';
  }

  @override
  String get damagedPictureTitle => 'Bozuk resim';

  @override
  String get damagedPictureBody =>
      'Bu resim bozuk olduğu için Kilit, çekildiği yer gibi gizli verilerini kaldıramadı. Olduğu gibi eklensin mi?';

  @override
  String get damagedPictureSeal => 'Olduğu gibi ekle';

  @override
  String get hiddenLocation => 'konum';

  @override
  String get hiddenCamera => 'kamera bilgileri';

  @override
  String get hiddenAuthorNotes => 'yazar ve notlar';

  @override
  String get hiddenExtraImages => 'ek resimler';

  @override
  String get hiddenOther => 'diğer üst veriler';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Panoda bir Kilit mesajı yok. WhatsApp\'ta mesaja uzun basıp Kopyala\'ya dokun.';

  @override
  String get clipboardBanner => 'Panoda bir Kilit mesajı var.';

  @override
  String get clipboardBannerOpen => 'Aç';

  @override
  String get clipboardBannerDismiss => 'Yok say';

  @override
  String get noteNew => 'Yeni not';

  @override
  String get noteTitle => 'Başlık';

  @override
  String get noteText => 'Not';

  @override
  String get sealAndSave => 'Şifrele ve kaydet';

  @override
  String get carrierTitle => 'Taşıyıcı mesajı';

  @override
  String get carrierIntro =>
      'Mesaj şifrelenir ve WhatsApp gibi bir uygulamaya yapıştırılacak metne çevrilir.';

  @override
  String get carrierMessage => 'Mesaj';

  @override
  String get withPassphrase => 'Ortak parola ile';

  @override
  String get carrierWithPassphraseHint =>
      'Karşı taraf aynı parolayla açar. Kapalıysa yalnızca sen açabilirsin.';

  @override
  String get passphrase => 'Ortak parola';

  @override
  String get carrierPassphraseHelper =>
      'En az 12 karakter. Parolayı bu mesajla aynı kanaldan gönderme.';

  @override
  String get carrierSeal => 'Şifrele';

  @override
  String get carrierResultIntro =>
      'Bu metni kopyalayıp gönder. Kanal yalnızca şifreli veriyi görür.';

  @override
  String carrierChars(int count) {
    return '$count karakter';
  }

  @override
  String get pasteTitle => 'Yapıştırılanı aç';

  @override
  String get pasteInput => 'Sohbetten kopyaladığın metin';

  @override
  String get pasteFromClipboard => 'Panodan yapıştır';

  @override
  String get passphraseIfAny => 'Ortak parola (varsa)';

  @override
  String get pasteOpen => 'Bul ve aç';

  @override
  String get pasteNone => 'Metinde KLT1 paketi bulunamadı.';

  @override
  String get pasteTruncated =>
      'Bir paket kesilmiş: gönderen uygulama mesajı kısaltmış olabilir.';

  @override
  String get pasteMalformed => 'Bir paket bozuk.';

  @override
  String get openWrongKey => 'Bu paket bu parolayla ya da anahtarla açılmıyor.';

  @override
  String get openDamaged => 'Bu paket bozuk ya da değiştirilmiş.';

  @override
  String get openIsFile => 'Bu paket bir dosya; .klt aç ile kasaya ekle.';

  @override
  String get packetTitle => 'Paket analizi';

  @override
  String get packetFile => 'Dosya';

  @override
  String get packetType => 'Tür';

  @override
  String get packetSize => 'Boyut';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (paket $packet)';
  }

  @override
  String get packetFormat => 'Biçim';

  @override
  String get packetFormatValue => 'KLT1 (age v1 üzerine)';

  @override
  String get packetRecipients => 'Alıcılar';

  @override
  String get packetContent => 'İçerik';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, 64 KiB parçalar';

  @override
  String get packetSignature => 'İmza';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, doğrulandı';

  @override
  String get sigUnsigned => 'İmzasız';

  @override
  String get sigInvalid => 'GEÇERSİZ';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (ortak parola)';

  @override
  String get itemOpen => 'Aç';

  @override
  String get itemView => 'Görüntüle';

  @override
  String get itemExport => '.klt olarak dışa aktar';

  @override
  String get itemSavePlain => 'Şifresiz kaydet';

  @override
  String get savePlainTitle => 'Şifresiz kaydedilsin mi?';

  @override
  String get savePlainBody =>
      'Dosya şifresi çözülmüş olarak kaydedilir. Kaydettiğin yerde kim erişebiliyorsa okuyabilir; Kilit onu artık koruyamaz.';

  @override
  String get itemDelete => 'Kasadan sil';

  @override
  String get exportTitle => '.klt olarak dışa aktar';

  @override
  String get exportIntro =>
      'Dosya yeniden şifrelenir ve kasan tarafından imzalanır. Dosya adı rastgele olur; asıl ad yalnızca şifreli paketin içinde durur.';

  @override
  String get exportWithPassphraseHint =>
      'Parolayı bilen herkes açar. Kapalıysa yalnızca senin kasan açar (yedek için).';

  @override
  String get exportPassphraseHelper =>
      'En az 12 karakter. Dosyayla aynı kanaldan gönderme.';

  @override
  String get passphraseTooShort => 'Ortak parola en az 12 karakter olmalı.';

  @override
  String get importTitle => '.klt dosyasını aç';

  @override
  String get importPassphraseHelper =>
      'Sana kendi kasanla gönderildiyse boş bırak.';

  @override
  String get importGo => 'Aç ve kasaya ekle';

  @override
  String importAddedSigned(String name) {
    return '$name kasaya eklendi (imzalı).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name kasaya eklendi (imzasız).';
  }

  @override
  String get importWrongKey => 'Bu dosya bu parolayla ya da kasanla açılmıyor.';

  @override
  String get importNotKlt => 'Bu bir .klt dosyası değil.';

  @override
  String get importDamaged => 'Dosya bozuk ya da değiştirilmiş.';

  @override
  String get settingsProtections => 'Korumaların';

  @override
  String get protPin => 'PIN koruması';

  @override
  String get protScreenshots => 'Ekran görüntüsü engeli';

  @override
  String get protScreenshotsValue => 'Açık, her ekranda';

  @override
  String get protAutoLock => 'Otomatik kilit';

  @override
  String get protAutoLockValue => 'Uygulamadan çıkınca';

  @override
  String get protNetwork => 'Tor bağlantısı';

  @override
  String get protNetworkValue =>
      'Bağlı değil: Aşama 1 ağa hiç çıkmaz. Tor Aşama 2\'de gelecek.';

  @override
  String get hwStrongbox => 'StrongBox güvenlik çipi';

  @override
  String get hwTee => 'Güvenli işlem ortamı (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (donanımsız)';

  @override
  String get hwSoftwareFile => 'Yazılım anahtarı (kasanın yanında)';

  @override
  String get hwNone => 'Yok';

  @override
  String get hwDev => 'Yok (geliştirme çekirdeği)';

  @override
  String get hwBoundHint =>
      'PIN bu cihazın donanım anahtarına bağlı. Kasa dosyası kopyalansa bile başka bir cihazda denenemez.';

  @override
  String get hwNotBoundHint =>
      'Donanım anahtarı yok: kasa dosyası kopyalanırsa PIN başka bir cihazda tahmin edilebilir.';

  @override
  String get settingsFingerprint => 'Güvenlik numaran';

  @override
  String get settingsFingerprintHint =>
      'Bir kişiyi doğrularken iki cihazda da aynı olmalı.';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Aydınlık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get settingsPrivacy => 'Gizlilik';

  @override
  String get clipboardCheck => 'Panodaki Kilit mesajını öner';

  @override
  String get clipboardCheckHint =>
      'Kasa açılınca panoda bir KLT1: mesajı varsa açmayı önerir. Android panonun okunduğunu bir bildirimle gösterir.';

  @override
  String get settingsPermissions => 'İzinler';

  @override
  String get permIntro => 'Kilit şu an hiçbir hassas izin kullanmıyor.';

  @override
  String get permCamera => 'Kamera';

  @override
  String get permCameraValue => 'Kullanılmıyor (kamera Aşama 2\'de)';

  @override
  String get permNotifications => 'Bildirimler';

  @override
  String get permNotificationsValue => 'Kullanılmıyor';

  @override
  String get permInternet => 'İnternet';

  @override
  String get permInternetValue => 'Yok: Aşama 1 çevrimdışı çalışır';

  @override
  String get permOpenSystem => 'Sistem izin ayarlarını aç';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get aboutVersion => 'Sürüm';

  @override
  String get aboutLicense => 'Lisans';

  @override
  String get aboutAlpha =>
      'Bağımsız bir denetimden geçmedi. Alfa sürüm: denemek için uygun, yüksek riskli kullanım için değil.';
}
