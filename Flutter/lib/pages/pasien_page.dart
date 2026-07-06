import 'package:flutter/material.dart';
import '../models/pasien.dart';
import '../services/pasien_service.dart';
import '../services/api_client.dart';

class PasienPage extends StatefulWidget {
  const PasienPage({Key? key}) : super(key: key);

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage> {
  List<Pasien> pasienList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPasien();
  }

  Future<void> _loadPasien() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await PasienService.getAll();
      setState(() {
        pasienList = data;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data pasien';
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
            ElevatedButton(onPressed: _loadPasien, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPasien,
        child: pasienList.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada data pasien')),
                ],
              )
            : ListView.builder(
                itemCount: pasienList.length,
                itemBuilder: (context, index) {
                  final pasien = pasienList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(pasien.nama.isNotEmpty ? pasien.nama[0].toUpperCase() : '?'),
                      ),
                      title: Text(pasien.nama),
                      subtitle: Text('${pasien.jenisKelamin} | ${pasien.noTelepon}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showPasienForm(context, pasien: pasien),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(pasien),
                          ),
                        ],
                      ),
                      onTap: () => _showPasienDetail(context, pasien),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPasienForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(Pasien pasien) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pasien'),
        content: Text('Yakin ingin menghapus data ${pasien.nama}?'),
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
        await PasienService.delete(pasien.id!);
        _showSnack('Pasien berhasil dihapus');
        _loadPasien();
      } on ApiException catch (e) {
        _showSnack(e.message, isError: true);
      }
    }
  }

  void _showPasienForm(BuildContext context, {Pasien? pasien}) {
    final namaController = TextEditingController(text: pasien?.nama ?? '');
    final tanggalLahirController = TextEditingController(text: pasien?.tanggalLahir ?? '');
    final alamatController = TextEditingController(text: pasien?.alamat ?? '');
    final noTeleponController = TextEditingController(text: pasien?.noTelepon ?? '');
    String jenisKelamin = pasien?.jenisKelamin ?? 'Laki-laki';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) => AlertDialog(
          title: Text(pasien == null ? 'Tambah Pasien' : 'Edit Pasien'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                TextField(
                  controller: tanggalLahirController,
                  decoration: const InputDecoration(labelText: 'Tanggal Lahir (DD/MM/YYYY)'),
                ),
                DropdownButtonFormField<String>(
                  value: jenisKelamin,
                  decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  items: ['Laki-laki', 'Perempuan']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) => setStateDialog(() => jenisKelamin = value!),
                ),
                TextField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 2,
                ),
                TextField(
                  controller: noTeleponController,
                  decoration: const InputDecoration(labelText: 'No. Telepon'),
                  keyboardType: TextInputType.phone,
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
                      if (namaController.text.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Nama tidak boleh kosong')),
                        );
                        return;
                      }

                      setStateDialog(() => isSaving = true);

                      final newPasien = Pasien(
                        id: pasien?.id,
                        nama: namaController.text,
                        tanggalLahir: tanggalLahirController.text,
                        jenisKelamin: jenisKelamin,
                        alamat: alamatController.text,
                        noTelepon: noTeleponController.text,
                      );

                      try {
                        if (pasien != null) {
                          await PasienService.update(pasien.id!, newPasien);
                        } else {
                          await PasienService.create(newPasien);
                        }
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        _loadPasien();
                        _showSnack(pasien == null ? 'Pasien berhasil ditambahkan' : 'Pasien berhasil diupdate');
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

  void _showPasienDetail(BuildContext context, Pasien pasien) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Pasien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${pasien.id}'),
            const SizedBox(height: 8),
            Text('Nama: ${pasien.nama}'),
            const SizedBox(height: 8),
            Text('Tanggal Lahir: ${pasien.tanggalLahir}'),
            const SizedBox(height: 8),
            Text('Jenis Kelamin: ${pasien.jenisKelamin}'),
            const SizedBox(height: 8),
            Text('Alamat: ${pasien.alamat}'),
            const SizedBox(height: 8),
            Text('No. Telepon: ${pasien.noTelepon}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
