# Laporan implementasi Presensi Digital v2.0

Tanggal: 18 November 2026. Spesifikasi: seluruh PRD Frontend 2 dan ketentuan
inti PRD Frontend 1 yang tetap berlaku. Kedua dokumen PRD tidak dimodifikasi.

## Fitur yang diterapkan

| PRD | Hasil |
| --- | --- |
| FR-01 | Sapaan dan tanggal Indonesia, profil email, status/aksi presensi, tiga angka bulan berjalan, dan maksimal tiga aktivitas terbaru. Ringkasan mengikuti stream record lokal. |
| FR-02 | Statistik bulanan: hari tercatat, selesai, belum pulang, total dan rata-rata durasi. Grafik tujuh hari dengan pemilih minggu, dihitung tanpa package chart. |
| FR-03 | Kalender dengan penanda tanggal yang memiliki record, navigasi bulan, pilihan tanggal, dan filter Semua/Selesai/Belum Pulang. Record terbaru ditampilkan dahulu. |
| FR-04 | Detail berdasarkan ID record dan UID: tanggal, waktu, durasi, serta foto masuk/pulang yang dapat dibuka ke PhotoViewer. |
| FR-05 | Tambah, ubah, atau kosongkan catatan opsional melalui `updateAttendanceRecord`. Record terkini dibaca sebelum menyimpan agar catatan tidak menimpa perubahan waktu/foto. Pesan sukses hanya muncul setelah penyimpanan berhasil. |
| FR-06 | Akun aktif, jumlah record pribadi, informasi data/foto lokal dan aplikasi, serta keluar dengan konfirmasi. |
| Navigasi | Empat tujuan Material 3 NavigationBar: Beranda, Statistik, Riwayat, Akun. Detail dan foto dibuka memakai Navigator. |
| UI | Primary action `#35664B`, sage, peach/lavender untuk metrics, padding 20 px, variasi hero/metrics/timeline/chart/calendar/informasi, dan versi aplikasi `2.0.0+2`. |

## Ketentuan data dan fitur inti

- Firebase Authentication, alur login/register, validasi, foto wajib,
  dialog izin kamera, kompresi/penyimpanan foto, dan logout tetap dipakai.
- `AttendanceService`, `AuthServices`, `PhotoStorage`/`StorageServices`,
  `PermissionService`, dan adapter `FirestoreService` tidak diubah.
- Kedua model dan format JSON tidak diubah. Kunci penyimpanan tetap
  `local_attendance_records_v1`; tidak ada penyimpanan ringkasan kedua.
- Statistik/filter/detail hanya membaca record sesuai UID. UID kosong
  menghasilkan daftar turunan kosong, bukan data seluruh akun.
- `AuthWrapper` masih menggunakan stream autentikasi. Key berdasarkan UID
  mereset state layar utama ketika akun berubah. Detail memantau sesi akun
  dan menghentikan tampilan/catatan saat sesi berubah.
- Hari tanpa record tidak dianggap tidak hadir. Tidak ada status terlambat,
  GPS, admin, ekspor, cloud sync, atau fitur lain di luar PRD v2.
- Tidak menambah dependency, font asset, ilustrasi, atau backend.
  `pubspec.yaml` hanya mengubah nomor versi; `pubspec.lock` tetap sama.

## Perilaku UI

- Riwayat awal menampilkan bulan berjalan. Pilihan tanggal bisa dihapus
  dengan mengetuk tanggal yang sama atau **Tampilkan sebulan**.
- Penanda kalender mengikuti record sebenarnya, terlepas dari filter status.
- Minggu dimulai Senin. Grafik hanya menjumlahkan durasi selesai di bulan
  terpilih, termasuk ketika minggu melintasi batas bulan/tahun.
- Total durasi adalah jumlah durasi selesai; rata-rata dibagi jumlah record
  selesai. Bulan tanpa record selesai menampilkan nol.
- Konten vertikal dapat digulir. Kalender/grafik dapat digulir horizontal
  bila layar sempit atau teks diperbesar, agar label dan target sentuh tetap
  terbaca. Metrics disusun ulang ketika teks diperbesar.
- Pada teks besar, label visual NavigationBar disembunyikan agar tidak
  terpotong; ikon, tooltip, semantik tujuan, dan judul halaman tetap tersedia.
- Animasi NavigationBar 200 ms menjadi nol ketika perangkat meminta reduced
  motion. Tidak menambah animasi kompleks.

## File baru

