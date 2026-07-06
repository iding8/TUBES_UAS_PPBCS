class Petugas {
  final int id;
  final String name;
  final String email;

  Petugas({required this.id, required this.name, required this.email});

  factory Petugas.fromJson(Map<String, dynamic> json) {
    return Petugas(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
