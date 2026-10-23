# engine-tor

Android için gömülü Tor ve köprüler (obfs4, snowflake, webtunnel). Kryfo'nun
Go motorundan alınacak (bkz. `NOTICE`). Mesaj kriptografisi burada değil,
Rust çekirdeğindedir.

Windows'ta bu motor kullanılmaz. Ağ geçidi bölmesi, Tor Project'in Expert
Bundle'ındaki `tor.exe` dosyasını ayrı bir alt süreç olarak çalıştırır.

Araç zinciri: Go 1.26.9 (Kryfo'nun yamalı vendor ağacıyla test edilmiş sürüm).
