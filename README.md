# BloodShare

BloodShare adalah aplikasi mobile berbasis Flutter dan Firebase yang digunakan untuk pendataan donor darah, pengelolaan stok darah, pengajuan donor, serta permintaan darah. Aplikasi ini memiliki dua jenis role, yaitu pengguna dan admin.

Aplikasi ini dibuat sebagai project UAS dengan tujuan membantu proses digitalisasi pendataan stok darah agar lebih mudah dipantau dan dikelola.

---

## Deskripsi Singkat

BloodShare memungkinkan pengguna untuk melihat stok darah yang tersedia, mengajukan donor darah, serta mengajukan permintaan darah untuk pasien. Admin memiliki akses untuk mengelola stok darah, melihat data pengguna, serta menyetujui atau menolak pengajuan donor dan permintaan darah.

Aplikasi ini terintegrasi dengan Firebase Authentication untuk proses login/register dan Cloud Firestore sebagai database realtime.

---

## Fitur Pengguna

- Register akun pengguna
- Login menggunakan email dan password
- Melihat stok darah yang tersedia
- Melihat detail stok darah berdasarkan golongan darah, jumlah, lokasi, dan status
- Mengajukan donor darah
- Mengajukan permintaan darah untuk pasien
- Melihat status pengajuan donor
- Melihat status permintaan darah
- Logout akun

---

## Fitur Admin

- Login sebagai admin berdasarkan role akun
- Dashboard admin dengan ringkasan data
- CRUD stok darah:
  - Tambah stok darah
  - Lihat stok darah
  - Edit stok darah
  - Hapus stok darah
- Melihat pengajuan donor dari pengguna
- Menyetujui atau menolak pengajuan donor
- Melihat permintaan darah dari pengguna
- Menyetujui atau menolak permintaan darah
- Melihat data pengguna yang terdaftar
- Logout akun

---

## Teknologi yang Digunakan

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase CLI
- FlutterFire CLI
- Android Emulator
- Visual Studio Code
- Git & GitHub

---
