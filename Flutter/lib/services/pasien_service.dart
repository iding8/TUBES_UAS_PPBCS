import 'api_client.dart';
import '../models/pasien.dart';

class PasienService {
  static Future<List<Pasien>> getAll() async {
    final data = await ApiClient.get('/pasien');
    final list = data['data'] as List;
    return list.map((e) => Pasien.fromJson(e)).toList();
  }

  static Future<Pasien> create(Pasien pasien) async {
    final data = await ApiClient.post('/pasien', pasien.toJson());
    return Pasien.fromJson(data['data']);
  }

  static Future<Pasien> update(int id, Pasien pasien) async {
    final data = await ApiClient.put('/pasien/$id', pasien.toJson());
    return Pasien.fromJson(data['data']);
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/pasien/$id');
  }
}
