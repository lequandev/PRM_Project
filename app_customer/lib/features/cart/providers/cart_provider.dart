import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class CartProvider with ChangeNotifier {
  final List<OrderItemModel> _items = [];

  List<OrderItemModel> get items => _items;
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(ProductModel product, Map<String, String> selectedCustomizations, double extraPrice, int quantity) {
    // Tìm kiếm xem đã có món này với CÙNG tùy chọn chưa
    final existingIndex = _items.indexWhere((item) {
      if (item.productId != product.id) return false;
      if (item.customizations.length != selectedCustomizations.length) return false;
      bool same = true;
      selectedCustomizations.forEach((key, value) {
        if (item.customizations[key] != value) same = false;
      });
      return same;
    });

    final unitPrice = product.basePrice + extraPrice;

    if (existingIndex >= 0) {
      // Nếu sản phẩm đã có trong giỏ hàng (cùng tùy chọn), chỉ tăng số lượng
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        totalPrice: unitPrice * (existingItem.quantity + quantity),
      );
    } else {
      // Thêm mới nếu chưa có
      final newItem = OrderItemModel(
        productId: product.id,
        productName: product.name,
        productImageUrl: product.imageUrl,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: unitPrice * quantity,
        customizations: selectedCustomizations,
        note: '',
      );
      _items.add(newItem);
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length) {
      if (newQuantity > 0) {
        final item = _items[index];
        _items[index] = item.copyWith(
          quantity: newQuantity,
          totalPrice: item.unitPrice * newQuantity,
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
