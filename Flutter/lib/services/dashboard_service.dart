import 'api_client.dart';

class DashboardStats {
  final int totalPasien;
  final int totalDokter;
  final int antrianMenunggu;
  final int antrianDipanggil;
  final int antrianSelesaiHariIni;
  final int jadwalHariIni;
  final Map<String, dynamic>? antrianBerikutnya;

  DashboardStats({
    required this.totalPasien,
    required this.totalDokter,
    required this.antrianMenunggu,
    required this.antrianDipanggil,
    required this.antrianSelesaiHariIni,
    required this.jadwalHariIni,
    this.antrianBerikutnya,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPasien: json['total_pasien'] ?? 0,
      totalDokter: json['total_dokter'] ?? 0,
      antrianMenunggu: json['antrian_menunggu'] ?? 0,
      antrianDipanggil: json['antrian_dipanggil'] ?? 0,
      antrianSelesaiHariIni: json['antrian_selesai_hari_ini'] ?? 0,
      jadwalHariIni: json['jadwal_hari_ini'] ?? 0,
      antrianBerikutnya: json['antrian_berikutnya'],
    );
  }
}

class DashboardService {
  /// GET /api/dashboard
  static Future<DashboardStats> getStats() async {
    final data = await ApiClient.get('/dashboard');
    return DashboardStats.fromJson(data['data']);
  }
}
