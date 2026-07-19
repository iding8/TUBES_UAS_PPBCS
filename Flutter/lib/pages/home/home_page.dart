import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_page.dart';
import 'dashboard_page.dart';
import 'pasien_page.dart';
import 'dokter_page.dart';
import 'jadwal_page.dart';
import 'antrian_page.dart';
import 'rekam_medis_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    PasienPage(),
    DokterPage(),
    JadwalPage(),
    AntrianPage(),
    RekamMedisPage(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Data Pasien',
    'Data Dokter',
    'Jadwal Pemeriksaan',
    'Antrian',
    'Rekam Medis',
  ];

  @override
  void initState() {
    super.initState();
    // Kalau app baru dibuka ulang (token lama masih tersimpan), currentUser
    // (termasuk role admin/staff) belum terisi -> ambil ulang dari /api/me.
    if (AuthService.currentUser == null) {
      AuthService.me().then((_) => setState(() {})).catchError((_) {});
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun petugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  static const List<IconData> _outlineIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.medical_services_outlined,
    Icons.calendar_today_outlined,
    Icons.confirmation_number_outlined,
    Icons.description_outlined,
  ];

  static const List<IconData> _filledIcons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.medical_services_rounded,
    Icons.calendar_today_rounded,
    Icons.confirmation_number_rounded,
    Icons.description_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.heroGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.local_hospital_rounded, size: 19, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
            ),
            const SizedBox(width: 4),
          ],
        ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: List.generate(_titles.length, (i) {
            return NavigationDestination(
              icon: Icon(_outlineIcons[i]),
              selectedIcon: Icon(_filledIcons[i]),
              label: _titles[i] == 'Rekam Medis' ? 'Rekam' : _titles[i].split(' ').first,
            );
          }),
        ),
      ),
    );
  }
}
