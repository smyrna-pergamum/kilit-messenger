# Gizlilik

- Hesap, telefon numarası ve e-posta istenmez. Rehber yüklenmez.
- Analitik, çökme raporu ve reklam yoktur.
- Kilit'in kendi sunucusu yoktur. Bağlanılan açık relay'ler `docs/RELAYS.md` dosyasında listelenmiştir. Bu relay'ler posta kutusu adreslerini, mesaj zamanlarını ve boyut sınıfını görür. Tor üzerinden bağlanıldığı için IP adresinizi görmez.
- Güncelleme kontrolü, GitHub Releases'teki imzalı bir dosyayı Tor üzerinden okur.
