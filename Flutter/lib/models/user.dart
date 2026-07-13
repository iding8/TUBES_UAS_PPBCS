class Petugas {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin' atau 'staff'

  Petugas({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'staff',
  });

  bool get isAdmin => role == 'admin';

  factory Petugas.fromJson(Map<String, dynamic> json) {
    return Petugas(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'staff',
    );
  }
}
