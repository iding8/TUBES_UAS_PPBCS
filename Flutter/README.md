# KlinikKu - Flutter Mobile App (REST API Client)

Versi ini sudah disesuaikan dengan arsitektur di `arsitektur_klinik.pptx`:

```
Flutter (Presentation Layer)  --HTTP/JSON-->  Laravel REST API (Application Layer)  --SQL/ORM-->  MySQL (Data Layer)
```

## Perubahan dari versi sebelumnya
- **Dihapus**: `sqflite`, `path`, `path_provider`, `database_helper.dart`, `database_viewer_page.dart` (data tidak lagi disimpan lokal di HP).
- **Ditambahkan**:
  - `http` untuk memanggil REST API Laravel
  - `shared_preferences` untuk menyimpan token Sanctum di HP
  - Halaman **Login** & **Register** (wajib login sebagai petugas/admin sebelum bisa akses data — sesuai bubble "Auth Petugas" di PPT)
  - Tombol **Logout** di AppBar
- Semua CRUD (Pasien, Dokter, Jadwal, Antrian, Rekam Medis) sekarang memanggil endpoint `/api/...` di Laravel, bukan database lokal.
- Field nama disesuaikan dengan kolom Laravel (`tanggal_lahir`, `jenis_kelamin`, `no_telepon`, `nomor_antrian`, `waktu_daftar`, dst).
- `id` sekarang `int` (auto-increment dari MySQL), bukan lagi string timestamp.
- Fitur TTS (Text-to-Speech) panggilan antrian tetap dipertahankan di halaman Antrian.

## Langkah Menjalankan

1. **Jalankan Laravel API-nya dulu** (dari folder `tubes-uas`):
   ```
   php artisan serve
   ```
   Pastikan sudah `php artisan migrate` dan ada minimal 1 akun (bisa lewat `/api/register` atau seeder).

2. **Ganti Base URL API** di `lib/config/api_config.dart`:
   - Emulator Android + Laravel di laptop yang sama → `http://10.0.2.2:8000/api`
   - HP fisik (WiFi sama dengan laptop) → `http://<IP-lokal-laptop>:8000/api`
   - Sudah online/hosting → `https://domainkamu.com/api`

3. Install dependency:
   ```
   flutter pub get
   ```

4. Jalankan aplikasi:
   ```
   flutter run
   ```

5. Buat akun petugas via halaman **Daftar** (atau lewat Postman ke `POST /api/register`), lalu login.

## Struktur Folder
```
lib/
  config/api_config.dart        -> alamat base URL API
  services/
    api_client.dart              -> wrapper HTTP + token Sanctum
    auth_service.dart             -> login/register/logout/me
    pasien_service.dart, dokter_service.dart, jadwal_service.dart,
    antrian_service.dart, rekam_medis_service.dart
  models/                        -> Pasien, Dokter, JadwalPemeriksaan, Antrian, RekamMedis, Petugas
  pages/
    login_page.dart, register_page.dart
    home_page.dart                -> shell bottom navigation
    pasien_page.dart, dokter_page.dart, jadwal_page.dart,
    antrian_page.dart, rekam_medis_page.dart
  main.dart
```

## Catatan
- Assets font (`Poppins`) dan `assets/1.jpeg` **tidak disertakan** dalam paket ini — copy ulang dari project lama kamu ke folder `assets/` dan `assets/font/` sebelum build, atau hapus referensinya di `pubspec.yaml` jika tidak dipakai.
