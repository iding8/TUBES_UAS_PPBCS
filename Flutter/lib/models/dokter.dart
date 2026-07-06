class Dokter {
  final int? id;
  String nama;
  String spesialisasi;
  String noTelepon;

  Dokter({
    this.id,
    required this.nama,
    required this.spesialisasi,
    required this.noTelepon,
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      nama: json['nama'] ?? '',
      spesialisasi: json['spesialisasi'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'spesialisasi': spesialisasi,
      'no_telepon': noTelepon,
    };
  }

  static Dokter kosong() => Dokter(id: null, nama: 'Tidak ditemukan', spesialisasi: '', noTelepon: '');
}
