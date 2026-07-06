import 'pasien.dart';
import 'dokter.dart';

class JadwalPemeriksaan {
  final int? id;
  int pasienId;
  int dokterId;
  String tanggal;
  String waktu;
  String keluhan;

  // Data relasi (dikirim Laravel via ->load(['pasien','dokter']))
  Pasien? pasien;
  Dokter? dokter;

  JadwalPemeriksaan({
    this.id,
    required this.pasienId,
    required this.dokterId,
    required this.tanggal,
    required this.waktu,
    required this.keluhan,
    this.pasien,
    this.dokter,
  });

  factory JadwalPemeriksaan.fromJson(Map<String, dynamic> json) {
    return JadwalPemeriksaan(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      pasienId: json['pasien_id'] is int ? json['pasien_id'] : int.tryParse('${json['pasien_id']}') ?? 0,
      dokterId: json['dokter_id'] is int ? json['dokter_id'] : int.tryParse('${json['dokter_id']}') ?? 0,
      tanggal: json['tanggal'] ?? '',
      waktu: json['waktu'] ?? '',
      keluhan: json['keluhan'] ?? '',
      pasien: json['pasien'] != null ? Pasien.fromJson(json['pasien']) : null,
      dokter: json['dokter'] != null ? Dokter.fromJson(json['dokter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'dokter_id': dokterId,
      'tanggal': tanggal,
      'waktu': waktu,
      'keluhan': keluhan,
    };
  }
}
