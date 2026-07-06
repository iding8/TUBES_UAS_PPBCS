import 'api_client.dart';
import '../models/antrian.dart';

class AntrianService {
  static Future<List<Antrian>> getAll() async {
    final data = await ApiClient.get('/antrian');
    final list = data['data'] as List;
    return list.map((e) => Antrian.fromJson(e)).toList();
  }

  /// Nomor antrian, tanggal, status awal, dan waktu daftar
  /// di-generate otomatis oleh server (lihat AntrianController@store).
  static Future<Antrian> create({required int pasienId, required int dokterId}) async {
    final data = await ApiClient.post('/antrian', {
      'pasien_id': pasienId,
      'dokter_id': dokterId,
    });
    return Antrian.fromJson(data['data']);
  }

  static Future<Antrian> updateStatus(int id, String status) async {
    final data = await ApiClient.put('/antrian/$id/status', {'status': status});
    return Antrian.fromJson(data['data']);
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/antrian/$id');
  }
}
