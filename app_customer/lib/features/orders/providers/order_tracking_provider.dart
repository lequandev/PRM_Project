import 'dart:async';

import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/foundation.dart';

import '../../../data/order_repository.dart';

/// Provider màn theo dõi đơn realtime (UC-19).
///
/// Subscribe [OrderRepository.watchOrder] ngay trong constructor — mỗi lần
/// staff (giả lập) đổi trạng thái, stream đẩy OrderModel mới và UI rebuild.
class OrderTrackingProvider extends ChangeNotifier {
  OrderTrackingProvider(this._repository, this.orderId) {
    _subscription = _repository.watchOrder(orderId).listen(
      (order) {
        _order = order;
        _error = null;
        _notify();
      },
      onError: (Object _) {
        _error = 'Mất kết nối cập nhật đơn hàng. Vui lòng thử lại.';
        _notify();
      },
    );
    // Fallback 1 lần: nếu orderId không tồn tại thì stream im lặng mãi,
    // cần getOrderById để hiện lỗi thay vì loading vô hạn.
    _loadOnce();
  }

  final OrderRepository _repository;
  final String orderId;

  StreamSubscription<OrderModel>? _subscription;
  OrderModel? _order;
  String? _error;
  String? _cancelError;
  bool _isCancelling = false;
  bool _disposed = false;

  OrderModel? get order => _order;
  String? get error => _error;

  /// Lỗi riêng của thao tác hủy đơn (không đè lên state màn hình).
  String? get cancelError => _cancelError;
  bool get isCancelling => _isCancelling;

  Future<void> _loadOnce() async {
    try {
      final order = await _repository.getOrderById(orderId);
      _order ??= order;
      _notify();
    } catch (_) {
      if (_order == null) {
        _error = 'Không tìm thấy đơn hàng $orderId.';
        _notify();
      }
    }
  }

  /// Hủy đơn với lý do (bắt buộc). Trả về true nếu thành công,
  /// false nếu lỗi — đọc thông báo qua [cancelError].
  Future<bool> cancelOrder(String reason) async {
    _isCancelling = true;
    _cancelError = null;
    _notify();
    try {
      await _repository.cancelOrder(orderId: orderId, reason: reason);
      return true;
    } catch (e) {
      _cancelError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCancelling = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
