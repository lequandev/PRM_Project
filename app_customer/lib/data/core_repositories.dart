import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'checkout_repository.dart';
import 'order_repository.dart';
import 'session.dart';

/// Bản THẬT của [OrderRepository] — bọc service Firebase trong core_module.
/// UI không đổi một dòng: chỉ swap nơi khởi tạo trong app.dart.
class CoreOrderRepository implements OrderRepository {
  CoreOrderRepository(this._orders, this._products, this._session);

  final OrderService _orders;
  final ProductService _products;
  final CurrentSession _session;

  @override
  Future<OrderModel> createOrder(OrderModel order) =>
      _orders.createOrder(order);

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) =>
      _orders.getOrdersByCustomer(customerId);

  @override
  Future<OrderModel> getOrderById(String orderId) =>
      _orders.getOrderById(orderId);

  @override
  Stream<OrderModel> watchOrder(String orderId) => _orders.watchOrder(orderId);

  @override
  Future<void> cancelOrder({required String orderId, required String reason}) =>
      _orders.updateOrderStatus(
        orderId: orderId,
        newStatus: OrderStatus.cancelled,
        cancelReason: reason,
      );

  @override
  Future<void> submitReview({
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
  }) {
    final trimmed = comment?.trim();
    return _products.submitReview(
      productId: productId,
      review: ReviewModel(
        id: '', // Firestore sinh id khi add
        userId: _session.uid,
        userName: _session.name,
        orderId: orderId,
        rating: rating,
        comment: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      ),
    );
  }
}

/// Bản THẬT của [CheckoutRepository] — voucher + đặt hàng qua core services.
class CoreCheckoutRepository implements CheckoutRepository {
  CoreCheckoutRepository(this._vouchers, this._orders);

  final VoucherService _vouchers;
  final OrderService _orders;

  @override
  Future<VoucherModel> validateVoucher({
    required String code,
    required double orderTotal,
    required String userId,
  }) async {
    try {
      return await _vouchers.validateVoucher(
        code: code,
        orderTotal: orderTotal,
        userId: userId,
      );
    } on AppException catch (e) {
      // Map lỗi nghiệp vụ của core sang lỗi UI của màn checkout
      throw VoucherException(e.message);
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    final created = await _orders.createOrder(order);
    final code = order.voucherCode;
    if (code != null) {
      try {
        await _vouchers.incrementUsageCount(code);
      } catch (_) {
        // Counter fail không được chặn đơn đã tạo thành công.
      }
    }
    return created;
  }
}
