import 'package:flutter/foundation.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'fake_seed.dart';

/// ⚠️ TẠM THỜI — thế chỗ CartProvider thật của Dev 2.
///
/// Dev 3 chỉ ĐỌC cart (theo quy tắc file workflow: "Đọc state từ CartProvider
/// của Dev 2, không sửa file cart"). Class này mô phỏng đúng contract tối
/// thiểu mà checkout cần: items / subtotal / clear.
///
/// Khi Dev 2 (Trung) expose CartProvider thật trong /features/cart:
///   1. Đổi type trong main.dart và checkout_provider.dart
///   2. Xóa file này
/// → Cần chốt contract này với Trung ở buổi Interface Sync.
class FakeCartProvider extends ChangeNotifier {
  FakeCartProvider() {
    _items.addAll(FakeSeed.cartItems);
  }

  final List<OrderItemModel> _items = [];

  List<OrderItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.totalPrice).roundToDouble();

  void add(OrderItemModel item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    final item = _items[index];
    _items[index] = item.copyWith(
      quantity: quantity,
      totalPrice: (item.unitPrice * quantity).roundToDouble(),
    );
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
