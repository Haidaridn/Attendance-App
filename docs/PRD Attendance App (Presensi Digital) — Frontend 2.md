# PRODUCT REQUIREMENTS DOCUMENT

## Presensi Digital — Attendance App v2.0

**Platform:** Flutter Android  
**Design Theme:** Soft Edu Dashboard Enhanced  
**Product Type:** Personal Attendance Tracking  
**Status:** Proposed PRD v2.0

---

## 1. Product Overview

Presensi Digital adalah aplikasi Android yang memungkinkan pengguna melakukan presensi masuk dan pulang menggunakan foto, memantau riwayat, serta memahami aktivitas kehadiran pribadi melalui dashboard dan statistik.

Versi 2.0 dikembangkan dari PRD 1.0 dengan memperluas fitur yang relevan, meningkatkan visual design, dan memperbaiki pengalaman pengguna.

### Product Goals

1. Mempermudah pencatatan presensi harian.
2. Memberikan visualisasi aktivitas presensi.
3. Menyediakan riwayat yang mudah ditelusuri.
4. Menghadirkan UI modern, rapi, dan konsisten.
5. Mempertahankan arsitektur Flutter yang mudah dipahami siswa.
6. Menyiapkan fondasi pengembangan berikutnya tanpa memerlukan backend tambahan.

## 2. Core Features — Dipertahankan

Seluruh fitur inti PRD 1.0 berikut tetap wajib:

- Registrasi dan login menggunakan Firebase Authentication.
- Logout dengan dialog konfirmasi.
- Presensi Masuk menggunakan foto wajib.
- Presensi Pulang menggunakan foto wajib.
- Satu record untuk satu pengguna per tanggal.
- Tiga status harian: belum masuk, sudah masuk, sudah pulang.
- Penyimpanan record secara lokal melalui SharedPreferences.
- Penyimpanan foto di direktori lokal aplikasi.
- Riwayat presensi yang terisolasi berdasarkan UID.
- PhotoViewer dengan zoom dan placeholder.
- Penanganan kegagalan kamera, izin, autentikasi, dan penyimpanan.
- ConfigErrorScreen ketika Firebase belum dikonfigurasi.

Seluruh kontrak publik service, struktur model dasar, dan ketentuan keamanan yang sudah berlaku harus tetap dipertahankan.

## 3. New Features — Version 2.0

### FR-01: Enhanced Home Dashboard

Halaman Home harus memiliki:

- Header sapaan sederhana.
- Tanggal hari ini dalam format Indonesia.
- ProfileCard yang menampilkan email akun.
- Hero AttendanceCard yang menampilkan status presensi.
- Tombol aksi Masuk/Pulang yang menonjol.
- Monthly Summary berupa tiga angka ringkasan.
- Recent Activity yang menampilkan maksimal tiga record terbaru.
- Akses menuju Riwayat dan Statistik.

Hero card harus menyesuaikan tiga status harian.

Tidak boleh memungkinkan presensi ganda pada tanggal yang sama.

### FR-02: Attendance Statistics

Tambahkan halaman Statistik dengan informasi:

- Jumlah hari yang memiliki record presensi pada bulan terpilih.
- Jumlah presensi yang sudah selesai.
- Jumlah presensi yang belum memiliki waktu pulang.
- Total durasi dari record yang sudah selesai.
- Rata-rata durasi presensi selesai.
- Grafik durasi berdasarkan hari pada minggu yang dipilih.

Seluruh statistik dihitung dari record lokal milik UID yang sedang login.

**Aturan perhitungan:**

- Record selesai adalah record dengan checkOutTime terisi.
- Total durasi menjumlahkan totalHours dari record selesai.
- Rata-rata durasi = total durasi / jumlah record selesai.
- Jika tidak ada record selesai, tampilkan nilai 0 atau empty state sesuai konteks.
- Hari tanpa record tidak otomatis dianggap tidak hadir.
- Jangan menciptakan status keterlambatan tanpa aturan jadwal yang terdefinisi.

Tidak memerlukan API analitik atau package chart eksternal.

### FR-03: Enhanced Attendance History

Perluas HistoryScreen dengan:

- Calendar view untuk memilih tanggal.
- Navigasi bulan sebelumnya dan berikutnya.
- Filter status: Semua, Selesai, Belum Pulang.
- RecordCard dengan informasi yang jelas.
- Navigasi ke AttendanceDetailScreen.

