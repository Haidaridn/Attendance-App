# Presensi Digital

Attendance App adalah aplikasi Android untuk mencatat presensi pribadi. Pengguna
masuk dengan akun Firebase, mengambil foto saat **Masuk** dan **Pulang**, lalu
melihat riwayat miliknya. Data presensi dan foto disimpan lokal di perangkat.

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
    home/       Presensi Masuk/Pulang
    history/    Riwayat akun aktif
    config_error/ Panduan konfigurasi Firebase
```

## Batasan

- Tidak ada dashboard admin atau rekap semua pengguna.
- Tidak ada GPS, QR, verifikasi wajah, shift, penggajian, izin, atau notifikasi.
- Data presensi belum disinkronkan ke Firestore.
- Tidak ada filter tanggal, ekspor laporan, atau profil cloud.
- Aplikasi ditujukan untuk Android; platform lain di luar cakupan.
- Foto tersimpan lokal dan akan hilang jika data aplikasi dihapus.
