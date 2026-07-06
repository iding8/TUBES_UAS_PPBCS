import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Exception khusus untuk error yang datang dari API.
class ApiException implements Exception {
  final String message;
  final bool unauthorized;
  ApiException(this.message, {this.unauthorized = false});

  @override
  String toString() => message;
}

/// Client HTTP sederhana untuk berkomunikasi dengan REST API Laravel.
/// Menyimpan token Sanctum di SharedPreferences supaya user tidak perlu
/// login ulang setiap membuka aplikasi.
class ApiClient {
  static const String baseUrl = ApiConfig.baseUrl;
  static String? _token;

  /// Dipanggil sekali saat aplikasi pertama kali dibuka (lihat main.dart)
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static bool get isLoggedIn => _token != null;

  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> get(String endpoint) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi/alamat API.');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi/alamat API.');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi/alamat API.');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi/alamat API.');
    }
  }

  static dynamic _handle(http.Response res) {
    Map<String, dynamic> decoded = {};
    try {
      if (res.body.isNotEmpty) {
        decoded = jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // body bukan JSON valid
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    if (res.statusCode == 401) {
      throw ApiException(
        decoded['message'] ?? 'Sesi berakhir, silakan login kembali',
        unauthorized: true,
      );
    }

    if (res.statusCode == 422) {
      // Error validasi Laravel: {"message": "...", "errors": {...}}
      final errors = decoded['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final firstError = errors.values.first;
        final msg = firstError is List ? firstError.first.toString() : firstError.toString();
        throw ApiException(msg);
      }
      throw ApiException(decoded['message'] ?? 'Data tidak valid');
    }

    throw ApiException(decoded['message'] ?? 'Terjadi kesalahan (${res.statusCode})');
  }
}
