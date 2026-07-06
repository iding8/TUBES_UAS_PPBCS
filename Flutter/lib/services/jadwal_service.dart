import 'api_client.dart';
import '../models/jadwal_pemeriksaan.dart';

class JadwalService {
  static Future<List<JadwalPemeriksaan>> getAll() async {
    final data = await ApiClient.get('/jadwal');
    final list = data['data'] as List;
    return list.map((e) => JadwalPemeriksaan.fromJson(e)).toList();
  }

  static Future<JadwalPemeriksaan> create(JadwalPemeriksaan jadwal) async {
    final data = await ApiClient.post('/jadwal', jadwal.toJson());
    return JadwalPemeriksaan.fromJson(data['data']);
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/jadwal/$id');
  }
}
