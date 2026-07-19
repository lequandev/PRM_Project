import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'checkout_repository.dart';
import 'order_repository.dart';
import 'profile_repository.dart';
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
  CoreProfileRepository(this._users, this._auth, this._fallback);

  final UserService _users;
  final AuthService _auth;
  final FakeProfileRepository _fallback;

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
  Future<int> getLoyaltyPoints(String uid) async {
    final user = await _users.getUserById(uid);
    return user?.loyaltyPoints ?? 0;
  }

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

  // ─── Loyalty: core CHƯA có service — fake tạm, chờ bàn với Dev 1 ───

  @override
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactions(String uid) =>
      _fallback.getLoyaltyTransactions(uid);

  @override
  Future<String> redeemPoints({required String uid, required int points}) =>
      _fallback.redeemPoints(uid: uid, points: points);
}
