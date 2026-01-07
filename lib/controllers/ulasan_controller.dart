import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:explorecirebon/config.dart';

class UlasanController with ChangeNotifier {
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> postUlasan({
    required int destinasiId,
    required int rating,
    required String komentar,
    required String token, // Diambil dari AuthController
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/ulasan"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'destinasi_id': destinasiId,
          'rating': rating,
          'komentar': komentar,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Gagal kirim ulasan: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Post Ulasan: $e");
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}