- `lib/services/attendance_statistics.dart`
- `lib/widgets/dashboard_widgets.dart`
- `lib/screens/home/widgets/dashboard_overview.dart`
- `lib/screens/history/widgets/attendance_calendar.dart`
- `lib/screens/history/attendance_detail_screen.dart`
- `lib/screens/statistics/statistics_screen.dart`
- `lib/screens/profile/profile_screen.dart`
- `test/services/attendance_statistics_test.dart`
- `test/widgets/attendance_v2_test.dart`
- `docs/V2_IMPLEMENTATION_REPORT.md`

## File yang diperbarui untuk v2

- `lib/main.dart`: palette enhanced dan tema navigasi.
- `lib/wrapper/auth_wrapper.dart`: key layar utama per UID.
- `lib/screens/home/home_screen.dart`: dashboard dan empat navigasi utama.
- `lib/screens/history/history_screen.dart`: kalender, filter, detail.
- `lib/screens/history/widgets/record_card.dart`: aksi menuju detail.
- `test/widgets/redesign_layout_test.dart`: gulir ke record/foto setelah
  penambahan kalender; seluruh pemeriksaan foto/zoom tetap dipertahankan.
- `pubspec.yaml`: versi `2.0.0+2`, tanpa perubahan dependency.
- `README.md`: fitur v2, struktur, navigasi/filter, dan keterbatasan lokal/offline.

Perubahan redesign sebelumnya dan konfigurasi Firebase/Android yang sudah ada
di workspace dipertahankan. Tidak ada commit yang dibuat pada sesi ini.

## Validasi

| Pemeriksaan | Hasil akhir |
| --- | --- |
| Flutter Analyze | Lulus, `No issues found!`, exit 0. |
| Flutter Test | Lulus, `32 tests passed`, exit 0. |
| APK debug | Lulus, `build/app/outputs/flutter-apk/app-debug.apk`, exit 0. |
| Layout | Layar baru diuji pada 320×720 dengan teks 100%/200%; tes sebelumnya juga memeriksa 390×844 dan form dengan keyboard. Tidak ada overflow terdeteksi. |
| Render visual | Beranda, ringkasan/aktivitas, Statistik, kalender Riwayat, Akun, Detail, dan Catatan diperiksa pada 390×844 menggunakan data uji dan font SDK. |

Tes meliputi total/rata-rata, bulan kosong, bulan/tanggal/status, urutan terbaru,
minggu lintas tahun, penanda kalender, UID, tambah/ubah/kosongkan notes dan
persistensinya, kegagalan simpan notes di UI, pergantian sesi, navigasi empat tab,
empty states, stream dashboard, batas tiga aktivitas, serta layout. Seluruh
pengujian inti sebelumnya tetap dijalankan.

Perintah lokal memakai flag `--no-pub`, `--no-version-check`, dan
`--suppress-analytics` untuk menggunakan dependency terpasang serta mencegah
pemeriksaan versi/telemetri mengganggu hasil pada jaringan terbatas. Profil alat
`APPDATA`/`LOCALAPPDATA` diarahkan sementara ke `.dart_tool/` dan JDK memakai
Android Studio melalui variabel proses `JAVA_HOME`; konfigurasi mesin global
tidak diubah.

Kendala awal: akses cache/profil alat, telemetri jaringan, dan JDK yang belum
terdeteksi pada profil alat baru. Setelah penyesuaian lingkungan proses,
analisis, tes, dan build selesai berhasil. Build masih menampilkan peringatan
kompatibilitas Kotlin Gradle Plugin pada beberapa dependency untuk versi Flutter
mendatang; dependency tidak diubah dalam pekerjaan ini.

Render tersedia di `build/ui_review_v2/`: `home.png`, `home-summary.png`,
`statistics.png`, `history.png`, `profile.png`, `detail.png`, dan `notes.png`.
Ini artefak pemeriksaan, bukan asset produksi, dan dapat dihapus `flutter clean`.

## Belum diuji langsung

- Login/register Firebase nyata dan skenario sesi offline pada perangkat.
- Kamera Android, izin ditolak/permanen, pembatalan foto, dan kompresi foto
  pada perangkat nyata.
- Instalasi APK dan interaksi menyeluruh pada perangkat Android/emulator.
- Persistensi sesudah restart perangkat; persistensi model/notes diuji dengan
  mock SharedPreferences, bukan penghapusan/penyimpanan data perangkat nyata.

Data dan foto tetap lokal. Tidak ada backup cloud atau sinkronisasi perangkat;
menghapus data aplikasi dapat menghapus keduanya. Login pertama offline tidak
dijanjikan. Informasi ini juga tampil di README dan halaman Akun.
