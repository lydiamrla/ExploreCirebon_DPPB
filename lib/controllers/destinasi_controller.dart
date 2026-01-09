import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destinasi_model.dart';
import '../config.dart';

class DestinasiController with ChangeNotifier {
  final String apiUrl = AppConfig.baseUrl;

  List<Destinasi> _budayaList = [];
  List<Destinasi> _kulinerList = [];
  List<Destinasi> _religiList = [];

  // Getter spesifik untuk masing-masing kategori
  List<Destinasi> get budayaList => _budayaList;
  List<Destinasi> get kulinerList => _kulinerList;
  List<Destinasi> get religiList => _religiList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- PERBAIKAN GETTER ---
  // Fungsi ini lebih aman digunakan di screen karena mengambil data berdasarkan parameter kategori
  List<Destinasi> getDestinasiByCategory(String kategori) {
    if (kategori == 'Budaya') return _budayaList;
    if (kategori == 'Kuliner') return _kulinerList;
    if (kategori == 'Religi') return _religiList;
    return [];
  }

  // --- FETCH DATA ---
  Future<void> fetchDestinasi(String kategori) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      debugPrint("Memanggil API: $apiUrl/destinasi?kategori=$kategori");

      final response = await http
          .get(
            Uri.parse('$apiUrl/destinasi?kategori=$kategori'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List data = [];

        if (decodedResponse is List) {
          data = decodedResponse;
        } else if (decodedResponse is Map &&
            decodedResponse.containsKey('data')) {
          data = decodedResponse['data'];
        }

        List<Destinasi> fetchedData = data
            .map((item) => Destinasi.fromJson(item))
            .toList();

        // PENTING: Mengisi list yang tepat sesuai kategori agar tidak tertukar
        if (kategori == 'Budaya') {
          _budayaList = fetchedData;
        } else if (kategori == 'Kuliner') {
          _kulinerList = fetchedData;
        } else if (kategori == 'Religi') {
          _religiList = fetchedData;
        }

        debugPrint("Berhasil memproses ${fetchedData.length} data $kategori");
      } else {
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Terjadi Kesalahan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- POST ULASAN ---
  Future<bool> postUlasan(
    int id,
    String komentar,
    int rating,
    String kategori,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$apiUrl/ulasan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'destinasi_id': id.toString(),
          'komentar': komentar,
          'rating': rating.toString(),
        },
      );

      if (response.statusCode == 201) {
        // PENTING: Panggil fetchDestinasi kembali agar data di aplikasi
        // diperbarui dengan ulasan yang baru saja masuk ke database.
        await fetchDestinasi(kategori);
        return true;
      } else {
        debugPrint("Gagal kirim ulasan: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error post ulasan: $e");
      return false;
    }
  }
}
