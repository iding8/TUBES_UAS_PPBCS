import 'api_client.dart';
import '../models/user.dart';

class AuthService {
  /// User yang sedang login, di-cache di memori supaya halaman manapun
  /// bisa cek role tanpa perlu request ulang ke /me.
  static Petugas? currentUser;

  /// POST /api/login
  static Future<Petugas> login(String email, String password) async {
    final data = await ApiClient.post('/login', {
      'email': email,
      'password': password,
    });
    await ApiClient.saveToken(data['token']);
    final user = Petugas.fromJson(data['user']);
    currentUser = user;
    return user;
  }

  /// POST /api/register (registrasi akun petugas/admin baru)
  static Future<Petugas> register(String name, String email, String password) async {
    final data = await ApiClient.post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    await ApiClient.saveToken(data['token']);
    final user = Petugas.fromJson(data['user']);
    currentUser = user;
    return user;
  }

  /// POST /api/logout
  static Future<void> logout() async {
    try {
      await ApiClient.post('/logout', {});
    } catch (_) {
      // tetap hapus token lokal walau request logout gagal (mis. tidak ada koneksi)
    }
    await ApiClient.clearToken();
    currentUser = null;
  }

  /// GET /api/me — dipanggil saat app dibuka & token lama masih ada,
  /// supaya currentUser (dan role-nya) terisi lagi tanpa login ulang.
  static Future<Petugas> me() async {
    final data = await ApiClient.get('/me');
    final user = Petugas.fromJson(data);
    currentUser = user;
    return user;
  }
}
