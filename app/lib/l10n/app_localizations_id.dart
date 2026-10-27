// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class LId extends L {
  LId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get copy => 'Salin';

  @override
  String get copied => 'Disalin';

  @override
  String get share => 'Bagikan';

  @override
  String get lockNow => 'Kunci sekarang';

  @override
  String get panicTooltip => 'Ketuk untuk mengunci, tahan untuk kode panik';

  @override
  String get panicNoCode => 'Atur kode panik di Setelan terlebih dahulu.';

  @override
  String get panicEnterTitle => 'Kode panik';

  @override
  String get panicEnterHint =>
      'Masukkan kode panik untuk menghapus semua isi Kilit.';

  @override
  String get panicWrong => 'Itu bukan kode panik.';

  @override
  String get settingsPanic => 'Kode panik';

  @override
  String get panicExplain =>
      'Empat digit. Jika dimasukkan di layar kunci sebagai ganti PIN, atau setelah menahan tombol kunci, kode ini menghapus selamanya semua kunci, pesan, dan file di Kilit, lalu Kilit mulai dari awal seperti baru dipasang.';

  @override
  String get panicStatusOn => 'Diatur';

  @override
  String get panicStatusOff => 'Belum diatur';

  @override
  String get panicSet => 'Atur kode panik';

  @override
  String get panicChange => 'Ubah kode panik';

  @override
  String get panicRemove => 'Hapus kode panik';

  @override
  String get panicCreateTitle => 'Pilih kode panik';

  @override
  String get panicCreateHint =>
      'Empat digit. Siapa pun yang melihat Anda memasukkannya dapat menghapus Kilit.';

  @override
  String get panicConfirmTitle => 'Ulangi kode panik';

  @override
  String get panicMismatch => 'Kode tidak cocok. Mulai lagi.';

  @override
  String get panicSaved => 'Kode panik diatur.';

  @override
  String get panicRemoved => 'Kode panik dihapus.';

  @override
  String get panicRejected => 'Kode ini tidak bisa dipakai. Pilih yang lain.';

  @override
  String get keptInVault => 'Disimpan di brankas.';

  @override
  String get alreadyInVault => 'Sudah ada di brankas.';

  @override
  String get keptTitleFallback => 'Pesan';

  @override
  String get devBanner => 'Inti pengembangan: tanpa enkripsi sungguhan.';

  @override
  String get lockTitleUnlock => 'Buka kunci';

  @override
  String get lockTitleCreate => 'Pilih PIN';

  @override
  String get lockTitleConfirm => 'Masukkan PIN lagi';

  @override
  String get lockHintUnlock => 'Masukkan PIN untuk membuka brankas Anda.';

  @override
  String lockHintCreate(int min) {
    return 'Minimal $min digit. Jika Anda lupa, brankas tidak bisa dibuka: tidak ada pemulihan.';
  }

  @override
  String get lockHintConfirm => 'Masukkan PIN yang sama sekali lagi.';

  @override
  String get lockMismatch => 'PIN tidak cocok. Mulai lagi.';

  @override
  String get lockWrongPin => 'PIN salah.';

  @override
  String get settingsChangePin => 'Ubah PIN';

  @override
  String get changePinCurrent => 'Masukkan PIN Anda saat ini';

  @override
  String get changePinNew => 'Pilih PIN baru';

  @override
  String get changePinDone => 'PIN diubah.';

  @override
  String lockWait(int seconds) {
    return 'Tunggu $seconds detik sebelum mencoba lagi.';
  }

  @override
  String pinDigitsEntered(int count) {
    return '$count digit dimasukkan';
  }

  @override
  String get pinDelete => 'Hapus';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Obrolan';

  @override
  String get navVault => 'Brankas';

  @override
  String get navCamera => 'Kamera';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get chatEmpty =>
      'Belum ada pesan. Pesan pertama yang Anda tulis memulai sesi terenkripsi.';

  @override
  String get chatInput => 'Pesan';

  @override
  String get chatSend => 'Kirim';

  @override
  String get chatNewContact =>
      'Menulis kepadamu tanpa ditambahkan. Terima untuk membalas, atau blokir. Bandingkan nomor keamanan sebelum mempercayainya.';

  @override
  String get safetyTitle => 'Nomor keamanan';

  @override
  String safetyHint(String name) {
    return 'Bandingkan 60 digit ini dengan $name, secara langsung atau lewat telepon. Jika sama di kedua ponsel, tidak ada siapa pun di antara kalian.';
  }

  @override
  String get attachCamera => 'Kamera';

  @override
  String get attachFile => 'Foto atau file';

  @override
  String get chatFileTooLarge => 'Terlalu besar untuk dikirim: maksimal 5 MB.';

  @override
  String get chatDelivered => 'Terkirim';

  @override
  String get fileComing => 'Menerima…';

  @override
  String get fileToVault => 'Tambahkan ke brankas';

  @override
  String get fileSavedVault => 'Ditambahkan ke brankas.';

  @override
  String get timerTitle => 'Pesan sementara';

  @override
  String get timerHint =>
      'Pesan baru di obrolan ini hilang setelah waktu ini, di kedua ponsel.';

  @override
  String get timerOff => 'Mati';

  @override
  String get timer5m => '5 menit';

  @override
  String get timer1h => '1 jam';

  @override
  String get timer1d => '1 hari';

  @override
  String get timer1w => '1 minggu';

  @override
  String get renewTitle => 'Perbarui ID Kilit saya';

  @override
  String get renewBody =>
      'Kamu mendapat kata baru, tautan baru, dan kode QR baru. Kontakmu tetap bisa mengobrol seperti biasa; ID dan tautan lama tidak lagi berfungsi untuk orang baru.';

  @override
  String get renewGo => 'Perbarui';

  @override
  String renewDone(String id) {
    return 'ID barumu: @$id';
  }

  @override
  String get cameraNoCamera =>
      'Kamera tidak bisa dibuka. Periksa izin kamera di setelan ponsel.';

  @override
  String get cameraShutter => 'Ambil foto';

  @override
  String get cameraRetake => 'Ambil ulang';

  @override
  String get cameraUse => 'Pakai';

  @override
  String get cameraIntro =>
      'Foto diambil hanya di memori: tidak ada yang ditulis ke ponsel, dan tidak berisi lokasi atau data kamera.';

  @override
  String get cameraSendTo => 'Kirim ke…';

  @override
  String get cameraToVault => 'Simpan di brankas';

  @override
  String get cameraSavedVault => 'Foto disimpan di brankas.';

  @override
  String get cameraNoContacts => 'Belum ada kontak untuk dikirimi.';

  @override
  String cameraSent(String name) {
    return 'Terkirim ke $name.';
  }

  @override
  String get chatsYourKilit => 'Kilit kamu';

  @override
  String get chatsSearch => 'Cari';

  @override
  String get chatsEmptyNew =>
      'Belum ada siapa pun. Tambahkan seseorang, atau tunjukkan kodemu.';

  @override
  String get torChipReady => 'Tor siap';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor mati';

  @override
  String get addTitle => 'Tambah seseorang';

  @override
  String get addHint =>
      'Pindai kodenya, atau tempel yang ia berikan: tautan atau @ID.';

  @override
  String get addScan => 'Pindai kodenya';

  @override
  String get addField => 'Tautan Kilit atau @ID';

  @override
  String get addGo => 'Tambah';

  @override
  String get addSearching => 'Mencari lewat Tor…';

  @override
  String get addNotFound =>
      'Tidak ada yang ditemukan dengan ID ini. Periksa, atau coba lagi sebentar.';

  @override
  String get addOffline =>
      'Belum tersambung ke Tor. Tunggu sampai tertulis Tor siap.';

  @override
  String get addNotInvite => 'Itu bukan tautan Kilit atau @ID.';

  @override
  String get addShowMine => 'Tunjukkan kodeku';

  @override
  String get addShowMineHint => 'Kode QR, tautan, dan @ID kamu';

  @override
  String get myTitle => 'Kodeku';

  @override
  String get myHint =>
      'Siapa pun yang punya kode ini, tautanmu, atau @ID-mu bisa menulis kepadamu. Pesan pertamanya menunggu di Permintaan sampai kamu menerima.';

  @override
  String get myCopyLink => 'Salin tautan';

  @override
  String myShareText(String id, String link) {
    return 'Tambahkan aku di Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'Pindai kode Kilit';

  @override
  String get scanHint => 'Arahkan kamera ke kode QR.';

  @override
  String get requestsTitle => 'Permintaan';

  @override
  String get requestsEmpty => 'Tidak ada permintaan.';

  @override
  String get requestHint =>
      'Mereka menulis kepadamu tanpa ditambahkan. Tidak ada yang sampai ke mereka sampai kamu menerima dan membalas.';

  @override
  String get requestAccept => 'Terima';

  @override
  String get requestDecline => 'Tolak';

  @override
  String get requestBlock => 'Blokir';

  @override
  String get chatOnRelay => 'Di relay';

  @override
  String get chatQueued => 'Menunggu jaringan';

  @override
  String get contactRename => 'Ganti nama';

  @override
  String get contactRemove => 'Hapus kontak';

  @override
  String get contactRemoveTitle => 'Hapus kontak ini?';

  @override
  String get contactRemoveBody =>
      'Sesi dan seluruh percakapan dihapus. Untuk menulis lagi, saling tambahkan kembali.';

  @override
  String get contactRemoveGo => 'Hapus';

  @override
  String get save => 'Simpan';

  @override
  String get vaultAddNote => 'Tambah catatan';

  @override
  String get vaultCompose => 'Pesan pembawa';

  @override
  String get vaultOpenClipboard => 'Buka dari papan klip';

  @override
  String get vaultOpenPasted => 'Buka teks yang ditempel';

  @override
  String get vaultSealFile => 'Enkripsi file';

  @override
  String get vaultOpenKlt => 'Buka .klt';

  @override
  String get vaultEmpty =>
      'Brankas Anda kosong. Tambahkan catatan atau enkripsi file; semuanya disimpan sebagai paket .klt.';

  @override
  String get vaultSigned => 'Bertanda tangan';

  @override
  String get vaultFileTooLarge => 'File terlalu besar: maksimal 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name telah dienkripsi dan ditambahkan ke brankas.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name telah dienkripsi dan ditambahkan ke brankas. Data tersembunyi yang dihapus: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name telah dienkripsi dan ditambahkan ke brankas. Kilit tidak bisa menghapus data tersembunyi (seperti nama pembuat) dari jenis file ini; periksa dulu sebelum membagikannya.';
  }

  @override
  String get damagedPictureTitle => 'Gambar rusak';

  @override
  String get damagedPictureBody =>
      'Gambar ini rusak, jadi Kilit tidak bisa menghapus data tersembunyinya, seperti lokasi pengambilan. Tambahkan apa adanya?';

  @override
  String get damagedPictureSeal => 'Tambahkan apa adanya';

  @override
  String get hiddenLocation => 'lokasi';

  @override
  String get hiddenCamera => 'detail kamera';

  @override
  String get hiddenAuthorNotes => 'pembuat dan catatan';

  @override
  String get hiddenExtraImages => 'gambar tambahan';

  @override
  String get hiddenOther => 'metadata lain';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Tidak ada pesan Kilit di papan klip. Di WhatsApp, tekan lama pesan lalu ketuk Salin.';

  @override
  String get clipboardBanner => 'Ada pesan Kilit di papan klip.';

  @override
  String get clipboardBannerOpen => 'Buka';

  @override
  String get clipboardBannerDismiss => 'Abaikan';

  @override
  String get noteNew => 'Catatan baru';

  @override
  String get noteTitle => 'Judul';

  @override
  String get noteText => 'Catatan';

  @override
  String get sealAndSave => 'Enkripsi dan simpan';

  @override
  String get carrierTitle => 'Pesan pembawa';

  @override
  String get carrierIntro =>
      'Pesan dienkripsi dan diubah menjadi teks untuk ditempel di aplikasi seperti WhatsApp.';

  @override
  String get carrierMessage => 'Pesan';

  @override
  String get withPassphrase => 'Dengan frasa sandi bersama';

  @override
  String get carrierWithPassphraseHint =>
      'Pihak lain membukanya dengan frasa sandi yang sama. Mati: hanya Anda yang bisa membukanya.';

  @override
  String get passphrase => 'Frasa sandi bersama';

  @override
  String get carrierPassphraseHelper =>
      'Minimal 12 karakter. Jangan kirim lewat saluran yang sama dengan pesannya.';

  @override
  String get carrierSeal => 'Enkripsi';

  @override
  String get carrierResultIntro =>
      'Salin dan kirim teks ini. Saluran hanya melihat data terenkripsi.';

  @override
  String carrierChars(int count) {
    return '$count karakter';
  }

  @override
  String get pasteTitle => 'Buka teks yang ditempel';

  @override
  String get pasteInput => 'Teks yang Anda salin dari obrolan';

  @override
  String get pasteFromClipboard => 'Tempel dari papan klip';

  @override
  String get passphraseIfAny => 'Frasa sandi bersama (jika ada)';

  @override
  String get pasteOpen => 'Cari dan buka';

  @override
  String get pasteNone => 'Tidak ditemukan paket KLT1 dalam teks.';

  @override
  String get pasteTruncated =>
      'Sebuah paket terpotong: aplikasi pengirim mungkin telah memendekkan pesan.';

  @override
  String get pasteMalformed => 'Sebuah paket rusak.';

  @override
  String get openWrongKey =>
      'Paket ini tidak bisa dibuka dengan frasa sandi atau kunci ini.';

  @override
  String get openDamaged => 'Paket ini rusak atau telah diubah.';

  @override
  String get openIsFile =>
      'Paket ini berisi file; tambahkan ke brankas dengan Buka .klt.';

  @override
  String get packetTitle => 'Analisis paket';

  @override
  String get packetFile => 'File';

  @override
  String get packetType => 'Jenis';

  @override
  String get packetSize => 'Ukuran';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (paket $packet)';
  }

  @override
  String get packetFormat => 'Format';

  @override
  String get packetFormatValue => 'KLT1 (dibangun di atas age v1)';

  @override
  String get packetRecipients => 'Penerima';

  @override
  String get packetContent => 'Isi';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, potongan 64 KiB';

  @override
  String get packetSignature => 'Tanda tangan';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, terverifikasi';

  @override
  String get sigUnsigned => 'Tanpa tanda tangan';

  @override
  String get sigInvalid => 'TIDAK VALID';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (frasa sandi bersama)';

  @override
  String get itemOpen => 'Buka';

  @override
  String get itemView => 'Lihat';

  @override
  String get itemExport => 'Ekspor sebagai .klt';

  @override
  String get itemSavePlain => 'Simpan tanpa enkripsi';

  @override
  String get savePlainTitle => 'Simpan tanpa enkripsi?';

  @override
  String get savePlainBody =>
      'File disimpan dalam keadaan terdekripsi. Siapa pun yang punya akses ke lokasi penyimpanan dapat membacanya; Kilit tidak bisa lagi melindunginya.';

  @override
  String get itemDelete => 'Hapus dari brankas';

  @override
  String get exportTitle => 'Ekspor sebagai .klt';

  @override
  String get exportIntro =>
      'File dienkripsi ulang dan ditandatangani oleh brankas Anda. Nama file dibuat acak; nama aslinya tetap di dalam paket terenkripsi.';

  @override
  String get exportWithPassphraseHint =>
      'Siapa pun yang punya frasa sandi bisa membukanya. Mati: hanya brankas Anda yang bisa membukanya (untuk cadangan).';

  @override
  String get exportPassphraseHelper =>
      'Minimal 12 karakter. Jangan kirim lewat saluran yang sama dengan filenya.';

  @override
  String get passphraseTooShort => 'Frasa sandi bersama minimal 12 karakter.';

  @override
  String get importTitle => 'Buka file .klt';

  @override
  String get importPassphraseHelper =>
      'Biarkan kosong jika dikirim ke brankas Anda sendiri.';

  @override
  String get importGo => 'Buka dan tambahkan ke brankas';

  @override
  String importAddedSigned(String name) {
    return '$name ditambahkan ke brankas (bertanda tangan).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name ditambahkan ke brankas (tanpa tanda tangan).';
  }

  @override
  String get importWrongKey =>
      'File ini tidak bisa dibuka dengan frasa sandi ini atau brankas Anda.';

  @override
  String get importNotKlt => 'Ini bukan file .klt.';

  @override
  String get importDamaged => 'File rusak atau telah diubah.';

  @override
  String get settingsProtections => 'Perlindungan Anda';

  @override
  String get protPin => 'Perlindungan PIN';

  @override
  String get protScreenshots => 'Pemblokiran tangkapan layar';

  @override
  String get protScreenshotsValue => 'Aktif, di setiap layar';

  @override
  String get protAutoLock => 'Kunci otomatis';

  @override
  String get protAutoLockValue => 'Saat Anda keluar dari aplikasi';

  @override
  String get protNetwork => 'Koneksi Tor';

  @override
  String get protNetworkValue =>
      'Tidak terhubung: tahap 1 tidak pernah online. Tor hadir di tahap 2.';

  @override
  String get torOff => 'Mati: Kilit tidak tersambung ke internet.';

  @override
  String torStarting(int progress) {
    return 'Menyambung… $progress%';
  }

  @override
  String get torReady => 'Tersambung lewat Tor.';

  @override
  String get torFailed => 'Tidak dapat tersambung ke Tor.';

  @override
  String get torUnavailable => 'Belum tersedia di perangkat ini.';

  @override
  String get torSwitch => 'Sambungkan lewat Tor';

  @override
  String get torSwitchHint =>
      'Kilit menjangkau jaringan hanya lewat Tor. Jika mati, Kilit tetap luring.';

  @override
  String get hwStrongbox => 'Chip keamanan StrongBox';

  @override
  String get hwTee => 'Lingkungan eksekusi tepercaya (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (tanpa perangkat keras aman)';

  @override
  String get hwSoftwareFile => 'Kunci perangkat lunak (di samping brankas)';

  @override
  String get hwNone => 'Tidak ada';

  @override
  String get hwDev => 'Tidak ada (inti pengembangan)';

  @override
  String get hwBoundHint =>
      'PIN Anda terikat ke kunci perangkat keras perangkat ini. Bahkan salinan file brankas tidak bisa dicoba di perangkat lain.';

  @override
  String get hwNotBoundHint =>
      'Tidak ada kunci perangkat keras: jika file brankas disalin, PIN bisa ditebak di perangkat lain.';

  @override
  String get settingsFingerprint => 'Nomor keamanan Anda';

  @override
  String get settingsFingerprintHint =>
      'Saat memverifikasi kontak, nomor ini harus sama di kedua perangkat.';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get languageSystem => 'Bahasa sistem';

  @override
  String get settingsPrivacy => 'Privasi';

  @override
  String get clipboardCheck => 'Tawarkan pesan Kilit di papan klip';

  @override
  String get clipboardCheckHint =>
      'Saat brankas dibuka, menawarkan untuk membuka pesan KLT1: di papan klip. Android menampilkan pemberitahuan bahwa papan klip telah dibaca.';

  @override
  String get settingsPermissions => 'Izin';

  @override
  String get permIntro => 'Saat ini Kilit tidak memakai izin sensitif apa pun.';

  @override
  String get permCamera => 'Kamera';

  @override
  String get permCameraValue => 'Tidak dipakai (kamera hadir di tahap 2)';

  @override
  String get permNotifications => 'Notifikasi';

  @override
  String get permNotificationsValue => 'Tidak dipakai';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Tidak ada: tahap 1 bekerja secara offline';

  @override
  String get permOpenSystem => 'Buka pengaturan izin sistem';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get aboutVersion => 'Versi';

  @override
  String get aboutLicense => 'Lisensi';

  @override
  String get aboutAlpha =>
      'Belum diaudit secara independen. Alfa: cocok untuk pengujian, bukan untuk penggunaan berisiko tinggi.';

  @override
  String get settingsBridges => 'Koneksi Tor';

  @override
  String get torRouteAuto => 'Otomatis';

  @override
  String get torRouteAutoHint =>
      'Langsung ke Tor; lewat jembatan bila diblokir.';

  @override
  String get torRouteDirect => 'Langsung ke Tor';

  @override
  String get torRouteObfs4 => 'Jembatan obfs4';

  @override
  String get torRouteObfs4Hint => 'Untuk jaringan yang memblokir Tor.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'Untuk sensor berat. Lebih lambat.';

  @override
  String get torRouteCustom => 'Jembatan sendiri';

  @override
  String get torRouteCustomHint =>
      'Baris jembatan dari bridges.torproject.org atau orang yang Anda percayai.';

  @override
  String get torRouteLinesHint => 'Satu baris jembatan per baris';
}
