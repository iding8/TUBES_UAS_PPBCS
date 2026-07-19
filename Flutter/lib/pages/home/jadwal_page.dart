import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../models/jadwal_pemeriksaan.dart';
import '../../models/pasien.dart';
import '../../models/dokter.dart';
import '../../services/jadwal_service.dart';
import '../../services/pasien_service.dart';
import '../../services/dokter_service.dart';
import '../../services/api_client.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({Key? key}) : super(key: key);

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<JadwalPemeriksaan> jadwalList = [];
  List<Pasien> pasienList = [];
  List<Dokter> dokterList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final results = await Future.wait([
        JadwalService.getAll(),
        PasienService.getAll(),
        DokterService.getAll(),
      ]);
      setState(() {
        jadwalList = results[0] as List<JadwalPemeriksaan>;
        pasienList = results[1] as List<Pasien>;
        dokterList = results[2] as List<Dokter>;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data jadwal';
        isLoading = false;
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return ErrorStateView(message: errorMessage!, onRetry: _loadData);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: jadwalList.isEmpty
            ? const EmptyState(
                icon: Icons.calendar_today_outlined,
                title: 'Belum ada jadwal pemeriksaan',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 90),
                itemCount: jadwalList.length,
                itemBuilder: (context, index) {
                  final jadwal = jadwalList[index];
                  final namaPasien = jadwal.pasien?.nama ?? 'Tidak ditemukan';
                  final namaDokter = jadwal.dokter?.nama ?? 'Tidak ditemukan';

                  return ElegantListCard(
                    icon: Icons.event_note_rounded,
                    iconColor: AppColors.secondary,
                    title: '$namaPasien — dr. $namaDokter',
                    subtitle: '${jadwal.tanggal} • ${jadwal.waktu}\nKeluhan: ${jadwal.keluhan}',
                    threeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                      onPressed: () => _confirmDelete(jadwal),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _loadData();
          if (!context.mounted) return;
          _showJadwalForm(context);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _confirmDelete(JadwalPemeriksaan jadwal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Yakin ingin menghapus jadwal pemeriksaan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await JadwalService.delete(jadwal.id!);
        _showSnack('Jadwal berhasil dihapus');
        _loadData();
      } on ApiException catch (e) {
        _showSnack(e.message, isError: true);
      }
    }
  }

  void _showJadwalForm(BuildContext context) {
    if (pasienList.isEmpty || dokterList.isEmpty) {
      _showSnack('Tambahkan pasien dan dokter terlebih dahulu', isError: true);
      return;
    }

    int? selectedPasienId = pasienList.first.id;
    int? selectedDokterId = dokterList.first.id;
    final tanggalController = TextEditingController();
    final waktuController = TextEditingController();
    final keluhanController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) => AlertDialog(
          title: const Text('Tambah Jadwal Pemeriksaan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedPasienId,
                  decoration: const InputDecoration(labelText: 'Pilih Pasien'),
                  items: pasienList
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama)))
                      .toList(),
                  onChanged: (value) => setStateDialog(() => selectedPasienId = value),
                ),
                DropdownButtonFormField<int>(
                  value: selectedDokterId,
                  decoration: const InputDecoration(labelText: 'Pilih Dokter'),
                  items: dokterList
                      .map((d) => DropdownMenuItem(value: d.id, child: Text(d.nama)))
                      .toList(),
                  onChanged: (value) => setStateDialog(() => selectedDokterId = value),
                ),
                TextField(
                  controller: tanggalController,
                  decoration: const InputDecoration(labelText: 'Tanggal (DD/MM/YYYY)'),
                ),
                TextField(
                  controller: waktuController,
                  decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'),
                ),
                TextField(
                  controller: keluhanController,
                  decoration: const InputDecoration(labelText: 'Keluhan'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (tanggalController.text.isEmpty ||
                          waktuController.text.isEmpty ||
                          keluhanController.text.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Semua field wajib diisi')),
                        );
                        return;
                      }

                      setStateDialog(() => isSaving = true);

                      final newJadwal = JadwalPemeriksaan(
                        pasienId: selectedPasienId!,
                        dokterId: selectedDokterId!,
                        tanggal: tanggalController.text,
                        waktu: waktuController.text,
                        keluhan: keluhanController.text,
                      );

                      try {
                        await JadwalService.create(newJadwal);
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        _loadData();
                        _showSnack('Jadwal berhasil ditambahkan');
                      } on ApiException catch (e) {
                        setStateDialog(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
