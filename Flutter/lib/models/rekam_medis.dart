import 'pasien.dart';
import 'dokter.dart';

class RekamMedis {
  final int? id;
  int pasienId;
  int dokterId;
  String tanggal;
  String diagnosis;
  String resep;
  String catatan;

  Pasien? pasien;
  Dokter? dokter;

  RekamMedis({
    this.id,
    required this.pasienId,
    required this.dokterId,
    required this.tanggal,
    required this.diagnosis,
    required this.resep,
    required this.catatan,
    this.pasien,
    this.dokter,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      pasienId: json['pasien_id'] is int ? json['pasien_id'] : int.tryParse('${json['pasien_id']}') ?? 0,
      dokterId: json['dokter_id'] is int ? json['dokter_id'] : int.tryParse('${json['dokter_id']}') ?? 0,
      tanggal: json['tanggal'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      resep: json['resep'] ?? '',
      catatan: json['catatan'] ?? '',
      pasien: json['pasien'] != null ? Pasien.fromJson(json['pasien']) : null,
      dokter: json['dokter'] != null ? Dokter.fromJson(json['dokter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'dokter_id': dokterId,
      'tanggal': tanggal,
      'diagnosis': diagnosis,
      'resep': resep,
      'catatan': catatan,
    };
  }
}
