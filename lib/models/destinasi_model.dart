import 'ulasan_model.dart';
import '../config.dart';

class Destinasi {
  final int id;
  final String nama;
  final String lokasi;
  final String? telepon;
  final String kategori;
  final String? gambar;
  final String? deskripsi;
  final String? latitude;
  final String? longitude;
  final String? harga;
  final String? jamOprasional;
  final List<Ulasan> ulasan;
  final double rataRating; // Tambahan untuk rating bintang

  Destinasi({
    required this.id,
    required this.nama,
    required this.lokasi,
    this.telepon,
    required this.kategori,
    this.gambar,
    this.deskripsi,
    this.latitude,
    this.longitude,
    this.harga,
    this.jamOprasional,
    required this.ulasan,
    this.rataRating = 0.0,
  });

  factory Destinasi.fromJson(Map<String, dynamic> json) {
    return Destinasi(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      lokasi: json['lokasi'] ?? '',
      telepon: json['telepon']?.toString(),
      kategori: json['kategori'] ?? '',
      // URL Gambar otomatis menggabungkan storageUrl dari config
      gambar: json['gambar'] != null
          ? "${AppConfig.storageUrl}/${json['gambar']}"
          : null,
      deskripsi: json['deskripsi']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      harga: json['harga']?.toString(),
      jamOprasional: json['jamOprasional']?.toString(),
      rataRating: (json['rata_rating'] ?? 0).toDouble(),
      ulasan:
          (json['ulasan'] as List?)?.map((i) => Ulasan.fromJson(i)).toList() ??
          [],
          
    );
  }
}
