import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      _showSnack('Nama dan email wajib diisi', isError: true);
      return;
    }
    setState(() => _savingProfile = true);
    try {
      await ApiClient.put('/profile', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });
      // refresh currentUser (termasuk role) dari server
      await AuthService.me();
      if (!mounted) return;
      _showSnack('Profil berhasil diperbarui');
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _savePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnack('Semua field password wajib diisi', isError: true);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack('Konfirmasi password tidak cocok', isError: true);
      return;
    }
    setState(() => _savingPassword = true);
    try {
      await ApiClient.put('/profile/password', {
        'current_password': _currentPasswordController.text,
        'password': _newPasswordController.text,
        'password_confirmation': _confirmPasswordController.text,
      });
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSnack('Password berhasil diubah');
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
                const SizedBox(height: 8),
                Chip(
                  label: Text(user?.isAdmin == true ? 'Admin' : 'Staff'),
                  backgroundColor: user?.isAdmin == true ? Colors.blue[50] : Colors.grey[200],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Informasi Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _savingProfile ? null : _saveProfile,
            child: _savingProfile
                ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan Profil'),
          ),
          const Divider(height: 40),
          const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _currentPasswordController,
            decoration: const InputDecoration(labelText: 'Password Saat Ini', border: OutlineInputBorder()),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPasswordController,
            decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder()),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru', border: OutlineInputBorder()),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _savingPassword ? null : _savePassword,
            child: _savingPassword
                ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Ubah Password'),
          ),
        ],
      ),
    );
  }
}
