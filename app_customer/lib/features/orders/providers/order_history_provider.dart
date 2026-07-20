import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/foundation.dart';

import '../../../data/order_repository.dart';
import '../../../data/session.dart';

/// Nhóm filter trên màn lịch sử đơn hàng (UC-18).
enum OrderHistoryFilter {
  all,
  processing,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case OrderHistoryFilter.all:
        return 'Tất cả';
      case OrderHistoryFilter.processing:
        return 'Đang xử lý';
      case OrderHistoryFilter.completed:
        return 'Hoàn thành';
      case OrderHistoryFilter.cancelled:
        return 'Đã hủy';
    }
  }

  bool matches(OrderModel order) {
    switch (this) {
      case OrderHistoryFilter.all:
        return true;
      case OrderHistoryFilter.processing:
        return const {
          OrderStatus.pending,
          OrderStatus.accepted,
          OrderStatus.preparing,
          OrderStatus.ready,
        }.contains(order.orderStatus);
      case OrderHistoryFilter.completed:
        return order.orderStatus == OrderStatus.delivered;
      case OrderHistoryFilter.cancelled:
        return order.orderStatus == OrderStatus.cancelled;
    }
  }
}

/// Provider màn lịch sử đơn hàng — load qua [OrderRepository], lọc theo nhóm.
class OrderHistoryProvider extends ChangeNotifier {
  OrderHistoryProvider(this._repository, this._session) {
    refresh();
  }

  final OrderRepository _repository;
  final CurrentSession _session;

  bool _isLoading = true;
  String? _error;
  List<OrderModel> _orders = const [];
  OrderHistoryFilter _filter = OrderHistoryFilter.all;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Toàn bộ đơn của khách (đã sort mới nhất trước từ repository).
  List<OrderModel> get orders => _orders;

  OrderHistoryFilter get filter => _filter;

  /// Danh sách sau khi áp filter đang chọn.
  List<OrderModel> get filteredOrders =>
      _orders.where(_filter.matches).toList();

  /// Tải (lại) danh sách đơn. Dùng cho cả lần đầu lẫn pull-to-refresh.
  Future<void> refresh() async {
    if (_orders.isEmpty) {
      _isLoading = true;
      _error = null;
      _notify();
    }
    try {
      _orders = await _repository.getOrdersByCustomer(_session.uid);
      _error = null;
    } catch (_) {
      _error = 'Không tải được danh sách đơn hàng. Vui lòng thử lại.';
    }
    _isLoading = false;
    _notify();
  }

  void setFilter(OrderHistoryFilter value) {
    if (_filter == value) return;
    _filter = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
