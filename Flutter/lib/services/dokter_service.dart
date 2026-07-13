import 'api_client.dart';
import '../models/dokter.dart';

class DokterService {
  static Future<List<Dokter>> getAll({String? search}) async {
    final query = (search != null && search.isNotEmpty)
        ? '?search=${Uri.encodeQueryComponent(search)}'
        : '';
    final data = await ApiClient.get('/dokter$query');
    final list = data['data'] as List;
    return list.map((e) => Dokter.fromJson(e)).toList();
  }

  static Future<Dokter> create(Dokter dokter) async {
    final data = await ApiClient.post('/dokter', dokter.toJson());
    return Dokter.fromJson(data['data']);
  }

  static Future<Dokter> update(int id, Dokter dokter) async {
    final data = await ApiClient.put('/dokter/$id', dokter.toJson());
    return Dokter.fromJson(data['data']);
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/dokter/$id');
  }
}
