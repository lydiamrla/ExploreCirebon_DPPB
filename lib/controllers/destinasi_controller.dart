import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destinasi_model.dart';

class DestinasiController with ChangeNotifier {
  final String apiUrl = "http://10.0.2.2:8000/api";
  List<Destinasi> _destinasiList = [];
  bool _isLoading = false;

  List<Destinasi> get destinasiList => _destinasiList;
  bool get isLoading => _isLoading;

  Future<void> fetchDestinasi(String kategori) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$apiUrl/destinasi?kategori=$kategori'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body)['data'];
        _destinasiList = data.map((json) => Destinasi.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> postUlasan(int id, String komentar, int rating) async {
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
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}