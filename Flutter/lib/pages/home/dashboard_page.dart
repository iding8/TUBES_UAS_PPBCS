import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardStats? stats;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await DashboardService.getStats();
      setState(() {
        stats = result;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat statistik dashboard';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(errorMessage!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadStats, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final s = stats!;
    final antrianBerikutnya = s.antrianBerikutnya;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Halo, ${AuthService.currentUser?.name ?? 'Petugas'} 👋',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            AuthService.currentUser?.isAdmin == true ? 'Admin' : 'Staff',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                icon: Icons.people,
                color: Colors.blue,
                label: 'Total Pasien',
                value: '${s.totalPasien}',
              ),
              _StatCard(
                icon: Icons.medical_services,
                color: Colors.teal,
                label: 'Total Dokter',
                value: '${s.totalDokter}',
              ),
              _StatCard(
                icon: Icons.hourglass_empty,
                color: Colors.orange,
                label: 'Antrian Menunggu',
                value: '${s.antrianMenunggu}',
              ),
              _StatCard(
                icon: Icons.campaign,
                color: Colors.purple,
                label: 'Antrian Dipanggil',
                value: '${s.antrianDipanggil}',
              ),
              _StatCard(
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'Selesai Hari Ini',
                value: '${s.antrianSelesaiHariIni}',
              ),
              _StatCard(
                icon: Icons.calendar_today,
                color: Colors.indigo,
                label: 'Jadwal Hari Ini',
                value: '${s.jadwalHariIni}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Antrian Berikutnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (antrianBerikutnya == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Tidak ada antrian yang menunggu'),
                  ],
                ),
              ),
            )
          else
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.confirmation_number)),
                title: Text(antrianBerikutnya['nomor_antrian'] ?? '-'),
                subtitle: Text(
                  '${antrianBerikutnya['pasien']?['nama'] ?? 'Pasien tidak ditemukan'} • '
                  '${antrianBerikutnya['dokter']?['nama'] ?? 'Dokter tidak ditemukan'}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700]), maxLines: 2),
          ],
        ),
      ),
    );
  }
}
