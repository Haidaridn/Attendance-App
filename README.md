# Presensi Digital v2.0

Attendance App adalah aplikasi Android untuk mencatat presensi pribadi. Pengguna
masuk dengan akun Firebase, mengambil foto saat **Masuk** dan **Pulang**, lalu
melihat riwayat miliknya. Data presensi dan foto disimpan lokal di perangkat.
Implementasi mengikuti PRD Frontend 2 dengan tema Soft Edu Dashboard Enhanced.

## Fitur v2

- Empat tab Material 3: Beranda, Statistik, Riwayat, dan Akun.
- Dashboard dengan status harian, tiga ringkasan bulan ini, dan maksimal tiga
  aktivitas terbaru.
- Statistik berdasarkan bulan, grafik durasi mingguan, total dan rata-rata
  durasi dari presensi selesai. Hari tanpa record tidak dianggap tidak hadir.
- Riwayat dengan kalender bertanda, navigasi bulan, dan filter status.
- Detail presensi, foto yang dapat diperbesar, serta catatan pribadi opsional.
- Catatan menggunakan record dan mekanisme penyimpanan yang sama; tidak mengubah
  waktu/foto presensi atau membuat record baru.
- Halaman akun menampilkan email, jumlah record pribadi, informasi penyimpanan,
  dan keluar dengan konfirmasi.

## Menjalankan aplikasi

Pastikan Flutter stable dan perangkat Android tersedia, lalu jalankan:

```bash
flutter doctor
flutter pub get
flutter devices
flutter run
```

Sebelum Firebase dikonfigurasi, aplikasi tetap dapat dibangun dan dibuka. Layar
**Firebase belum dikonfigurasi** akan menjelaskan langkah setup. Konfigurasikan
proyek milik Anda dengan:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=ID_PROJECT_ANDA
```

Jangan menyimpan kredensial atau `google-services.json` di repository publik.

## Identitas Android

`applicationId`: `com.example.attendance_app`

Gunakan ID tersebut ketika mendaftarkan aplikasi Android di Firebase.

## Struktur utama

```text
lib/
  models/       Model AttendanceRecord dan UserProfile
  services/     Autentikasi, presensi lokal, izin, dan penyimpanan foto
  wrapper/      Pemilih layar berdasarkan status autentikasi
  screens/
    auth/       Masuk dan daftar
    home/       Dashboard dan presensi Masuk/Pulang
    statistics/ Statistik lokal bulan dan minggu
    history/    Kalender, filter, detail, dan catatan akun aktif
    profile/    Informasi akun dan penyimpanan lokal
    config_error/ Panduan konfigurasi Firebase
  widgets/      Komponen dashboard sederhana
```

## Batasan

- Tidak ada dashboard admin atau rekap semua pengguna.
- Tidak ada GPS, QR, verifikasi wajah, shift, penggajian, izin, atau notifikasi.
- Data presensi belum disinkronkan ke Firestore.
- Tidak ada ekspor laporan atau profil cloud.
- Aplikasi ditujukan untuk Android; platform lain di luar cakupan.
- Record dan foto tersimpan lokal; menghapus data aplikasi dapat menghapus keduanya.
- Tidak ada sinkronisasi lintas perangkat atau backup cloud.
- Login pertama tidak dijanjikan bekerja offline. Riwayat dan statistik lokal
  dapat dibaca ketika pengguna memiliki sesi autentikasi yang valid.

## Penyimpanan dan statistik

`AttendanceService` memakai cache memori dan SharedPreferences dengan kunci
`local_attendance_records_v1`. `FirestoreService` tetap adapter lokal;
`PhotoStorage`/`StorageServices` tetap menyimpan foto lokal. Model dan format JSON
tidak berubah. Semua query, kalender, ringkasan, detail, dan statistik memakai UID
akun aktif. Statistik dihitung dari record, tanpa penyimpanan data ringkasan kedua.

Riwayat awalnya menampilkan bulan berjalan, terbaru lebih dahulu. Pilih bulan
lain dengan panah kalender; ketuk tanggal untuk memfilter, ketuk kembali atau
pilih **Tampilkan sebulan** untuk menghapus pilihan tanggal. Filter status dapat
digabungkan dengan pilihan tanggal. Grafik mingguan hanya menjumlahkan durasi
selesai di dalam bulan terpilih; tanda kosong bukan status ketidakhadiran.

## Validasi pengembangan

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Tes otomatis tidak memakai akun Firebase, kamera, atau izin perangkat nyata.
Hasil pemeriksaan v2 dan keterbatasan perangkat dilaporkan terpisah di `docs/`.
