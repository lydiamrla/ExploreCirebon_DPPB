import 'ulasan_model.dart';

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
  });

  factory Destinasi.fromJson(Map<String, dynamic> json) {
    String baseUrl = "http://10.0.2.2:8000/storage/";

    return Destinasi(
      id: json['id'],
      nama: json['nama'],
      lokasi: json['lokasi'],
      telepon: json['telepon'],
      kategori: json['kategori'],
      gambar: json['gambar'] != null ? baseUrl + json['gambar'] : null,
      deskripsi: json['deskripsi'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      harga: json['harga'],
      jamOprasional: json['jamOprasional'],
      ulasan:
          (json['ulasan'] as List?)?.map((i) => Ulasan.fromJson(i)).toList() ??
          [],
    );
  }
}
