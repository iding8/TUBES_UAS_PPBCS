class Pasien {
  final int? id;
  String nama;
  String tanggalLahir;
  String jenisKelamin;
  String alamat;
  String noTelepon;

  Pasien({
    this.id,
    required this.nama,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alamat,
    required this.noTelepon,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      nama: json['nama'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? 'Laki-laki',
      alamat: json['alamat'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'no_telepon': noTelepon,
    };
  }

  static Pasien kosong() => Pasien(
        id: null,
        nama: 'Tidak ditemukan',
        tanggalLahir: '',
        jenisKelamin: 'Laki-laki',
        alamat: '',
        noTelepon: '',
      );
}
