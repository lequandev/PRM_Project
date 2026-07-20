import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// InventoryProvider — Quản lý kho nguyên liệu (UC-34 UI, UC-35 Admin).
/// Dùng InventoryService từ core_module (đã implement đầy đủ bởi Dev 1).
class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  StreamSubscription? _inventorySub;
  StreamSubscription<User?>? _authSub;

  List<IngredientModel> _ingredients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<IngredientModel> get ingredients => _ingredients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<IngredientModel> get lowStockItems =>
      _ingredients.where((i) => i.isLow || i.isOutOfStock).toList();
  int get lowStockCount => lowStockItems.length;

  InventoryProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadAndWatch();
      } else {
        _inventorySub?.cancel();
        _inventorySub = null;
        _ingredients = [];
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _inventorySub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  void _loadAndWatch() {
    if (_inventorySub != null) return; // Already listening
    _isLoading = true;
    notifyListeners();

    _inventorySub = _service.watchInventory().listen(
      (list) {
        _ingredients = list;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải kho hàng: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// UC-35: Cập nhật số lượng tồn kho
  Future<bool> updateStock({
    required String ingredientId,
    required double newStock,
    required String updatedBy,
  }) async {
    try {
      await _service.updateStock(
        ingredientId: ingredientId,
        newStock: newStock,
        updatedBy: updatedBy,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật kho: $e';
      notifyListeners();
      return false;
    }
  }

  /// UC-35 Admin: Thêm nguyên liệu mới
  Future<bool> addIngredient(IngredientModel ingredient) async {
    try {
      final created = await _service.addIngredient(ingredient);
      _ingredients.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi thêm nguyên liệu: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

}
