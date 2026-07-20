import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// VoucherProvider — CRUD voucher cho Admin (UC-29).
class VoucherProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<VoucherModel> _vouchers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VoucherModel> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<VoucherModel> get activeVouchers =>
      _vouchers.where((v) => v.isActive && v.expiresAt.isAfter(DateTime.now())).toList();

  VoucherProvider() {
    loadVouchers();
  }

  Future<void> loadVouchers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snap = await _db
          .collection('vouchers')
          .orderBy('createdAt', descending: true)
          .get();
      _vouchers = snap.docs
          .map((doc) => VoucherModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách voucher: $e';
      AppLogger.error('VoucherProvider.loadVouchers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVoucher(VoucherModel voucher) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db
          .collection('vouchers')
          .doc(voucher.code.toUpperCase())
          .set(VoucherModel.toFirestore(voucher));
      _vouchers.insert(0, voucher);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo voucher: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateVoucher(String code) async {
    try {
      await _db.collection('vouchers').doc(code).update({'isActive': false});
      final idx = _vouchers.indexWhere((v) => v.code == code);
      if (idx != -1) {
        _vouchers[idx] = _vouchers[idx].copyWith(isActive: false);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi vô hiệu hóa voucher: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateVoucher(String code) async {
    try {
      await _db.collection('vouchers').doc(code).update({'isActive': true});
      final idx = _vouchers.indexWhere((v) => v.code == code);
      if (idx != -1) {
        _vouchers[idx] = _vouchers[idx].copyWith(isActive: true);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi kích hoạt voucher: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVoucher(VoucherModel voucher) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db
          .collection('vouchers')
          .doc(voucher.code.toUpperCase())
          .update(VoucherModel.toFirestore(voucher));
      final idx = _vouchers.indexWhere((v) => v.code == voucher.code);
      if (idx != -1) {
        _vouchers[idx] = voucher;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật voucher: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVoucher(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.collection('vouchers').doc(code.toUpperCase()).delete();
      _vouchers.removeWhere((v) => v.code == code);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa voucher: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
