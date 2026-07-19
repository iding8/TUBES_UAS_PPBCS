import 'package:flutter/material.dart';
import '../../models/pasien.dart';
import '../../services/pasien_service.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class PasienPage extends StatefulWidget {
  const PasienPage({Key? key}) : super(key: key);

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage> {
  List<Pasien> pasienList = [];
  bool isLoading = true;
  String? errorMessage;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPasien();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPasien() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await PasienService.getAll(search: _searchController.text.trim());
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
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return ErrorStateView(message: errorMessage!, onRetry: _loadPasien);
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau no. telepon...',
                prefixIcon: const Icon(Icons.search_rounded, size: 21),
                isDense: true,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 19),
                        onPressed: () {
                          _searchController.clear();
                          _loadPasien();
                        },
                      ),
              ),
              onSubmitted: (_) => _loadPasien(),
            ),
          ),
          Expanded(child: _buildPasienList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPasienForm(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildPasienList() {
    return RefreshIndicator(
      onRefresh: _loadPasien,
      child: pasienList.isEmpty
          ? const EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Belum ada data pasien',
              subtitle: 'Ketuk tombol + untuk menambahkan pasien baru',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 90),
              itemCount: pasienList.length,
              itemBuilder: (context, index) {
                  final pasien = pasienList[index];
                  return ElegantListCard(
                    icon: pasien.jenisKelamin.toLowerCase().startsWith('l') ? Icons.man_rounded : Icons.woman_rounded,
                    iconColor: pasien.jenisKelamin.toLowerCase().startsWith('l') ? AppColors.info : AppColors.secondary,
                    title: pasien.nama,
                    subtitle: '${pasien.jenisKelamin} • ${pasien.noTelepon}',
                    onTap: () => _showPasienDetail(context, pasien),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                          onPressed: () => _showPasienForm(context, pasien: pasien),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                          onPressed: () => _confirmDelete(pasien),
                        ),
                      ],
                    ),
                  );
                },
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
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
