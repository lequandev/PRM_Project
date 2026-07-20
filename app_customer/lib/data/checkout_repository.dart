import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'fake_seed.dart';
import 'order_repository.dart';

/// Lỗi nghiệp vụ voucher — message hiển thị thẳng lên UI.
class VoucherException implements Exception {
  VoucherException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// CheckoutRepository — validate voucher (UC-14) + tạo đơn (UC-17).
///
/// Bản thật sẽ bọc VoucherService.validateVoucher + OrderService.createOrder
/// (+ incrementUsageCount) của core. UI không cần đổi khi swap.
abstract class CheckoutRepository {
  Future<VoucherModel> validateVoucher({
    required String code,
    required double orderTotal,
    required String userId,
  });

  Future<OrderModel> placeOrder(OrderModel order);

  /// Phí ship / đơn tối thiểu / tỷ lệ tích điểm (UC-36 cung cấp).
  Future<StoreConfig> getStoreConfig();
}

class FakeCheckoutRepository implements CheckoutRepository {
  FakeCheckoutRepository(this._orderRepository);

  final OrderRepository _orderRepository;

  static const _latency = Duration(milliseconds: 500);

  @override
  Future<VoucherModel> validateVoucher({
    required String code,
    required double orderTotal,
    required String userId,
  }) async {
    await Future.delayed(_latency);
    final normalized = code.trim().toUpperCase();
    final matches = FakeSeed.vouchers.where((v) => v.code == normalized);
    if (matches.isEmpty) {
      throw VoucherException('Mã "$normalized" không tồn tại.');
    }
    final voucher = matches.first;
    if (!voucher.isActive) {
      throw VoucherException('Mã $normalized đã bị vô hiệu hóa.');
    }
    if (DateTime.now().isAfter(voucher.expiresAt)) {
      throw VoucherException('Mã $normalized đã hết hạn.');
    }
    if (orderTotal < voucher.minOrderValue) {
      throw VoucherException(
          'Đơn tối thiểu ${voucher.minOrderValue.toVnd} mới dùng được mã này.');
    }
    return voucher;
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) =>
      _orderRepository.createOrder(order);

  @override
  Future<StoreConfig> getStoreConfig() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const StoreConfig(
      storeName: 'Coffee Shop',
      address: '',
      phone: '',
      openTime: '07:00',
      closeTime: '22:00',
      isOpen: true,
      deliveryFee: FakeSeed.deliveryFee,
      minDeliveryOrder: FakeSeed.minDeliveryOrder,
      loyaltyRate: FakeSeed.loyaltyRate,
    );
  }
}
