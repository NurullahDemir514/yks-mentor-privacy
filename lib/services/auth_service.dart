import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'mongodb_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  static final AuthService instance = AuthService._init();
  final _storage = const FlutterSecureStorage();
  User? _currentUser;
  bool _isInitialized = false;
  final String _userKey = 'user_data';

  AuthService._init();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('Auth servisi başlatılıyor...');
      await MongoDBService.instance.init();

      await _loadUserFromPrefs();

      _isInitialized = true;
      print('Auth servisi başlatıldı');
    } catch (e) {
      print('Auth init hatası detayı: $e');
      print('Stack trace: ${StackTrace.current}');
      _currentUser = null;
      await _storage.delete(key: 'user_id');
      rethrow;
    }
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final user = await MongoDBService.instance.getUserById(userData);
      if (user != null) {
        _currentUser = User.fromMap(user);
      }
    }
  }

  Future<void> _saveUserToPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userId);
  }

  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('Kayıt işlemi başlatılıyor...');
      final userData =
          await MongoDBService.instance.registerUser(email, password, name);
      if (userData != null) {
        _currentUser = User.fromMap(userData);
        await _storage.write(
            key: 'user_id', value: userData['_id'].toHexString());
        await _saveUserToPrefs(userData['_id'].toHexString());
        print('Kayıt başarılı: ${_currentUser?.email}');
        return true;
      }
      print('Kayıt başarısız');
      return false;
    } catch (e, stackTrace) {
      print('Kayıt hatası detayı: $e');
      print('Hata türü: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('Giriş işlemi başlatılıyor...');
      await _ensureInitialized();
      final userData = await MongoDBService.instance.loginUser(email, password);
      if (userData != null) {
        _currentUser = User.fromMap(userData);
        await _storage.write(
            key: 'user_id', value: userData['_id'].toHexString());
        await _saveUserToPrefs(userData['_id'].toHexString());
        print('Giriş başarılı: ${_currentUser?.email}');
        return true;
      }
      print('Giriş başarısız: Kullanıcı bulunamadı');
      return false;
    } catch (e) {
      print('Giriş hatası detayı: $e');
      print('Stack trace: ${StackTrace.current}');
      _currentUser = null;
      await _storage.delete(key: 'user_id');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      print('Çıkış yapılıyor...');
      await _storage.delete(key: 'user_id');
      _currentUser = null;
      await _clearUserFromPrefs();
      print('Çıkış başarılı');
    } catch (e) {
      print('Çıkış hatası detayı: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<bool> validateCurrentSession() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      final sessionId = await _storage.read(key: 'session_id');

      if (userId == null || sessionId == null) {
        return false;
      }

      return await MongoDBService.instance.validateSession(userId, sessionId);
    } catch (e) {
      print('Oturum doğrulama hatası: $e');
      return false;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<void> updateProfilePhoto(File imageFile) async {
    try {
      if (_currentUser == null) throw Exception('Kullanıcı oturumu bulunamadı');

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final collection = MongoDBService.instance.getCollection('users');
      await collection.update(
        where.eq('_id', _currentUser!.id),
        {
          '\$set': {
            'profilePhoto': base64Image,
          }
        },
      );

      _currentUser = _currentUser!.copyWith(profilePhoto: base64Image);
    } catch (e) {
      print('Profil fotoğrafı güncellenirken hata: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Mevcut şifreyi doğrula
      final isValid = await MongoDBService.instance
          .validatePassword(user.email, currentPassword);
      if (!isValid) {
        throw Exception('Mevcut şifre yanlış');
      }

      // Şifreyi güncelle
      await MongoDBService.instance.updatePassword(user.id, newPassword);
    } catch (e) {
      throw Exception(
          'Şifre değiştirme işlemi başarısız oldu: ${e.toString()}');
    }
  }
}
