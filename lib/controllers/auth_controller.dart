import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wajib ditambahkan
import '../models/user_model.dart';
import '../services/auth_services.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _token; // TAMBAHKAN INI UNTUK MENYIMPAN TOKEN DI MEMORI

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // --- GETTER TOKEN (SOLUSI AGAR TIDAK MERAH DI DETAILWISATASCREEN) ---
  String? get token => _token;

  // --- LOGIN DENGAN PENYIMPANAN TOKEN ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = ''; // Reset error message
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success']) {
      _user = result['user'];
      _token = result['token']; // SIMPAN KE VARIABEL LOKAL
      
      // Simpan token ke memori HP agar bisa dibaca DestinasiController
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result['token'] != null) {
        await prefs.setString('token', result['token']);
        debugPrint("Login Berhasil. Token disimpan.");
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    _errorMessage = result['message'] ?? 'Login gagal, periksa email/password';
    notifyListeners();
    return false;
  }

  // --- REGISTER ---
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.register(name, email, password);
    _isLoading = false;
    _errorMessage = result['success'] ? '' : result['message'];
    notifyListeners();
    return result['success'];
  }

  // --- INISIALISASI USER (CEK LOGIN SAAT APLIKASI DIBUKA) ---
  Future<void> initUser() async {
    _isLoading = true;
    notifyListeners();

    // AMBIL TOKEN DARI STORAGE SAAT APLIKASI DIBUKA
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    final result = await _authService.getProfile();
    if (result['success']) {
      _user = result['user'];
    } else {
      _user = null;
      _token = null; // RESET TOKEN JIKA GAGAL
      // Jika token expired, hapus dari storage
      await prefs.remove('token');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- UPDATE PROFILE ---
  Future<bool> updateProfile({required String name, String? password}) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.updateProfile(name: name, password: password);
    if (result['success']) {
      _user = result['user']; 
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  // --- LOGOUT ---
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _authService.logout();
    if (success) {
      _user = null;
      _token = null; // RESET TOKEN SAAT LOGOUT
      // Hapus token dari storage saat logout
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      debugPrint("Logout Berhasil. Token dihapus.");
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }
}