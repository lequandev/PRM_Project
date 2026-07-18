import 'dart:async';

import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'fake_seed.dart';

/// OrderRepository — cổng dữ liệu đơn hàng cho toàn bộ feature của Dev 3.
///
/// UI/Provider CHỈ phụ thuộc interface này. Hiện tại dùng [FakeOrderRepository]
/// (OrderService trong core còn UnimplementedError). Khi Dev 1 implement xong,
/// viết CoreOrderRepository bọc OrderService rồi đổi 1 dòng trong main.dart —
/// không đụng UI.
abstract class OrderRepository {
  Future<List<OrderModel>> getOrdersByCustomer(String customerId);

  Future<OrderModel> getOrderById(String orderId);

  /// UC-19 — stream realtime, khớp chữ ký OrderService.watchOrder.
  Stream<OrderModel> watchOrder(String orderId);

  /// UC-17 — tạo đơn, trả về đơn đã có id + createdAt.
  Future<OrderModel> createOrder(OrderModel order);

  /// Customer tự hủy khi status == pending (OrderStatus.canCustomerCancel).
  Future<void> cancelOrder({required String orderId, required String reason});

  /// UC-39 — gửi đánh giá sản phẩm sau khi đơn delivered.
  Future<void> submitReview({
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
  });
}

/// Kho đơn hàng in-memory + mô phỏng staff xử lý đơn để demo tracking UC-19:
/// pending → accepted → preparing → ready → delivered, mỗi bước [stepDuration].
class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({this.stepDuration = const Duration(seconds: 8)}) {
    _orders.addAll(FakeSeed.historyOrders());
  }

  final Duration stepDuration;
  final List<OrderModel> _orders = [];
  final Map<String, StreamController<OrderModel>> _watchers = {};
  final Map<String, Timer> _simulators = {};
  int _seq = 3;

  static const _latency = Duration(milliseconds: 400);

  OrderModel _byId(String orderId) =>
      _orders.firstWhere((o) => o.id == orderId,
          orElse: () => throw Exception('Không tìm thấy đơn $orderId'));

  void _emit(OrderModel order) {
    final i = _orders.indexWhere((o) => o.id == order.id);
    if (i >= 0) _orders[i] = order;
    _watchers[order.id]?.add(order);
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    await Future.delayed(_latency);
    final list =
        _orders.where((o) => o.customerId == customerId).toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000)));
    return list;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    await Future.delayed(_latency);
    return _byId(orderId);
  }

  @override
  Stream<OrderModel> watchOrder(String orderId) {
    final controller = _watchers.putIfAbsent(
      orderId,
      () => StreamController<OrderModel>.broadcast(),
    );
    // Phát trạng thái hiện tại ngay khi subscribe (giống Firestore snapshots).
    scheduleMicrotask(() {
      final existing = _orders.where((o) => o.id == orderId);
      if (existing.isNotEmpty) controller.add(existing.first);
    });
    return controller.stream;
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    await Future.delayed(_latency);
    _seq++;
    final now = DateTime.now();
    final id =
        'OD-${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_seq.toString().padLeft(3, '0')}';
    final created = order.copyWith(
      id: id,
      status: OrderStatus.pending.name,
      createdAt: now,
      updatedAt: now,
    );
    _orders.insert(0, created);
    _startSimulation(id);
    return created;
  }

  @override
  Future<void> cancelOrder(
      {required String orderId, required String reason}) async {
    await Future.delayed(_latency);
    final order = _byId(orderId);
    if (!order.orderStatus.canCustomerCancel) {
      throw Exception('Đơn đã được quán xác nhận, không thể tự hủy.');
    }
    _simulators.remove(orderId)?.cancel();
    _emit(order.copyWith(
      status: OrderStatus.cancelled.name,
      cancelReason: reason,
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> submitReview({
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    // Mock: chỉ giả lập độ trễ. Bản thật gọi ProductService.submitReview.
    await Future.delayed(_latency);
  }

  /// Giả lập staff app (Dev 4) xử lý đơn để màn tracking có dữ liệu sống.
  void _startSimulation(String orderId) {
    const chain = [
      OrderStatus.accepted,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.delivered,
    ];
    var step = 0;
    _simulators[orderId] = Timer.periodic(stepDuration, (timer) {
      final order = _byId(orderId);
      if (order.orderStatus.isTerminal || step >= chain.length) {
        timer.cancel();
        _simulators.remove(orderId);
        return;
      }
      final next = chain[step++];
      final now = DateTime.now();
      _emit(order.copyWith(
        status: next.name,
        updatedAt: now,
        acceptedAt: next == OrderStatus.accepted ? now : order.acceptedAt,
        readyAt: next == OrderStatus.ready ? now : order.readyAt,
        deliveredAt: next == OrderStatus.delivered ? now : order.deliveredAt,
        paymentStatus: next == OrderStatus.delivered &&
                order.paymentMethod == PaymentMethod.cash.name
            ? PaymentStatus.paid.name
            : order.paymentStatus,
      ));
    });
  }

  void dispose() {
    for (final t in _simulators.values) {
      t.cancel();
    }
    for (final c in _watchers.values) {
      c.close();
    }
  }
}
