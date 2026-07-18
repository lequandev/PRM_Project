import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _currentUser!.role == 'staff';

  StaffAuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        await _fetchCurrentUserInfo(firebaseUser.uid);
      }
    });
  }

  Future<void> _fetchCurrentUserInfo(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _userService.getUserById(uid);
      if (user != null && user.role == 'staff' && user.isActive) {
        _currentUser = user;
      } else {
        await _authService.signOut();
        _currentUser = null;
        if (user != null && user.role != 'staff') {
          _errorMessage = 'Tài khoản không có quyền truy cập ứng dụng nhân viên.';
        } else if (user != null && !user.isActive) {
          _errorMessage = 'Tài khoản của bạn đã bị khóa.';
        }
      }
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin người dùng.';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(email: email, password: password);
      
      // RBAC validation
      if (user.role != 'staff') {
        _errorMessage = 'Tài khoản không có quyền truy cập ứng dụng nhân viên.';
        await _authService.signOut();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!user.isActive) {
        _errorMessage = 'Tài khoản của bạn đã bị khóa.';
        await _authService.signOut();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không mong muốn.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
