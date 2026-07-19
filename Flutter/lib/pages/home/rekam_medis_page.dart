import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../models/rekam_medis.dart';
import '../../models/pasien.dart';
import '../../models/dokter.dart';
import '../../services/rekam_medis_service.dart';
import '../../services/pasien_service.dart';
import '../../services/dokter_service.dart';
import '../../services/api_client.dart';

class RekamMedisPage extends StatefulWidget {
  const RekamMedisPage({Key? key}) : super(key: key);

  @override
  State<RekamMedisPage> createState() => _RekamMedisPageState();
}

class _RekamMedisPageState extends State<RekamMedisPage> {
  List<RekamMedis> rekamMedisList = [];
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
        RekamMedisService.getAll(),
        PasienService.getAll(),
        DokterService.getAll(),
      ]);
      setState(() {
        rekamMedisList = results[0] as List<RekamMedis>;
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
        errorMessage = 'Gagal memuat data rekam medis';
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
        child: rekamMedisList.isEmpty
            ? const EmptyState(
                icon: Icons.description_outlined,
                title: 'Belum ada rekam medis',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 90),
                itemCount: rekamMedisList.length,
                itemBuilder: (context, index) {
                  final rekamMedis = rekamMedisList[index];
                  final namaPasien = rekamMedis.pasien?.nama ?? 'Tidak ditemukan';
                  final namaDokter = rekamMedis.dokter?.nama ?? 'Tidak ditemukan';

                  return ElegantListCard(
                    icon: Icons.description_rounded,
                    iconColor: AppColors.success,
                    title: namaPasien,
                    subtitle: 'Dokter: $namaDokter\nDiagnosis: ${rekamMedis.diagnosis}',
                    threeLine: true,
                    onTap: () => _showRekamMedisDetail(context, rekamMedis, namaPasien, namaDokter),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                      onPressed: () => _confirmDelete(rekamMedis),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRekamMedisForm(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _confirmDelete(RekamMedis rekamMedis) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rekam Medis'),
        content: const Text('Yakin ingin menghapus rekam medis ini?'),
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
        await RekamMedisService.delete(rekamMedis.id!);
        _showSnack('Rekam medis berhasil dihapus');
        _loadData();
      } on ApiException catch (e) {
        _showSnack(e.message, isError: true);
      }
    }
  }

  void _showRekamMedisForm(BuildContext context) {
    if (pasienList.isEmpty || dokterList.isEmpty) {
      _showSnack('Tambahkan pasien dan dokter terlebih dahulu', isError: true);
      return;
    }

    int? selectedPasienId = pasienList.first.id;
    int? selectedDokterId = dokterList.first.id;
    final tanggalController = TextEditingController();
    final diagnosisController = TextEditingController();
    final resepController = TextEditingController();
    final catatanController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) => AlertDialog(
          title: const Text('Tambah Rekam Medis'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedPasienId,
                  decoration: const InputDecoration(labelText: 'Pilih Pasien'),
                  items: pasienList.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama))).toList(),
                  onChanged: (value) => setStateDialog(() => selectedPasienId = value),
                ),
                DropdownButtonFormField<int>(
                  value: selectedDokterId,
                  decoration: const InputDecoration(labelText: 'Pilih Dokter'),
                  items: dokterList.map((d) => DropdownMenuItem(value: d.id, child: Text(d.nama))).toList(),
                  onChanged: (value) => setStateDialog(() => selectedDokterId = value),
                ),
                TextField(
                  controller: tanggalController,
                  decoration: const InputDecoration(labelText: 'Tanggal (DD/MM/YYYY)'),
                ),
                TextField(
                  controller: diagnosisController,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                  maxLines: 2,
                ),
                TextField(
                  controller: resepController,
                  decoration: const InputDecoration(labelText: 'Resep'),
                  maxLines: 2,
                ),
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                  maxLines: 2,
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
                          diagnosisController.text.isEmpty ||
                          resepController.text.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Tanggal, diagnosis, dan resep wajib diisi')),
                        );
                        return;
                      }

                      setStateDialog(() => isSaving = true);

                      final newRekamMedis = RekamMedis(
                        pasienId: selectedPasienId!,
                        dokterId: selectedDokterId!,
                        tanggal: tanggalController.text,
                        diagnosis: diagnosisController.text,
                        resep: resepController.text,
                        catatan: catatanController.text,
                      );

                      try {
                        await RekamMedisService.create(newRekamMedis);
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        _loadData();
                        _showSnack('Rekam medis berhasil ditambahkan');
                      } on ApiException catch (e) {
                        setStateDialog(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRekamMedisDetail(BuildContext context, RekamMedis rekamMedis, String namaPasien, String namaDokter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Rekam Medis'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pasien: $namaPasien', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Dokter: $namaDokter'),
              const SizedBox(height: 8),
              Text('Tanggal: ${rekamMedis.tanggal}'),
              const SizedBox(height: 8),
              Text('Diagnosis: ${rekamMedis.diagnosis}'),
              const SizedBox(height: 8),
              Text('Resep: ${rekamMedis.resep}'),
              const SizedBox(height: 8),
              Text('Catatan: ${rekamMedis.catatan}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
