import 'pasien.dart';
import 'dokter.dart';

class Antrian {
  final int? id;
  String nomorAntrian;
  int pasienId;
  int dokterId;
  String tanggal;
  String status; // menunggu | dipanggil | selesai
  String waktuDaftar;

  Pasien? pasien;
  Dokter? dokter;

  Antrian({
    this.id,
    required this.nomorAntrian,
    required this.pasienId,
    required this.dokterId,
    required this.tanggal,
    required this.status,
    required this.waktuDaftar,
    this.pasien,
    this.dokter,
  });

  factory Antrian.fromJson(Map<String, dynamic> json) {
    return Antrian(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      nomorAntrian: json['nomor_antrian'] ?? '',
      pasienId: json['pasien_id'] is int ? json['pasien_id'] : int.tryParse('${json['pasien_id']}') ?? 0,
      dokterId: json['dokter_id'] is int ? json['dokter_id'] : int.tryParse('${json['dokter_id']}') ?? 0,
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? 'menunggu',
      waktuDaftar: json['waktu_daftar'] ?? '',
      pasien: json['pasien'] != null ? Pasien.fromJson(json['pasien']) : null,
      dokter: json['dokter'] != null ? Dokter.fromJson(json['dokter']) : null,
    );
  }
}
