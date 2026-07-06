import 'api_client.dart';
import '../models/user.dart';

class AuthService {
  /// POST /api/login
  static Future<Petugas> login(String email, String password) async {
    final data = await ApiClient.post('/login', {
      'email': email,
      'password': password,
    });
    await ApiClient.saveToken(data['token']);
    return Petugas.fromJson(data['user']);
  }

  /// POST /api/register (registrasi akun petugas/admin baru)
  static Future<Petugas> register(String name, String email, String password) async {
    final data = await ApiClient.post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    await ApiClient.saveToken(data['token']);
    return Petugas.fromJson(data['user']);
  }

  /// POST /api/logout
  static Future<void> logout() async {
    try {
      await ApiClient.post('/logout', {});
    } catch (_) {
      // tetap hapus token lokal walau request logout gagal (mis. tidak ada koneksi)
    }
    await ApiClient.clearToken();
  }

  /// GET /api/me
  static Future<Petugas> me() async {
    final data = await ApiClient.get('/me');
    return Petugas.fromJson(data);
  }
}
