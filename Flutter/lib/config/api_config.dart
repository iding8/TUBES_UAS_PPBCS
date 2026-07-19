/// Konfigurasi koneksi ke REST API Laravel.
///
/// PENTING: sesuaikan [baseUrl] dengan alamat server Laravel kamu.
/// - Jika testing di EMULATOR ANDROID & Laravel jalan di laptop yang sama
///   (php artisan serve / Laragon), gunakan: http://10.0.2.2:8000/api
/// - Jika testing di HP FISIK (device asli) yang terhubung ke WiFi yang sama
///   dengan laptop, gunakan IP lokal laptop, contoh: http://192.168.1.10:8000/api
///   (cek IP dengan `ipconfig` di Windows / `ifconfig` di Mac-Linux)
/// - Jika sudah deploy ke hosting, ganti dengan domain aslinya,
///   contoh: https://klinikku.my.id/api
class ApiConfig {
  static const String baseUrl = "http://192.168.1.170:8000/api";
}
