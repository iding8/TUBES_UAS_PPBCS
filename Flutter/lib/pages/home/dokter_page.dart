import 'package:flutter/material.dart';
import '../../models/dokter.dart';
import '../../services/dokter_service.dart';
import '../../services/api_client.dart';

class DokterPage extends StatefulWidget {
  const DokterPage({Key? key}) : super(key: key);

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  List<Dokter> dokterList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDokter();
  }

  Future<void> _loadDokter() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await DokterService.getAll();
      setState(() {
        dokterList = data;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data dokter';
        isLoading = false;
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
    );
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
            ElevatedButton(onPressed: _loadDokter, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDokter,
        child: dokterList.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada data dokter')),
                ],
              )
            : ListView.builder(
                itemCount: dokterList.length,
                itemBuilder: (context, index) {
                  final dokter = dokterList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.medical_services)),
                      title: Text(dokter.nama),
                      subtitle: Text('${dokter.spesialisasi} | ${dokter.noTelepon}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showDokterForm(context, dokter: dokter),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(dokter),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDokterForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(Dokter dokter) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokter'),
        content: Text('Yakin ingin menghapus data dr. ${dokter.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DokterService.delete(dokter.id!);
        _showSnack('Dokter berhasil dihapus');
        _loadDokter();
      } on ApiException catch (e) {
        _showSnack(e.message, isError: true);
      }
    }
  }

  void _showDokterForm(BuildContext context, {Dokter? dokter}) {
    final namaController = TextEditingController(text: dokter?.nama ?? '');
    final spesialisasiController = TextEditingController(text: dokter?.spesialisasi ?? '');
    final noTeleponController = TextEditingController(text: dokter?.noTelepon ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) => AlertDialog(
          title: Text(dokter == null ? 'Tambah Dokter' : 'Edit Dokter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Dokter'),
              ),
              TextField(
                controller: spesialisasiController,
                decoration: const InputDecoration(labelText: 'Spesialisasi'),
              ),
              TextField(
                controller: noTeleponController,
                decoration: const InputDecoration(labelText: 'No. Telepon'),
                keyboardType: TextInputType.phone,
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
                      if (namaController.text.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Nama tidak boleh kosong')),
                        );
                        return;
                      }

                      setStateDialog(() => isSaving = true);

                      final newDokter = Dokter(
                        id: dokter?.id,
                        nama: namaController.text,
                        spesialisasi: spesialisasiController.text,
                        noTelepon: noTeleponController.text,
                      );

                      try {
                        if (dokter != null) {
                          await DokterService.update(dokter.id!, newDokter);
                        } else {
                          await DokterService.create(newDokter);
                        }
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        _loadDokter();
                        _showSnack(dokter == null ? 'Dokter berhasil ditambahkan' : 'Dokter berhasil diupdate');
                      } on ApiException catch (e) {
                        setStateDialog(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
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
