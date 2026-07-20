import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  final List<OrderItemModel> _items = [];

  List<OrderItemModel> get items => _items;
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decodedList = json.decode(cartData);
        _items.clear();
        for (var item in decodedList) {
          _items.add(OrderItemModel.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items', encodedList);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

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
    _saveCart();
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
      _saveCart();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
      _saveCart();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }
}
