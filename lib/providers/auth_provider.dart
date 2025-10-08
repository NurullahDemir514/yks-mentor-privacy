import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _authService.currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => user != null;

  Future<void> init() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await _authService.init();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      if (!success) {
        _error = 'Kayıt işlemi başarısız oldu';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _authService.login(email, password);

      if (!success) {
        _error = 'Giriş başarısız';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