Riwayat tetap diurutkan terbaru terlebih dahulu sebagai default.

Filter hanya memengaruhi tampilan; tidak boleh mengubah atau menghapus record.

### FR-04: Attendance Detail

Tambahkan AttendanceDetailScreen untuk menampilkan:

- Tanggal presensi.
- Waktu masuk.
- Waktu pulang jika tersedia.
- Durasi jika tersedia.
- Foto masuk.
- Foto pulang jika tersedia.
- Catatan opsional.

Foto dapat diketuk untuk membuka PhotoViewer.

Data yang ditampilkan harus berasal dari record milik pengguna aktif.

### FR-05: Optional Attendance Notes

Aktifkan penggunaan field notes yang sudah tersedia pada AttendanceRecord.

Pengguna dapat menambahkan atau memperbarui catatan pribadi pada record miliknya.

Ketentuan:

- Catatan bersifat opsional.
- Tidak menggantikan kewajiban foto.
- Tidak mengubah waktu Masuk/Pulang.
- Tidak membuat record kedua.
- Disimpan menggunakan mekanisme updateAttendanceRecord.
- Kegagalan penyimpanan harus ditampilkan secara jelas.

### FR-06: User Profile

Tambahkan ProfileScreen dengan:

- Informasi email akun aktif.
- Ringkasan jumlah record pribadi.
- Informasi bahwa data presensi dan foto disimpan lokal.
- Informasi singkat aplikasi.
- Tombol logout dengan konfirmasi.

Tidak menambahkan registrasi profil Firestore atau sistem peran admin.

## 4. Navigation Structure

Gunakan empat navigasi utama:

| Menu      | Screen           |
| --------- | ---------------- |
| Beranda   | HomeScreen       |
| Statistik | StatisticsScreen |
| Riwayat   | HistoryScreen    |
| Akun      | ProfileScreen    |

Gunakan Material 3 NavigationBar.

AttendanceDetailScreen dan PhotoViewer dibuka melalui Navigator ketika diperlukan, bukan sebagai tab tambahan.

LoginScreen, RegisterScreen, dan ConfigErrorScreen tetap berada di luar navigasi utama.

## 5. UI/UX Design System

### Theme

Soft Edu Dashboard Enhanced.

### Color Tokens

- Background: `#F7F9F6`
- Surface: `#FFFFFF`
- Primary Action: `#35664B`
- Sage Accent: `#8BAF91`
- Soft Sage: `#DDE8D5`
- Soft Peach: `#F9E8CA`
- Soft Lavender: `#E6E0F8`
- Primary Text: `#24332A`
- Secondary Text: `#64748B`
- Border: `#E5EBE4`
- Error: `#DC2626`

Tetap sediakan satu konstanta seed color terpusat sesuai kebutuhan modul pembelajaran.

### Typography

Gunakan font sistem yang bersih atau Plus Jakarta Sans jika telah tersedia tanpa perlu menambah asset.

- Display: 26–30 px, bold.
- Heading: 20–24 px, semibold.
- Section title: 16–18 px, semibold.
- Body: 14–16 px.
- Caption: 12–13 px.

Gunakan skala yang adaptif terhadap pengaturan teks perangkat.

### Component Guidelines

- Radius card utama: 20–24 px.
- Radius card kecil: 14–18 px.
- Radius tombol: 14–16 px.
- Horizontal screen padding: 20 px.
- Spacing system: kelipatan 4 atau 8 px.
- Touch target interaktif minimal sekitar 48 × 48 dp.
- Shadow sangat ringan.
- Border hanya digunakan bila membantu hierarki.
- Ikon menggunakan Material Icons.

### Visual Variety Rules

Jangan menggunakan card dengan tampilan identik untuk seluruh konten.

Gunakan variasi yang konsisten:

1. **Hero Card:** untuk status utama dan tombol aksi.
2. **Metric Card:** untuk ringkasan numerik.
3. **Timeline Row:** untuk aktivitas terakhir.
4. **Chart Surface:** untuk statistik.
5. **Calendar Panel:** untuk navigasi tanggal.
6. **Information Group:** untuk informasi profil.

Variasi warna harus memiliki tujuan visual, bukan dekorasi acak.

### Motion

Animasi ringan diizinkan pada v2.0:

