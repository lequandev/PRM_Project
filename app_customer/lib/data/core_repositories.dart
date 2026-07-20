import 'dart:async';

import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'checkout_repository.dart';
import 'order_repository.dart';
import 'profile_repository.dart';
import 'session.dart';

/// Bản THẬT của [OrderRepository] — bọc service Firebase trong core_module.
/// UI không đổi một dòng: chỉ swap nơi khởi tạo trong app.dart.
class CoreOrderRepository implements OrderRepository {
  CoreOrderRepository(
      this._orders, this._products, this._session, this._loyalty);

  final OrderService _orders;
  final ProductService _products;
  final CurrentSession _session;
  final LoyaltyService _loyalty;

  /// Đơn đã cộng điểm trong phiên này — tránh gọi transaction lặp mỗi lần
  /// stream đẩy. Server còn 1 lớp idempotent nữa (doc earn_{orderId}).
  final Set<String> _awardedOrderIds = {};

  /// UC-27: cộng điểm khi khách xem đơn đã `delivered`. Không có Cloud Functions
  /// nên đây là nơi kích hoạt cộng điểm. Fire-and-forget, lỗi không chặn UI.
  void _maybeAward(OrderModel order) {
    if (order.orderStatus != OrderStatus.delivered) return;
    if (order.id.isEmpty || order.loyaltyPointsEarned <= 0) return;
    if (!_awardedOrderIds.add(order.id)) return;
    unawaited(
      _loyalty.awardPointsForOrder(order.customerId, order).catchError(
        (Object _) {
          _awardedOrderIds.remove(order.id); // lỗi → cho phép thử lại
        },
      ),
    );
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) =>
      _orders.createOrder(order);

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    final orders = await _orders.getOrdersByCustomer(customerId);
    for (final o in orders) {
      _maybeAward(o);
    }
    return orders;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final order = await _orders.getOrderById(orderId);
    _maybeAward(order);
    return order;
  }

  @override
  Stream<OrderModel> watchOrder(String orderId) =>
      _orders.watchOrder(orderId).map((order) {
        _maybeAward(order);
        return order;
      });

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
  CoreCheckoutRepository(this._vouchers, this._orders, this._storeConfig);

  final VoucherService _vouchers;
  final OrderService _orders;
  final StoreConfigService _storeConfig;

  @override
  Future<StoreConfig> getStoreConfig() => _storeConfig.getStoreConfig();

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

/// Bản LAI của [ProfileRepository]: phần core đã implement thì chạy THẬT
/// (hồ sơ + điểm từ UserService.getUserById, reset password từ AuthService),
/// phần UserService còn stub thì tạm ủy quyền về [FakeProfileRepository].
///
/// TODO(core PR #2): khi UserService có addresses CRUD / updateProfile /
/// deactivateAccount và loyalty có service thật → thay từng dòng _fallback.
class CoreProfileRepository implements ProfileRepository {
  CoreProfileRepository(this._users, this._auth, this._loyalty);

  final UserService _users;
  final AuthService _auth;
  final LoyaltyService _loyalty;

  @override
  Future<ProfileData> getProfile(String uid) async {
    final user = await _users.getUserById(uid);
    if (user == null) {
      throw DatabaseException.notFound('Tài khoản');
    }
    return ProfileData(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      loyaltyPoints: user.loyaltyPoints,
    );
  }

  @override
  Future<int> getLoyaltyPoints(String uid) => _loyalty.getPoints(uid);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email);

  @override
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? avatarUrl,
  }) =>
      _users.updateProfile(
          uid: uid, name: name, phone: phone, avatarUrl: avatarUrl);

  @override
  Future<List<AddressModel>> getAddresses(String uid) =>
      _users.getAddresses(uid);

  @override
  Future<AddressModel> addAddress(
          {required String uid, required AddressModel address}) =>
      _users.addAddress(uid: uid, address: address);

  @override
  Future<void> updateAddress(
          {required String uid, required AddressModel address}) =>
      _users.updateAddress(uid: uid, address: address);

  @override
  Future<void> deleteAddress(
          {required String uid, required String addressId}) =>
      _users.deleteAddress(uid: uid, addressId: addressId);

  @override
  Future<void> deactivateAccount(String uid) =>
      _users.deactivateAccount(uid);

  // ─── Loyalty (UC-27/28) — LoyaltyService THẬT ───
  // Điểm được CỘNG khi khách xem đơn đã delivered (xem CoreOrderRepository).

  @override
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactions(String uid) =>
      _loyalty.getTransactions(uid);

  /// UC-28: trừ điểm + trả mã voucher thưởng. Không tạo voucher mới (rules chỉ
  /// admin được ghi /vouchers) → trả mã có sẵn GIAM15K để khách áp ở checkout.
  @override
  Future<String> redeemPoints(
      {required String uid, required int points}) async {
    const rewardCode = 'GIAM15K';
    await _loyalty.redeemPoints(
      uid: uid,
      points: points,
      description: 'Đổi $points điểm lấy voucher $rewardCode',
    );
    return rewardCode;
  }
}
