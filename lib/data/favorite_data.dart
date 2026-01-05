// Simpan di lib/data/favorite_data.dart

class FavoriteItem {
  final String title;
  final String description;
  final String location;
  final String imagePath;
  final String category; // 'Budaya', 'Kuliner', atau 'Religi'

  FavoriteItem({
    required this.title,
    required this.description,
    required this.location,
    required this.imagePath,
    required this.category,
  });
}

// List Global untuk menyimpan favorit
List<FavoriteItem> favoriteList = [];