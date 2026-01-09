class UserUlasan {
  final String name;
  final String? avatar;

  UserUlasan({required this.name, this.avatar});

  factory UserUlasan.fromJson(Map<String, dynamic> json) {
    return UserUlasan(
      name: json['name'] ?? 'Anonim',
      avatar: json['avatar'],
    );
  }
}

// Model untuk Ulasan
class Ulasan {
  final int id;
  final int rating;
  final String komentar;
  final UserUlasan? user;

  Ulasan({
    required this.id,
    required this.rating,
    required this.komentar,
    this.user,
  });

  factory Ulasan.fromJson(Map<String, dynamic> json) {
    return Ulasan(
      id: json['id'],
      rating: json['rating'] ?? 0,
      komentar: json['komentar'] ?? '',
      user: UserUlasan(
        name: json['name'] ?? 'Anonim', 
        avatar: json['avatar'],
      ),
    );
  }
}