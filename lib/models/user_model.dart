class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  // Fungsi untuk konversi dari JSON ke Objek Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // LOGIKA PENTING: Cek apakah ada key 'user' di dalam JSON
    // Jika ada (seperti hasil Postman-mu), gunakan json['user']
    // Jika tidak ada, gunakan json itu sendiri
    final data = json['user'] != null ? json['user'] : json;

    return UserModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}