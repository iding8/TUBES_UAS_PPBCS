import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return ErrorStateView(message: errorMessage!, onRetry: _loadStats);
    }

    final s = stats!;
    final antrianBerikutnya = s.antrianBerikutnya;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Kartu sapaan bergradasi — sentuhan personal di atas dashboard.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_greeting 👋',
                        style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AuthService.currentUser?.name ?? 'Petugas',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AuthService.currentUser?.isAdmin == true ? 'Admin' : 'Staff',
                          style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Ringkasan Hari Ini', icon: Icons.insights_rounded),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              GradientStatCard(
                icon: Icons.people_alt_rounded,
                color: AppColors.info,
                label: 'Total Pasien',
                value: '${s.totalPasien}',
              ),
              GradientStatCard(
                icon: Icons.medical_services_rounded,
                color: AppColors.primary,
                label: 'Total Dokter',
                value: '${s.totalDokter}',
              ),
              GradientStatCard(
                icon: Icons.hourglass_bottom_rounded,
                color: AppColors.warning,
                label: 'Antrian Menunggu',
                value: '${s.antrianMenunggu}',
              ),
              GradientStatCard(
                icon: Icons.campaign_rounded,
                color: AppColors.secondary,
                label: 'Antrian Dipanggil',
                value: '${s.antrianDipanggil}',
              ),
              GradientStatCard(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                label: 'Selesai Hari Ini',
                value: '${s.antrianSelesaiHariIni}',
              ),
              GradientStatCard(
                icon: Icons.event_available_rounded,
                color: AppColors.secondaryLight,
                label: 'Jadwal Hari Ini',
                value: '${s.jadwalHariIni}',
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionLabel('Antrian Berikutnya', icon: Icons.next_plan_outlined),
          if (antrianBerikutnya == null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Expanded(child: Text('Tidak ada antrian yang menunggu', style: TextStyle(color: AppColors.textSecondary))),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.card,
                border: Border.all(color: AppColors.primary.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          antrianBerikutnya['nomor_antrian'] ?? '-',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${antrianBerikutnya['pasien']?['nama'] ?? 'Pasien tidak ditemukan'} • '
                          '${antrianBerikutnya['dokter']?['nama'] ?? 'Dokter tidak ditemukan'}',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
