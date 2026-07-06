import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/antrian.dart';
import '../models/pasien.dart';
import '../models/dokter.dart';
import '../services/antrian_service.dart';
import '../services/pasien_service.dart';
import '../services/dokter_service.dart';
import '../services/api_client.dart';

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
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
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
        return Colors.orange;
      case 'dipanggil':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
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
            ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );
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
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ANTRIAN SAAT INI',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blue),
                          tooltip: 'Ulangi Panggilan',
                          onPressed: () {
                            if (antrianAktif.isNotEmpty) {
                              final antrian = antrianAktif.first;
                              final namaPasien = antrian.pasien?.nama ?? 'Tidak ditemukan';
                              _speakAntrian(antrian.nomorAntrian, namaPasien);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...antrianAktif.map((antrian) {
                      final namaPasien = antrian.pasien?.nama ?? 'Tidak ditemukan';
                      final namaDokter = antrian.dokter?.nama ?? 'Tidak ditemukan';

                      return Column(
                        children: [
                          Text(
                            antrian.nomorAntrian,
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          Text(namaPasien, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                          Text('dr. $namaDokter', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Belum ada antrian')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredAntrian.length,
                      itemBuilder: (context, index) {
                        final antrian = _filteredAntrian[index];
                        final namaPasien = antrian.pasien?.nama ?? 'Tidak ditemukan';
                        final namaDokter = antrian.dokter?.nama ?? 'Tidak ditemukan';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(antrian.status),
                              child: Text(
                                antrian.nomorAntrian,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            title: Text(namaPasien),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('dr. $namaDokter'),
                                Text(
                                  'Waktu: ${antrian.waktuDaftar}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
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
                                      Icon(Icons.campaign, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Panggil'),
                                    ]),
                                  ),
                                if (antrian.status != 'selesai')
                                  const PopupMenuItem(
                                    value: 'selesai',
                                    child: Row(children: [
                                      Icon(Icons.check_circle, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Selesai'),
                                    ]),
                                  ),
                                if (antrian.status != 'menunggu')
                                  const PopupMenuItem(
                                    value: 'menunggu',
                                    child: Row(children: [
                                      Icon(Icons.access_time, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Kembalikan ke Menunggu'),
                                    ]),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ]),
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
      selectedColor: Colors.blue.shade100,
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
                          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
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
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.confirmation_number, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                antrian.nomorAntrian,
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(namaPasien, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('dr. $namaDokter', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(spesialisasiDokter, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
