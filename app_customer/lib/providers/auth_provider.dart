import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _currentUser = null;
      } else {
        _currentUser = await _authService.getCurrentUserModel();
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