- Pergantian status card.
- Perpindahan tab.
- Perubahan filter.
- Munculnya konten setelah loading.

Durasi animasi direkomendasikan 150–250 ms. Hormati preferensi reduced motion perangkat.

Jangan menambahkan animasi kompleks, ilustrasi eksternal, atau gambar dekoratif yang tidak diperlukan.

## 6. Page Layout Specifications

### HomeScreen

Urutan layout:

1. Greeting Header
2. Profile Summary
3. Hero Attendance Status
4. Primary Attendance Action
5. Monthly Summary
6. Recent Activity
7. Bottom Navigation

Status dan aksi presensi harus tetap menjadi fokus visual utama.

### StatisticsScreen

Urutan layout:

1. Header Statistik
2. Month Selector
3. Monthly Metrics
4. Weekly Duration Chart
5. Total & Average Duration Summary
6. Empty State jika data tidak tersedia

### HistoryScreen

Urutan layout:

1. Page Header
2. Month Calendar
3. Status Filter Chips
4. Attendance Record List
5. Empty/Error State

### ProfileScreen

Urutan layout:

1. Account Header
2. Email Information
3. Personal Record Summary
4. Local Storage Information
5. About Application
6. Logout Action

## 7. Technical Architecture

Gunakan Flutter Material 3 dan Navigator bawaan.

Pertahankan pola:

**Screen → Service → Local Storage**

Ketentuan wajib:

- AuthServices tetap menggunakan Firebase Authentication.
- AttendanceService tetap menggunakan SharedPreferences dan cache memori.
- FirestoreService tetap menjadi adapter lokal sesuai implementasi awal.
- PhotoStorage dan StorageServices tetap menggunakan foto lokal.
- Stream AttendanceService tetap dapat digunakan oleh banyak pendengar dan mengirim data terkini.
- Semua data tetap difilter menggunakan UID pengguna aktif.
- Tidak menambahkan Cloud Firestore atau Firebase Storage.
- Tidak menambahkan Provider, Riverpod, Bloc, GetX, atau router eksternal.
- Tidak mengubah nama file/kelas dan signature publik yang sudah dikunci PRD 1.0.
- File baru hanya digunakan untuk fitur v2.0 yang disetujui.

Screen baru yang diperbolehkan:

- statistics_screen.dart
- profile_screen.dart
- attendance_detail_screen.dart

Widget reusable tambahan diperbolehkan selama tetap sederhana dan mudah dipelajari.

## 8. Data & Persistence Rules

Pertahankan model AttendanceRecord dan UserProfile beserta format JSON yang sudah berlaku.

Kunci SharedPreferences untuk record tetap:

`local_attendance_records_v1`

Field notes yang sudah tersedia dapat digunakan untuk fitur catatan.

Aturan:

- Jangan mengubah ID record saat pulang atau memperbarui catatan.
- Jangan membuat record baru saat memperbarui catatan.
- Jangan mengubah format waktu ISO 8601.
- Jangan mengubah key JSON yang sudah ada.
- Jangan menggunakan UID kosong untuk membaca semua record.
- Jangan menampilkan keberhasilan jika penyimpanan gagal.

Data Statistik, Calendar, dan Dashboard harus diturunkan dari AttendanceRecord, bukan disimpan sebagai data duplikat.

## 9. Authentication & Attendance Flow

Alur autentikasi tetap mengikuti PRD awal.

Alur presensi:

1. Pengguna menekan Masuk atau Pulang.
2. Aplikasi meminta izin kamera jika diperlukan.
3. Kamera dibuka.
4. Pengguna mengambil foto.
5. Foto dikompres dan disimpan lokal.
6. Record dibuat atau diperbarui.
7. UI menampilkan status terbaru.

Jika foto dibatalkan, tidak ada perubahan record.

Jika izin atau penyimpanan gagal, tampilkan pesan kesalahan yang jelas.

Tombol harus nonaktif selama proses berlangsung untuk mencegah pemanggilan ganda.

## 10. Offline & Data Limitations

Data presensi dan foto tetap bersifat lokal.

Riwayat dan statistik dapat ditampilkan dari data yang telah tersimpan ketika pengguna memiliki sesi autentikasi yang valid.

Namun:

