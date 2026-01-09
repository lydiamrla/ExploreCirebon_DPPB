import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config.dart'; // Pastikan import config untuk baseUrl

class AuthService {
  // Menggunakan baseUrl dari AppConfig agar konsisten dengan file lain
  final String baseUrl = AppConfig.baseUrl; 

  // --- FUNGSI BANTU STORAGE ---
  // Kita gunakan key 'token' agar sama dengan yang dipanggil di DestinasiController
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); 
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token ke SharedPreferences
        await _saveToken(data['token']); 
        
        return {
          'success': true, 
          'user': UserModel.fromJson(data['user']),
          'token': data['token'], // Kirim balik ke controller
        };
      }
      return {
        'success': false, 
        'message': data['message'] ?? 'Email atau password salah'
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi ke server'};
    }
  }

  // --- GET PROFILE ---
  Future<Map<String, dynamic>> getProfile() async {
    try {
      String? token = await _getToken();
      if (token == null) return {'success': false};

      final response = await http.get(
        Uri.parse('$baseUrl/settings/profile'), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        return {
          'success': true,
          'user': UserModel.fromJson(decodedData), 
        };
      }
      return {'success': false};
    } catch (e) {
      print("Error getProfile: $e");
      return {'success': false};
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, 
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _saveToken(data['token']);
        return {
          'success': true,
          'user': UserModel.fromJson(data['user']),
          'token': data['token'],
        };
      } 
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mendaftar',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // --- UPDATE PROFILE ---
  Future<Map<String, dynamic>> updateProfile({required String name, String? password}) async {
    try {
      final token = await _getToken();
      final Map<String, String> body = {'name': name};
      
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = password; 
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/settings/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'user': UserModel.fromJson(data['user'])
        };
      } 
      return {
        'success': false, 
        'message': data['message'] ?? 'Gagal update'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem'};
    }
  }

  // --- LOGOUT ---
  Future<bool> logout() async {
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Pastikan key 'token' yang dihapus
      return true;
    } catch (e) {
      return false;
    }
  }
}