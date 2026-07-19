import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/antrian.dart';
import '../../models/pasien.dart';
import '../../models/dokter.dart';
import '../../services/antrian_service.dart';
import '../../services/pasien_service.dart';
import '../../services/dokter_service.dart';
import '../../services/api_client.dart';

class AntrianPage extends StatefulWidget {
  const AntrianPage({Key? key}) : super(key: key);

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  String _filterStatus = 'Semua';
  final FlutterTts flutterTts = FlutterTts();
  List<Antrian> antrianList = [];
  List<Pasien> pasienList = [];
  List<Dokter> dokterList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final results = await Future.wait([
        AntrianService.getAll(),
        PasienService.getAll(),
        DokterService.getAll(),
      ]);
      setState(() {
        antrianList = results[0] as List<Antrian>;
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
        errorMessage = 'Gagal memuat data antrian';
        isLoading = false;
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : null),
    );
  }

  Future<void> _speakAntrian(String nomorAntrian, String namaPasien) async {
    String text = "Nomor antrian $nomorAntrian, atas nama $namaPasien, silakan menuju ruang pemeriksaan";
    await flutterTts.speak(text);
  }

  List<Antrian> get _filteredAntrian {
    if (_filterStatus == 'Semua') return antrianList;
    return antrianList.where((a) => a.status == _filterStatus.toLowerCase()).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return AppColors.warning;
      case 'dipanggil':
        return AppColors.primary;
      case 'selesai':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return ErrorStateView(message: errorMessage!, onRetry: _loadData);
    }

    final antrianAktif = antrianList.where((a) => a.status == 'dipanggil').toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            if (antrianAktif.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.heroGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.campaign_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'ANTRIAN SAAT INI',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (antrianAktif.isNotEmpty) {
                              final antrian = antrianAktif.first;
                              final namaPasien = antrian.pasien?.nama ?? 'Tidak ditemukan';
                              _speakAntrian(antrian.nomorAntrian, namaPasien);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                            child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...antrianAktif.map((antrian) {
                      final namaPasien = antrian.pasien?.nama ?? 'Tidak ditemukan';
                      final namaDokter = antrian.dokter?.nama ?? 'Tidak ditemukan';

                      return Column(
                        children: [
                          Text(
                            antrian.nomorAntrian,
                            style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05),
                          ),
                          const SizedBox(height: 6),
                          Text(namaPasien, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                          Text('dr. $namaDokter', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85))),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Menunggu'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dipanggil'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Selesai'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filteredAntrian.isEmpty
                  ? const EmptyState(icon: Icons.confirmation_number_outlined, title: 'Belum ada antrian')
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 6, bottom: 90),
                      itemCount: _filteredAntrian.length,
                      itemBuilder: (context, index) {
                        final antrian = _filteredAntrian[index];
                        final namaPasien = antrian.pasien?.nama ?? 'Tidak ditemukan';
                        final namaDokter = antrian.dokter?.nama ?? 'Tidak ditemukan';
                        final statusColor = _getStatusColor(antrian.status);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: AppShadows.card,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(14)),
                                  child: Text(
                                    antrian.nomorAntrian,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              namaPasien,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          StatusBadge(status: antrian.status),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('dr. $namaDokter', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                      Text(
                                        'Waktu: ${antrian.waktuDaftar}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                              onSelected: (value) async {
                                try {
                                  if (value == 'delete') {
                                    await AntrianService.delete(antrian.id!);
                                  } else {
                                    await AntrianService.updateStatus(antrian.id!, value);
                                    if (value == 'dipanggil') {
                                      _speakAntrian(antrian.nomorAntrian, namaPasien);
                                    }
                                  }
                                  _loadData();
                                } on ApiException catch (e) {
                                  _showSnack(e.message, isError: true);
                                }
                              },
                              itemBuilder: (context) => [
                                if (antrian.status != 'dipanggil')
                                  const PopupMenuItem(
                                    value: 'dipanggil',
                                    child: Row(children: [
                                      Icon(Icons.campaign, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('Panggil'),
                                    ]),
                                  ),
                                if (antrian.status != 'selesai')
                                  const PopupMenuItem(
                                    value: 'selesai',
                                    child: Row(children: [
                                      Icon(Icons.check_circle, color: AppColors.success),
                                      SizedBox(width: 8),
                                      Text('Selesai'),
                                    ]),
                                  ),
                                if (antrian.status != 'menunggu')
                                  const PopupMenuItem(
                                    value: 'menunggu',
                                    child: Row(children: [
                                      Icon(Icons.access_time, color: AppColors.warning),
                                      SizedBox(width: 8),
                                      Text('Kembalikan ke Menunggu'),
                                    ]),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [
                                    Icon(Icons.delete, color: AppColors.danger),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ]),
                                ),
                              ],
                            ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAntrianForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Ambil Nomor'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _filterStatus = label),
      selectedColor: AppColors.primary.withOpacity(0.18),
    );
  }

  void _showAntrianForm(BuildContext context) {
    if (pasienList.isEmpty || dokterList.isEmpty) {
      _showSnack('Tambahkan pasien dan dokter terlebih dahulu', isError: true);
      return;
    }

    int? selectedPasienId = pasienList.first.id;
    int? selectedDokterId = dokterList.first.id;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) => AlertDialog(
          title: const Text('Ambil Nomor Antrian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedPasienId,
                decoration: const InputDecoration(labelText: 'Pilih Pasien'),
                items: pasienList.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama))).toList(),
                onChanged: (value) => setStateDialog(() => selectedPasienId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDokterId,
                decoration: const InputDecoration(labelText: 'Pilih Dokter'),
                items: dokterList
                    .map((d) => DropdownMenuItem(value: d.id, child: Text('dr. ${d.nama} - ${d.spesialisasi}')))
                    .toList(),
                onChanged: (value) => setStateDialog(() => selectedDokterId = value),
              ),
            ],
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
                      setStateDialog(() => isSaving = true);
                      try {
                        final newAntrian = await AntrianService.create(
                          pasienId: selectedPasienId!,
                          dokterId: selectedDokterId!,
                        );
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        _loadData();
                        _showTicketDialog(context, newAntrian);
                      } on ApiException catch (e) {
                        setStateDialog(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Ambil Nomor'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDialog(BuildContext context, Antrian antrian) {
    final namaPasien = antrian.pasien?.nama ??
        pasienList.where((p) => p.id == antrian.pasienId).map((p) => p.nama).firstOrNull ??
        'Tidak ditemukan';
    final namaDokter = antrian.dokter?.nama ??
        dokterList.where((d) => d.id == antrian.dokterId).map((d) => d.nama).firstOrNull ??
        'Tidak ditemukan';
    final spesialisasiDokter = antrian.dokter?.spesialisasi ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nomor Antrian Anda'),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.confirmation_number, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                antrian.nomorAntrian,
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(namaPasien, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('dr. $namaDokter', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(spesialisasiDokter, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Text('Waktu: ${antrian.waktuDaftar}', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
