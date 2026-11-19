# Laporan redesign Soft Edu Dashboard

Tanggal: 18 November 2026.

## Ringkasan

Redesign hanya mengubah presentasi UI/UX. Identitas sage green `#8BAF91`,
background `#F7F9F6`, permukaan putih, border lembut, radius 14–22 px,
tipografi sistem, serta jarak komponen diterapkan melalui tema Material 3
berbasis `ColorScheme.fromSeed`. Satu konstanta `kSeedColor` tetap berada
di `lib/main.dart`. Tidak ada dependency, font asset, ilustrasi, animasi,
halaman, atau fitur baru.

## Perubahan setiap layar

| Layar / komponen | Perubahan visual |
| --- | --- |
| Login | Identitas aplikasi minimalis, judul dan deskripsi yang jelas, form dalam kartu putih, input rounded berikon, tombol sage dan tautan Daftar. |
| Register | Header dan kartu form mengikuti Login; hanya tiga input semula. |
| Home | Hierarki Beranda, profil akun berwarna sage lembut, bagian presensi utama, tanggal Indonesia, dan tampilan tiga status. Tombol Masuk/Pulang tetap ditentukan oleh record yang sama. Riwayat dan Keluar tetap tersedia. |
| History | Kartu tanggal berikon, informasi waktu dan durasi berjenjang, thumbnail rounded, serta empty state berikon dengan pesan asli. |
| Photo Viewer | Latar gelap bernuansa hijau, judul kontras, SafeArea, dan placeholder lembut. Tampilan layar penuh dan zoom tetap tersedia. |
| Config Error | Tema yang sama, langkah setup dengan jarak lebih nyaman, serta pesan error asli dalam panel berwarna lembut. Semua instruksi konfigurasi tetap ada. |
| Dialog | Bentuk rounded, tema tombol yang konsisten, dan ikon kontekstual untuk keluar/izin kamera. Isi, tombol, dan tindakan tetap dipertahankan. |
| Responsivitas | Lebar konten dibatasi pada layar besar, konten dapat digulir, label input berpindah ke atas pada layar sempit/teks besar, dan thumbnail disusun vertikal bila diperlukan. |

## Daftar file yang diubah

| File | Perubahan |
| --- | --- |
| `lib/main.dart` | Seed sage dan fungsi tema bersama `buildAppTheme`. |
| `lib/screens/auth/login_screen.dart` | Layout autentikasi dan kartu form. |
| `lib/screens/auth/register_screen.dart` | Layout registrasi yang konsisten. |
| `lib/screens/auth/widgets/auth_text_field.dart` | Ikon input, label responsif, dan header visual bersama `AuthHeader`. |
| `lib/screens/home/home_screen.dart` | Susunan dashboard, hierarki, jarak, dan lebar responsif. |
| `lib/screens/home/widgets/profile_card.dart` | Kartu akun dengan ikon dan email yang dapat membungkus. |
| `lib/screens/home/widgets/attendance_card.dart` | Kartu tiga status, tanggal, waktu, durasi, dan thumbnail responsif. |
| `lib/screens/home/widgets/action_button.dart` | Ukuran minimum tombol tanpa tinggi tetap yang memotong teks besar. |
| `lib/screens/home/widgets/camera_button.dart` | Ikon pada kedua dialog izin; alur kamera tidak diubah. |
| `lib/screens/home/widgets/logout_dialog.dart` | Ikon keluar; tindakan dan pesan tetap sama. |
| `lib/screens/home/widgets/photo_viewer.dart` | Presentasi viewer dan placeholder; pembacaan file/Base64 tidak diubah. |
| `lib/screens/history/history_screen.dart` | Lebar, padding, SafeArea, dan empty state. |
| `lib/screens/history/widgets/record_card.dart` | Tata letak informasi dan thumbnail responsif. |
| `lib/screens/config_error/config_error_screen.dart` | Tema bersama dan presentasi instruksi/error. |
| `test/widgets/redesign_layout_test.dart` (baru) | Enam tes UI tanpa Firebase/kamera nyata. |
| `docs/UI_UX_REDESIGN_REPORT.md` (baru) | Laporan ini. |

Perubahan Firebase/Android, `firebase.json`, dan `package-lock.json` yang
sudah ada sebelum pekerjaan ini tidak disentuh.

## Perlindungan PRD

- Dokumen PRD tidak diubah.
- Model, seluruh service, `AuthWrapper`, `pubspec.yaml`, dan `pubspec.lock`
  tidak diubah, diverifikasi melalui Git diff.
- Kode sebelum metode `build` pada Login, Register, dan Home sama persis
  dengan versi HEAD. Validasi, autentikasi, loading, penanganan error,
  langganan stream, lifecycle, dan proses Masuk/Pulang tetap dipertahankan.
- UID, kontrak publik, penyimpanan lokal, format JSON/tanggal/waktu,
  kewajiban foto, dan aturan satu record per pengguna per tanggal tetap sama.
- Pembacaan foto lokal, cabang Base64, fallback placeholder, serta
  `InteractiveViewer` tetap dipertahankan.
- Tes yang sudah ada tidak diubah atau dihapus.

## Hasil validasi

| Pemeriksaan | Hasil |
| --- | --- |
| `flutter analyze` | Lulus, `No issues found!`. |
| `flutter test` | Lulus, 19 tes: 13 tes sebelumnya dan 6 tes UI tambahan. |
| `flutter build apk --debug` | Lulus; hasil di `build/app/outputs/flutter-apk/app-debug.apk`. |
| Layout | Tidak ada overflow yang terdeteksi pada 320×720 dan 390×844, skala teks 100%/200%, serta form 320×640 dengan inset keyboard 280 px. |
| Navigasi foto | Tes memastikan thumbnail riwayat membuka viewer, zoom tersedia, dan placeholder tampil saat foto tidak ada. |
| Pemeriksaan visual | Render Login, Register, tiga status Home, History, Config Error, dan dialog Keluar diperiksa. Data render merupakan data uji, bukan akun/presensi nyata. |

Render pemeriksaan tersimpan di `build/ui_review/` (artefak sementara yang
dapat terhapus saat `flutter clean`): `login.png`, `register.png`,
`home-empty.png`, `home-checked-in.png`, `home-complete.png`, `history.png`,
`config.png`, dan `logout.png`. Ini bukan asset aplikasi.

## Keterbatasan

- Tidak ada perangkat Android yang terhubung saat pemeriksaan. APK berhasil
  dibangun, tetapi belum dipasang dan diuji pada perangkat nyata/emulator.
- Login/register Firebase nyata, kamera, izin biasa/permanen, pembatalan
  kamera, kompresi foto, dan persistensi setelah restart perangkat belum
  diuji secara langsung pada sesi ini.
- Pemeriksaan visual memakai render widget Flutter dengan font Roboto dari
  SDK; hasil pada perangkat dapat sedikit berbeda karena font/sistem.
- Build menampilkan peringatan kompatibilitas Kotlin Gradle Plugin dari
  `firebase_auth`, `firebase_core`, dan `flutter_image_compress_common`
  terhadap versi Flutter mendatang. Build saat ini berhasil; dependency
  tidak diubah karena pekerjaan ini dibatasi pada UI/UX.
- Perubahan belum di-commit.
