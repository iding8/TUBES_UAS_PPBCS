import 'api_client.dart';
import '../models/rekam_medis.dart';

class RekamMedisService {
  static Future<List<RekamMedis>> getAll() async {
    final data = await ApiClient.get('/rekam-medis');
    final list = data['data'] as List;
    return list.map((e) => RekamMedis.fromJson(e)).toList();
  }

  static Future<RekamMedis> create(RekamMedis rekamMedis) async {
    final data = await ApiClient.post('/rekam-medis', rekamMedis.toJson());
    return RekamMedis.fromJson(data['data']);
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/rekam-medis/$id');
  }
}
