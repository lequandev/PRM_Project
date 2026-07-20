import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// AdminAuthProvider — RBAC authentication cho Admin Web App.
/// Chỉ cho phép users có role == 'admin'.
class AdminAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _currentUser!.role == 'admin';

  AdminAuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        await _fetchUserInfo(firebaseUser.uid);
      }
    });
  }

  Future<void> _fetchUserInfo(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userService.getUserById(uid);
      if (user != null && user.role == 'admin' && user.isActive) {
        _currentUser = user;
      } else {
        await _authService.signOut();
        _currentUser = null;
        if (user != null && user.role != 'admin') {
          _errorMessage = 'Tài khoản không có quyền truy cập Admin Dashboard.';
        } else if (user != null && !user.isActive) {
          _errorMessage = 'Tài khoản đã bị vô hiệu hóa.';
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

      if (user.role != 'admin') {
        _errorMessage = 'Tài khoản này không có quyền Admin.';
        await _authService.signOut();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!user.isActive) {
        _errorMessage = 'Tài khoản đã bị vô hiệu hóa.';
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
      // Nếu tài khoản được tạo thủ công trên Firebase Console nhưng chưa có
      // document trong Firestore, AuthService sẽ ném lỗi "Không tìm thấy".
      // Tại thời điểm này, FirebaseAuth đã login thành công, ta tự động cấp quyền Admin.
      if (e.message.toLowerCase().contains('không tìm thấy')) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && fbUser.email == email) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
              'uid': fbUser.uid,
              'email': fbUser.email,
              'name': 'Admin (Console)',
              'role': 'admin',
              'phone': '',
              'loyaltyPoints': 0,
              'isActive': true,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            // Fetch lại user vừa tạo
            final newUser = await _userService.getUserById(fbUser.uid);
            if (newUser != null) {
              _currentUser = newUser;
              _isLoading = false;
              notifyListeners();
              return true;
            }
          } catch (err) {
            _errorMessage = 'Lỗi cấp quyền Admin: $err';
          }
        }
      }

      if (_currentUser == null) {
        _errorMessage = e.message;
      }
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
