import 'dart:async';
import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class StaffInventoryProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();

  List<IngredientModel> _ingredients = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<IngredientModel>>? _subscription;

  List<IngredientModel> get ingredients => _ingredients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StaffInventoryProvider() {
    _startWatchingInventory();
  }

  void reload() {
    _subscription?.cancel();
    _startWatchingInventory();
  }

  void _startWatchingInventory() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _inventoryService.watchInventory().listen(
      (list) {
        _ingredients = list;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('Lỗi khi theo dõi kho: $error');
        _errorMessage = 'Không thể tải dữ liệu kho hàng.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> updateStockLevel({
    required String ingredientId,
    required double newStock,
    required String updatedBy,
  }) async {
    try {
      await _inventoryService.updateStock(
        ingredientId: ingredientId,
        newStock: newStock,
        updatedBy: updatedBy,
      );
      return true;
    } catch (e) {
      AppLogger.error('Lỗi khi cập nhật tồn kho $ingredientId: $e');
      return false;
    }
  }

  Future<bool> markOutOfStock({
    required String ingredientId,
    required String updatedBy,
  }) async {
    return updateStockLevel(
      ingredientId: ingredientId,
      newStock: 0,
      updatedBy: updatedBy,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
