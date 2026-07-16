import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order/order_model.dart';
import '../models/order/order_status.dart';

/// OrderService — Firestore access layer cho Orders.
///
/// ⚠️  PHÂN CÔNG:
///   - UC-13 → UC-19 (Customer ordering & tracking)  : Dev 3 gọi từ OrderProvider
///   - UC-20 → UC-26 (Staff queue & status updates)  : Dev 4 gọi từ StaffOrderProvider
///   - UC-37 (Revenue reports)                       : Dev 5 gọi từ AnalyticsProvider
///
/// Dev 1 owns file này — chỉ Dev 1 được sửa.
/// Dev 3/4/5: KHÔNG sửa file này, gọi methods qua Provider của mình.
class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── UC-17: Đặt hàng xác nhận ─────────────────────────
  // Dev 3 dùng — CheckoutProvider

  Future<OrderModel> createOrder(OrderModel order) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-17)
    throw UnimplementedError('OrderService.createOrder — chưa implement');
  }

  // ─── UC-18: Xem lịch sử đơn hàng ──────────────────────
  // Dev 3 dùng — OrderHistoryProvider

  Future<List<OrderModel>> getOrdersByCustomer(String customerId) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-18)
    throw UnimplementedError('OrderService.getOrdersByCustomer — chưa implement');
  }

  // ─── UC-19: Theo dõi realtime ─────────────────────────
  // Dev 3 dùng — OrderTrackingProvider

  Stream<OrderModel> watchOrder(String orderId) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-19)
    throw UnimplementedError('OrderService.watchOrder — chưa implement');
  }

  // ─── UC-20: Hàng đợi Staff (realtime) ─────────────────
  // Dev 4 dùng — StaffQueueProvider

  Stream<List<OrderModel>> watchActiveOrders() {
    // TODO: Dev 1 implements khi Dev 4 cần (UC-20)
    throw UnimplementedError('OrderService.watchActiveOrders — chưa implement');
  }

  // ─── UC-21→24, UC-26: Cập nhật trạng thái ────────────
  // Dev 4 dùng — StaffOrderProvider

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? cancelReason,
  }) {
    // TODO: Dev 1 implements khi Dev 4 cần (UC-21→24, UC-26)
    throw UnimplementedError('OrderService.updateOrderStatus — chưa implement');
  }

  Future<OrderModel> getOrderById(String orderId) {
    // TODO: Dev 1 implements khi Dev 3/4 cần
    throw UnimplementedError('OrderService.getOrderById — chưa implement');
  }

  // ─── UC-37: Báo cáo doanh thu ─────────────────────────
  // Dev 5 dùng — AnalyticsProvider

  Future<List<OrderModel>> getOrdersByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-37)
    throw UnimplementedError('OrderService.getOrdersByDateRange — chưa implement');
  }
}