- Aplikasi tidak menjanjikan login pertama secara offline.
- Tidak ada sinkronisasi lintas perangkat.
- Tidak ada backup cloud.
- Menghapus data aplikasi dapat menghapus record dan foto lokal.

Keterbatasan ini harus dijelaskan secara jujur pada README dan informasi aplikasi.

## 11. Testing Requirements

Pertahankan semua pengujian inti PRD 1.0.

Tambahkan pengujian:

- Perhitungan total dan rata-rata durasi.
- Statistik bulan kosong.
- Filter record berdasarkan bulan.
- Filter status selesai dan belum pulang.
- Pengurutan riwayat terbaru.
- Kalender menandai tanggal sesuai record.
- Penambahan dan perubahan notes.
- Isolasi data antar-UID.
- Navigasi utama.
- Empty states.
- Widget tidak overflow pada ukuran layar yang diuji.

Pengujian Firebase, kamera, dan permission pada perangkat asli harus dilaporkan terpisah apabila belum dijalankan.

Perintah validasi wajib:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Jangan mengklaim pengujian berhasil jika belum dijalankan.

## 12. Acceptance Criteria

Aplikasi v2.0 diterima apabila:

1. Semua fitur inti PRD 1.0 tetap bekerja.
2. Masuk/Pulang tetap membutuhkan foto.
3. Tidak ada record harian duplikat.
4. Statistik sesuai dengan data record aktual.
5. Hari kosong tidak otomatis dianggap tidak hadir.
6. Filter riwayat menghasilkan data yang sesuai.
7. Detail record menampilkan foto dan informasi yang benar.
8. Catatan dapat disimpan tanpa membuat record kedua.
9. Akun lain tidak dapat membaca data pengguna sebelumnya.
10. Dashboard mengikuti perubahan data presensi.
11. Seluruh layar menggunakan Soft Edu Dashboard Enhanced secara konsisten.
12. Navigasi dan tombol berfungsi.
13. Tidak ada overflow yang terdeteksi.
14. Kegagalan penyimpanan dan autentikasi ditangani dengan benar.
15. Pengujian otomatis dan build dilaporkan secara transparan.

## 13. Explicitly Out of Scope

Fitur berikut belum termasuk v2.0:

- Admin dashboard.
- GPS dan geofencing.
- QR attendance.
- Face recognition.
- Verifikasi biometrik.
- Firebase Storage.
- Sinkronisasi Firestore.
- Rekap seluruh pengguna.
- Penggajian.
- Shift management.
- Sistem pengajuan izin.
- Export PDF/CSV.
- Push notifications.
- Sistem keterlambatan berbasis jadwal.
- Dark mode.

Fitur tersebut dapat dievaluasi dalam versi berikutnya, tetapi tidak boleh ditambahkan tanpa persetujuan.

## 14. Implementation Priorities

### Phase 1 — UI Foundation

Theme, typography, spacing, reusable visual components, dan autentikasi.

### Phase 2 — Home Dashboard

Hero AttendanceCard, monthly summary, recent activity, dan status harian.

### Phase 3 — Statistics

Service/helper perhitungan statistik, metrics UI, dan grafik.

### Phase 4 — History Enhancement

Calendar, filter, detail presensi, dan catatan opsional.

### Phase 5 — Profile & Navigation

ProfileScreen serta navigasi utama.

### Phase 6 — Quality Assurance

Tests, responsive validation, APK build, dan pembaruan README.

## 15. Agent Implementation Rules

Sebelum mengubah kode, agent wajib:

1. Membaca PRD 1.0 dan dokumen v2.0 ini.
2. Mengidentifikasi semua ketentuan lama yang tetap berlaku.
3. Mengidentifikasi fitur baru yang secara eksplisit disetujui pada v2.0.
4. Menyiapkan implementasi bertahap.
5. Menjaga kontrak service serta model lama.
6. Tidak menambahkan fitur di luar versi ini.
7. Tidak menyembunyikan error atau kegagalan testing.

Jika PRD 1.0 melarang fitur yang sekarang secara eksplisit ditambahkan di PRD 2.0, ketentuan v2.0 berlaku khusus pada perubahan tersebut.

Ketentuan keamanan, penyimpanan, autentikasi, dan integritas data dari PRD 1.0 tetap berlaku.

**Final Objective:**

Develop a more complete and visually polished Attendance App while preserving its original attendance workflow, understandable Flutter architecture, and reliable local data handling.
