import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.login(email, password);
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

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.register(name, email, password);
    _isLoading = false;
    _errorMessage = result['success'] ? '' : result['message'];
    notifyListeners();
    return result['success'];
  }

  Future<void> initUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.getProfile();
    if (result['success']) {
      _user = result['user']; // Data user terisi di sini!
    } else {
      _user = null; // Token tidak valid atau expired
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fungsi Update Profile yang sebelumnya error karena belum ada di AuthService
  Future<bool> updateProfile({required String name, String? password}) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.updateProfile(name: name, password: password);
    if (result['success']) {
      _user = result['user']; // Update state user agar UI Profile langsung berubah
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();
    final success = await _authService.logout();
    if (success) _user = null;
    _isLoading = false;
    notifyListeners();
    return success;
  }
} // <--- Pastikan tidak ada karakter 'r' atau lainnya setelah kurung kurawal ini