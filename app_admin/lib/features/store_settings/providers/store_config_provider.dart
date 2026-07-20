import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// StoreConfigProvider — Quản lý cấu hình cửa hàng (UC-36).
class StoreConfigProvider extends ChangeNotifier {
  final StoreConfigService _service = StoreConfigService();

  StoreConfig? _config;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  StoreConfig? get config => _config;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  StoreConfigProvider() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    _isLoading = true;
    notifyListeners();
    try {
      _config = await _service.getStoreConfig();
    } catch (e) {
      _errorMessage = 'Lỗi tải cấu hình: $e';
      AppLogger.error('StoreConfigProvider._loadConfig: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConfig(StoreConfig newConfig) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.updateStoreConfig(newConfig);
      _config = newConfig;
      _successMessage = 'Đã lưu cấu hình thành công!';
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi lưu cấu hình: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleStoreOpen(bool isOpen) async {
    try {
      await _service.toggleStoreOpen(isOpen);
      if (_config != null) {
        _config = StoreConfig(
          storeName: _config!.storeName,
          address: _config!.address,
          phone: _config!.phone,
          openTime: _config!.openTime,
          closeTime: _config!.closeTime,
          isOpen: isOpen,
          deliveryFee: _config!.deliveryFee,
          minDeliveryOrder: _config!.minDeliveryOrder,
          loyaltyRate: _config!.loyaltyRate,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật trạng thái: $e';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
