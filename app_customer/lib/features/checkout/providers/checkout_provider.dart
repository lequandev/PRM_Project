import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/foundation.dart';

import '../../../data/app_session.dart';
import '../../../data/checkout_repository.dart';
import '../../../data/fake_seed.dart';
import '../../../data/profile_repository.dart';
import '../../cart/providers/cart_provider.dart';

/// CheckoutProvider — state cho màn thanh toán (UC-13 → UC-17).
///
/// Đọc giỏ hàng từ [CartProvider] thật của Dev 2/Tú (chỉ đọc + clearCart),
/// validate voucher + đặt hàng qua [CheckoutRepository],
/// load địa chỉ đã lưu qua [ProfileRepository].
///
/// TODO(Dev 1): OrderModel chưa có field `deliveryFee` — phí giao hàng hiện
/// được cộng thẳng vào totalAmount nhưng không lưu tách riêng trên đơn.
/// Đã tạo issue cho Dev 1 bổ sung field này vào core_module.
class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({
    required CheckoutRepository checkoutRepository,
    required ProfileRepository profileRepository,
    required CartProvider cart,
  })  : _checkoutRepository = checkoutRepository,
        _profileRepository = profileRepository,
        _cart = cart {
    // Giỏ hàng đổi (Dev 2 thêm/bớt món) → tiền phải tính lại.
    _cart.addListener(_onCartChanged);
    loadAddresses();
  }

  final CheckoutRepository _checkoutRepository;
  final ProfileRepository _profileRepository;
  final CartProvider _cart;

  // ─── State ────────────────────────────────────────────────

  OrderType orderType = OrderType.pickup;
  AddressModel? selectedAddress;
  PaymentMethod paymentMethod = PaymentMethod.cash;
  VoucherModel? voucher;
  String? voucherError;
  bool isApplyingVoucher = false;
  bool isPlacingOrder = false;
  String note = '';

  List<AddressModel> addresses = [];
  bool isLoadingAddresses = false;

  // ─── Giỏ hàng (chỉ đọc) ───────────────────────────────────

  List<OrderItemModel> get items => _cart.items;

  bool get isCartEmpty => _cart.items.isEmpty;

  int get itemCount => _cart.totalQuantity;

  // ─── Tính tiền (luôn roundToDouble để khớp VND) ───────────

  double get subtotal => _cart.totalAmount.roundToDouble();

  double get discount =>
      (voucher?.calculateDiscount(subtotal) ?? 0).roundToDouble();

  double get deliveryFee =>
      orderType == OrderType.delivery ? FakeSeed.deliveryFee.roundToDouble() : 0;

  double get total => (subtotal - discount + deliveryFee).roundToDouble();

  int get estimatedPoints => (total * FakeSeed.loyaltyRate).floor();

  /// Đơn giao hàng chưa đạt giá trị tối thiểu?
  bool get isBelowDeliveryMinimum =>
      orderType == OrderType.delivery && subtotal < FakeSeed.minDeliveryOrder;

  /// Đủ điều kiện bấm nút Đặt hàng?
  bool get canPlaceOrder =>
      !isCartEmpty &&
      !isPlacingOrder &&
      !isBelowDeliveryMinimum &&
      (orderType == OrderType.pickup || selectedAddress != null);

  // ─── Actions ──────────────────────────────────────────────

  /// Load địa chỉ đã lưu, tự chọn sẵn địa chỉ mặc định (isDefault).
  Future<void> loadAddresses() async {
    isLoadingAddresses = true;
    notifyListeners();
    try {
      addresses = await _profileRepository.getAddresses(AppSession.uid);
      if (selectedAddress == null && addresses.isNotEmpty) {
        selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }
    } finally {
      isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void setOrderType(OrderType type) {
    if (orderType == type) return;
    orderType = type;
    notifyListeners();
  }

  void setAddress(AddressModel address) {
    selectedAddress = address;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    if (paymentMethod == method) return;
    paymentMethod = method;
    notifyListeners();
  }

  void setNote(String value) {
    note = value;
    // Không notify — TextField tự giữ text, tránh rebuild cả màn mỗi ký tự.
  }

  /// UC-14 — kiểm tra mã giảm giá. Lỗi nghiệp vụ hiển thị qua [voucherError].
  Future<void> applyVoucher(String code) async {
    if (code.trim().isEmpty) {
      voucherError = 'Vui lòng nhập mã giảm giá.';
      notifyListeners();
      return;
    }
    isApplyingVoucher = true;
    voucherError = null;
    notifyListeners();
    try {
      voucher = await _checkoutRepository.validateVoucher(
        code: code,
        orderTotal: subtotal,
        userId: AppSession.uid,
      );
      voucherError = null;
    } on VoucherException catch (e) {
      voucher = null;
      voucherError = e.message;
    } catch (_) {
      voucher = null;
      voucherError = 'Không kiểm tra được mã. Thử lại sau nhé.';
    } finally {
      isApplyingVoucher = false;
      notifyListeners();
    }
  }

  void removeVoucher() {
    voucher = null;
    voucherError = null;
    notifyListeners();
  }

  /// UC-17 — dựng OrderModel từ state hiện tại và gửi cho repository.
  /// Trả về đơn đã có id thật + createdAt. Ném lại exception cho UI xử lý.
  Future<OrderModel> placeOrder() async {
    isPlacingOrder = true;
    notifyListeners();
    try {
      final trimmedNote = note.trim();
      final order = OrderModel(
        id: '', // repository sinh id thật khi tạo đơn
        customerId: AppSession.uid,
        customerName: AppSession.name,
        customerPhone: AppSession.phone,
        items: List.of(_cart.items),
        subtotal: subtotal,
        discountAmount: discount,
        totalAmount: total,
        orderType: orderType.name,
        deliveryAddress: orderType == OrderType.delivery
            ? AddressModel.toFirestore(selectedAddress!)
            : null,
        voucherCode: voucher?.code,
        paymentMethod: paymentMethod.name,
        // Cổng online (VNPay/MoMo/ZaloPay) đang chạy chế độ Demo —
        // giả lập đã thanh toán thành công. Tiền mặt thì chờ thu khi giao.
        paymentStatus: paymentMethod == PaymentMethod.cash
            ? PaymentStatus.pending.name
            : PaymentStatus.paid.name,
        note: trimmedNote.isEmpty ? null : trimmedNote,
        loyaltyPointsEarned: estimatedPoints,
      );
      final created = await _checkoutRepository.placeOrder(order);
      _cart.clearCart();
      return created;
    } finally {
      isPlacingOrder = false;
      notifyListeners();
    }
  }

  void _onCartChanged() => notifyListeners();

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }
}
