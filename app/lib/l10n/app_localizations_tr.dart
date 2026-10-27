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
      'Dört haneli bir kod. Kilit ekranında PIN yerine ya da kilit düğmesine basılı tuttuktan sonra girilirse Kilit\'teki tüm anahtarları, mesajları ve dosyaları kalıcı olarak siler; Kilit yeni kurulmuş gibi baştan başlar.';

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
  String get settingsChangePin => 'PIN\'i değiştir';

  @override
  String get changePinCurrent => 'Şu anki PIN\'inizi girin';

  @override
  String get changePinNew => 'Yeni bir PIN seçin';

  @override
  String get changePinDone => 'PIN değiştirildi.';

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
  String get chatEmpty =>
      'Henüz mesaj yok. Yazdığınız ilk mesaj şifreli oturumu başlatır.';

  @override
  String get chatInput => 'Mesaj';

  @override
  String get chatSend => 'Gönder';

  @override
  String get chatNewContact =>
      'Seni eklemeden yazdı. Yanıtlamak için kabul et ya da engelle. Güvenmeden önce güvenlik numaralarını karşılaştırın.';

  @override
  String get safetyTitle => 'Güvenlik numarası';

  @override
  String safetyHint(String name) {
    return 'Bu 60 haneyi $name ile yüz yüze ya da telefonda karşılaştırın. İki telefonda da aynıysa arada kimse yoktur.';
  }

  @override
  String get attachCamera => 'Kamera';

  @override
  String get attachFile => 'Fotoğraf ya da dosya';

  @override
  String get chatFileTooLarge => 'Gönderilemeyecek kadar büyük: en fazla 5 MB.';

  @override
  String get chatDelivered => 'Teslim edildi';

  @override
  String get fileComing => 'Alınıyor…';

  @override
  String get fileToVault => 'Kasaya ekle';

  @override
  String get fileSavedVault => 'Kasaya eklendi.';

  @override
  String get timerTitle => 'Süreli mesajlar';

  @override
  String get timerHint =>
      'Bu sohbetteki yeni mesajlar bu süreden sonra iki telefondan da silinir.';

  @override
  String get timerOff => 'Kapalı';

  @override
  String get timer5m => '5 dakika';

  @override
  String get timer1h => '1 saat';

  @override
  String get timer1d => '1 gün';

  @override
  String get timer1w => '1 hafta';

  @override
  String get renewTitle => 'Kilit kimliğimi yenile';

  @override
  String get renewBody =>
      'Yeni kelimeler, yeni bir bağlantı ve yeni bir QR kod alırsın. Kişilerin seninle eskisi gibi yazışmaya devam eder; eski kimlik ve bağlantı yeni kimse için çalışmaz.';

  @override
  String get renewGo => 'Yenile';

  @override
  String renewDone(String id) {
    return 'Yeni kimliğin: @$id';
  }

  @override
  String get cameraNoCamera =>
      'Kamera açılamadı. Telefonun ayarlarından kamera iznini kontrol et.';

  @override
  String get cameraShutter => 'Fotoğraf çek';

  @override
  String get cameraRetake => 'Yeniden çek';

  @override
  String get cameraUse => 'Kullan';

  @override
  String get cameraIntro =>
      'Fotoğraflar yalnızca bellekte çekilir: telefona hiçbir şey yazılmaz ve içlerinde konum ya da kamera bilgisi olmaz.';

  @override
  String get cameraSendTo => 'Gönder…';

  @override
  String get cameraToVault => 'Kasada sakla';

  @override
  String get cameraSavedVault => 'Fotoğraf kasada saklandı.';

  @override
  String get cameraNoContacts => 'Henüz gönderilecek kişi yok.';

  @override
  String cameraSent(String name) {
    return '$name kişisine gönderildi.';
  }

  @override
  String get chatsYourKilit => 'Senin Kilit\'in';

  @override
  String get chatsSearch => 'Ara';

  @override
  String get chatsEmptyNew =>
      'Henüz kimse yok. Birini ekle ya da ona kodunu göster.';

  @override
  String get torChipReady => 'Tor hazır';

  @override
  String torChipStarting(int progress) {
    return 'Tor %$progress';
  }

  @override
  String get torChipOff => 'Tor kapalı';

  @override
  String get addTitle => 'Birini ekle';

  @override
  String get addHint =>
      'Onun kodunu tara ya da sana verdiğini yapıştır: bir bağlantı ya da bir @kimlik.';

  @override
  String get addScan => 'Onun kodunu tara';

  @override
  String get addField => 'Bir Kilit bağlantısı ya da @kimlik';

  @override
  String get addGo => 'Ekle';

  @override
  String get addSearching => 'Tor üzerinden aranıyor…';

  @override
  String get addNotFound =>
      'Bu kimlikle kimse bulunamadı. Kontrol et ya da birazdan yeniden dene.';

  @override
  String get addOffline =>
      'Henüz Tor\'a bağlı değil. \'Tor hazır\' yazana kadar bekle.';

  @override
  String get addNotInvite => 'Bu bir Kilit bağlantısı ya da @kimlik değil.';

  @override
  String get addShowMine => 'Kodumu göster';

  @override
  String get addShowMineHint => 'QR kodun, bağlantın, @kimliğin';

  @override
  String get myTitle => 'Kodum';

  @override
  String get myHint =>
      'Bu kodu, bağlantını ya da @kimliğini bilen herkes sana yazabilir. İlk mesajı, sen kabul edene kadar İstekler\'de bekler.';

  @override
  String get myCopyLink => 'Bağlantıyı kopyala';

  @override
  String myShareText(String id, String link) {
    return 'Kilit\'te beni ekle: @$id\n$link';
  }

  @override
  String get scanTitle => 'Kilit kodu tara';

  @override
  String get scanHint => 'Kamerayı QR koda tut.';

  @override
  String get requestsTitle => 'İstekler';

  @override
  String get requestsEmpty => 'İstek yok.';

  @override
  String get requestHint =>
      'Sana, seni eklemeden yazdılar. Kabul edip yanıt verene kadar onlara hiçbir şey gitmez.';

  @override
  String get requestAccept => 'Kabul et';

  @override
  String get requestDecline => 'Reddet';

  @override
  String get requestBlock => 'Engelle';

  @override
  String get chatOnRelay => 'Relay\'lerde';

  @override
  String get chatQueued => 'Ağ bekleniyor';

  @override
  String get contactRename => 'Yeniden adlandır';

  @override
  String get contactRemove => 'Kişiyi sil';

  @override
  String get contactRemoveTitle => 'Bu kişi silinsin mi?';

  @override
  String get contactRemoveBody =>
      'Oturum ve tüm sohbet silinir. Yeniden yazışmak için birbirinizi yeniden ekleyin.';

  @override
  String get contactRemoveGo => 'Sil';

  @override
  String get save => 'Kaydet';

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
  String get torOff => 'Kapalı: Kilit internete çıkmıyor.';

  @override
  String torStarting(int progress) {
    return 'Bağlanıyor… %$progress';
  }

  @override
  String get torReady => 'Tor üzerinden bağlı.';

  @override
  String get torFailed => 'Tor\'a bağlanılamadı.';

  @override
  String get torUnavailable => 'Bu cihazda henüz yok.';

  @override
  String get torSwitch => 'Tor üzerinden bağlan';

  @override
  String get torSwitchHint =>
      'Kilit ağa yalnızca Tor üzerinden çıkar. Kapalıyken çevrimdışı kalır.';

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

  @override
  String get settingsBridges => 'Tor bağlantısı';

  @override
  String get torRouteAuto => 'Otomatik';

  @override
  String get torRouteAutoHint => 'Önce doğrudan Tor; engellenirse köprülerle.';

  @override
  String get torRouteDirect => 'Doğrudan Tor';

  @override
  String get torRouteObfs4 => 'obfs4 köprüleri';

  @override
  String get torRouteObfs4Hint => 'Tor\'u engelleyen ağlar için.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'Ağır sansür için. Daha yavaş.';

  @override
  String get torRouteCustom => 'Kendi köprülerim';

  @override
  String get torRouteCustomHint =>
      'bridges.torproject.org\'dan ya da güvendiğiniz birinden köprü satırları.';

  @override
  String get torRouteLinesHint => 'Her satıra bir köprü';

  @override
  String get resend => 'Tekrar gönder';

  @override
  String get resendHint =>
      'Mesaj bir relay\'de, ama karşı telefon ulaştığını henüz bildirmedi. Kilit, ulaşana kadar bir hafta boyunca günde bir kez yeniden gönderir.';

  @override
  String get resendDone => 'Tekrar gönderildi.';
}
