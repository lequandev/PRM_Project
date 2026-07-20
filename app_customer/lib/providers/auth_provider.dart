import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUserData = prefs.getString('cached_user');
    
    if (cachedUserData != null) {
      try {
        _currentUser = UserModel.fromJson(json.decode(cachedUserData));
        _isInitializing = false;
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to load cached user: $e');
      }
    }

    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _currentUser = null;
        await prefs.remove('cached_user');
      } else {
        try {
          final realUser = await _authService.getCurrentUserModel();
          if (realUser != null) {
            _currentUser = realUser;
            await prefs.setString('cached_user', json.encode(realUser.toJson()));
          }
        } catch (e) {
          debugPrint('Failed to fetch real user from Firestore: $e');
        }
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Gọi hàm sign-in từ AuthService (UC-02)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError("Đã xảy ra lỗi không xác định.");
      _setLoading(false);
      return false;
    }
  }

  /// Gọi hàm đăng ký từ AuthService (UC-01)
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authService.registerCustomer(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError("Đã xảy ra lỗi không xác định.");
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
