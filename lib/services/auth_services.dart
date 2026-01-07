import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Sesuaikan IP

  // Fungsi bantu simpan token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Fungsi bantu ambil token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }


  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data['token']); // Simpan token Sanctum
        return {
          'success': true, 
          'user': UserModel.fromJson(data['user'])
        };
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  // lib/services/auth_services.dart

Future<Map<String, dynamic>> getProfile() async {
  try {
    String? token = await _getToken();
    if (token == null) return {'success': false};

    // Gunakan endpoint yang paling stabil. 
    // Jika di Postman tadi URL /settings/profile berhasil, pakai itu:
    final response = await http.get(
      Uri.parse('$baseUrl/settings/profile'), 
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      
      // Mengirimkan decodedData ke Model. 
      // Karena UserModel.fromJson yang baru sudah punya pengecekan 'user', ini akan aman.
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

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json', // Wajib agar Laravel mengembalikan JSON jika error validasi
        },
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel mewajibkan ini karena ada rules 'confirmed'
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Simpan token yang didapat dari Laravel
        await _saveToken(data['token']);
        
        return {
          'success': true,
          'user': UserModel.fromJson(data['user']),
        };
      } else {
        // Mengambil pesan error dari Laravel (misal: email sudah terdaftar)
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mendaftar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({required String name, String? password}) async {
    try {
      final token = await _getToken();
      
      // Kirim data sesuai ProfileUpdateRequest Laravel
      final Map<String, String> body = {
        'name': name,
      };
      
      // Jika password mau diupdate juga (opsional tergantung logic Laravelmu)
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = password; 
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/settings/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Token dikirim di sini
        },
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true, 
          'user': UserModel.fromJson(data['user'])
        };
      } else {
        return {
          'success': false, 
          'message': data['message'] ?? 'Gagal update'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem'};
    }
  }

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
      await prefs.remove('auth_token'); // Hapus token lokal
      return true;
    } catch (e) {
      return false;
    }
  }
}