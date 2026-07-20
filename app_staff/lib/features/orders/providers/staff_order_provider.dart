import 'dart:async';
import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class StaffOrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _allActiveOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<OrderModel>>? _subscription;

  List<OrderModel> get allActiveOrders => _allActiveOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<OrderModel> get pendingOrders =>
      _allActiveOrders.where((o) => o.status == OrderStatus.pending.name).toList();

  List<OrderModel> get preparingOrders => _allActiveOrders
      .where((o) => o.status == OrderStatus.accepted.name || o.status == OrderStatus.preparing.name)
      .toList();

  List<OrderModel> get readyOrders =>
      _allActiveOrders.where((o) => o.status == OrderStatus.ready.name).toList();

  StaffOrderProvider() {
    _startWatchingOrders();
  }

  void reload() {
    _subscription?.cancel();
    _startWatchingOrders();
  }

  void _startWatchingOrders() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _orderService.watchActiveOrders().listen(
      (orders) {
        _allActiveOrders = orders;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('Lỗi khi theo dõi đơn hàng: $error');
        _errorMessage = 'Không thể kết nối danh sách đơn hàng.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> acceptOrder(String orderId) async {
    return _updateStatus(orderId, OrderStatus.accepted);
  }

  Future<bool> startPreparing(String orderId) async {
    return _updateStatus(orderId, OrderStatus.preparing);
  }

  Future<bool> markReady(String orderId) async {
    return _updateStatus(orderId, OrderStatus.ready);
  }

  Future<bool> completeOrder(String orderId) async {
    return _updateStatus(orderId, OrderStatus.delivered);
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _orderService.updateOrderStatus(
        orderId: orderId,
        newStatus: OrderStatus.cancelled,
        cancelReason: reason,
      );
      return true;
    } catch (e) {
      AppLogger.error('Lỗi khi hủy đơn hàng $orderId: $e');
      return false;
    }
  }

  Future<bool> _updateStatus(String orderId, OrderStatus status) async {
    try {
      await _orderService.updateOrderStatus(
        orderId: orderId,
        newStatus: status,
      );
      return true;
    } catch (e) {
      AppLogger.error('Lỗi khi cập nhật trạng thái đơn $orderId sang ${status.name}: $e');
      return false;
    }
  }

  Future<OrderModel?> getOrderDetails(String orderId) async {
    try {
      return await _orderService.getOrderById(orderId);
    } catch (e) {
      AppLogger.error('Lỗi khi lấy thông tin đơn hàng $orderId: $e');
      return null;
    }
  }

  // UC-25: In hóa đơn (Mocking Receipt Printing)
  Future<bool> mockPrintReceipt(OrderModel order) async {
    AppLogger.info('Bắt đầu in hóa đơn cho đơn hàng: ${order.id}');
    // Giả lập thời gian kết nối máy in và in hóa đơn (1.5s)
    await Future.delayed(const Duration(milliseconds: 1500));
    AppLogger.info('Đã in hóa đơn thành công cho đơn hàng: ${order.id}');
    return true;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
