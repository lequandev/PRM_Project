import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class CartProvider with ChangeNotifier {
  final List<OrderItemModel> _items = [];

  List<OrderItemModel> get items => _items;
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(ProductModel product, List<CustomizationModel> customizations, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Nếu sản phẩm đã có trong giỏ hàng, chỉ tăng số lượng
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        totalPrice: existingItem.unitPrice * (existingItem.quantity + quantity),
      );
    } else {
      // Thêm mới nếu chưa có
      final newItem = OrderItemModel(
        productId: product.id,
        productName: product.name,
        productImageUrl: product.imageUrl,
        quantity: quantity,
        unitPrice: product.basePrice,
        totalPrice: product.basePrice * quantity,
        customizations: {}, // Tạm thời rỗng, cần map CustomizationModel
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
