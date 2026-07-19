import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order/order_model.dart';
import '../models/order/order_status.dart';
import '../models/common/app_exception.dart';

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

  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final ref =
          await _db.collection('orders').add(OrderModel.toFirestore(order));
      final doc = await ref.get();
      return OrderModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  // ─── UC-18: Xem lịch sử đơn hàng ──────────────────────
  // Dev 3 dùng — OrderHistoryProvider

  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    try {
      // Cần composite index: orders(customerId ASC, createdAt DESC)
      // — đã khai báo trong firestore.indexes.json ở root repo.
      final snap = await _db
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  // ─── UC-19: Theo dõi realtime ─────────────────────────
  // Dev 3 dùng — OrderTrackingProvider

  Stream<OrderModel> watchOrder(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw DatabaseException.notFound('Đơn hàng');
      }
      return OrderModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  // ─── UC-20: Hàng đợi Staff (realtime) ─────────────────
  // Dev 4 dùng — StaffQueueProvider

  Stream<List<OrderModel>> watchActiveOrders() {
    return _db
        .collection('orders')
        .where('status', whereIn: ['pending', 'accepted', 'preparing', 'ready'])
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
              .toList();
          orders.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
          return orders;
        });
  }

  // ─── UC-21→24, UC-26: Cập nhật trạng thái ────────────
  // Dev 4 dùng — StaffOrderProvider

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? cancelReason,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newStatus == OrderStatus.accepted) {
        updates['acceptedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == OrderStatus.ready) {
        updates['readyAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == OrderStatus.delivered) {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
      }
      if (cancelReason != null) {
        updates['cancelReason'] = cancelReason;
      }
      await _db.collection('orders').doc(orderId).update(updates);
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final doc = await _db.collection('orders').doc(orderId).get();
      if (!doc.exists || doc.data() == null) {
        throw DatabaseException.notFound('Đơn hàng');
      }
      return OrderModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException.unknown(e);
    }
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
