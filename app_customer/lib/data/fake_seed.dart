import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'app_session.dart';

/// Seed data cho MOCK MODE — chỉ dùng trong FakeRepository.
/// Khi service thật của Dev 1 sẵn sàng, file này chỉ còn phục vụ widget test.
abstract class FakeSeed {
  // ─── Sản phẩm (menu là của Dev 2 — đây chỉ là data cho cart/order demo) ───

  static final products = <ProductModel>[
    const ProductModel(
      id: 'p_cfsd',
      name: 'Cà phê sữa đá',
      categoryId: 'c_coffee',
      basePrice: 29000,
      description: 'Cà phê phin truyền thống, sữa đặc, đá viên.',
      avgRating: 4.7,
      totalReviews: 128,
    ),
    const ProductModel(
      id: 'p_bacxiu',
      name: 'Bạc xỉu',
      categoryId: 'c_coffee',
      basePrice: 32000,
      description: 'Sữa nhiều cà phê ít, ngọt dịu.',
      avgRating: 4.5,
      totalReviews: 86,
    ),
    const ProductModel(
      id: 'p_tdcs',
      name: 'Trà đào cam sả',
      categoryId: 'c_tea',
      basePrice: 45000,
      description: 'Trà đen, đào ngâm, cam vàng và sả tươi.',
      avgRating: 4.8,
      totalReviews: 203,
    ),
    const ProductModel(
      id: 'p_latte',
      name: 'Latte nóng',
      categoryId: 'c_coffee',
      basePrice: 55000,
      description: 'Espresso và sữa tươi đánh nóng, nghệ thuật latte art.',
      avgRating: 4.6,
      totalReviews: 74,
    ),
    const ProductModel(
      id: 'p_matcha',
      name: 'Matcha đá xay',
      categoryId: 'c_blended',
      basePrice: 59000,
      description: 'Matcha Nhật, sữa tươi, đá xay mịn, kem whipping.',
      avgRating: 4.4,
      totalReviews: 51,
    ),
  ];

  // ─── Giỏ hàng mặc định (2 item để demo checkout ngay) ───

  static final cartItems = <OrderItemModel>[
    const OrderItemModel(
      productId: 'p_cfsd',
      productName: 'Cà phê sữa đá',
      quantity: 2,
      unitPrice: 29000,
      totalPrice: 58000,
      customizations: {'size': 'M', 'đá': '100%', 'đường': '70%'},
    ),
    const OrderItemModel(
      productId: 'p_tdcs',
      productName: 'Trà đào cam sả',
      quantity: 1,
      unitPrice: 49000, // size L +4k
      totalPrice: 49000,
      customizations: {'size': 'L', 'đá': '50%'},
    ),
  ];

  // ─── Địa chỉ đã lưu ───

  static final addresses = <AddressModel>[
    const AddressModel(
      id: 'a_home',
      label: 'Nhà',
      street: '123 Nguyễn Văn Linh',
      ward: 'Phường Nam Dương',
      district: 'Quận Hải Châu',
      city: 'Đà Nẵng',
      isDefault: true,
    ),
    const AddressModel(
      id: 'a_school',
      label: 'Trường',
      street: 'Khu đô thị FPT City',
      ward: 'Phường Hòa Hải',
      district: 'Quận Ngũ Hành Sơn',
      city: 'Đà Nẵng',
    ),
  ];

  // ─── Voucher (khớp schema /vouchers — doc ID = code) ───

  static final vouchers = <VoucherModel>[
    VoucherModel(
      code: 'COFFEE20',
      description: 'Giảm 20% tối đa 25.000đ cho đơn từ 50.000đ',
      discountType: 'percentage',
      discountValue: 20,
      maxDiscountAmount: 25000,
      minOrderValue: 50000,
      startDate: DateTime(2026, 7, 1),
      expiresAt: DateTime(2026, 8, 1),
    ),
    VoucherModel(
      code: 'GIAM15K',
      description: 'Giảm thẳng 15.000đ, không điều kiện',
      discountType: 'fixed',
      discountValue: 15000,
      startDate: DateTime(2026, 7, 1),
      expiresAt: DateTime(2026, 12, 31),
    ),
    VoucherModel(
      code: 'HETHAN',
      description: 'Voucher đã hết hạn (để test lỗi)',
      discountType: 'fixed',
      discountValue: 10000,
      startDate: DateTime(2026, 6, 1),
      expiresAt: DateTime(2026, 7, 1),
    ),
  ];

  // ─── Lịch sử đơn hàng ───

  static List<OrderModel> historyOrders() {
    final now = DateTime.now();
    return [
      OrderModel(
        id: 'OD-240712-001',
        customerId: AppSession.uid,
        customerName: AppSession.name,
        customerPhone: AppSession.phone,
        items: const [
          OrderItemModel(
            productId: 'p_latte',
            productName: 'Latte nóng',
            quantity: 1,
            unitPrice: 55000,
            totalPrice: 55000,
            customizations: {'size': 'M'},
          ),
        ],
        subtotal: 55000,
        totalAmount: 55000,
        status: 'delivered',
        orderType: 'pickup',
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        loyaltyPointsEarned: 550,
        createdAt: now.subtract(const Duration(days: 5)),
        deliveredAt: now.subtract(const Duration(days: 5, hours: -1)),
      ),
      OrderModel(
        id: 'OD-240714-002',
        customerId: AppSession.uid,
        customerName: AppSession.name,
        customerPhone: AppSession.phone,
        items: const [
          OrderItemModel(
            productId: 'p_matcha',
            productName: 'Matcha đá xay',
            quantity: 2,
            unitPrice: 59000,
            totalPrice: 118000,
            customizations: {'size': 'L', 'đường': '50%'},
          ),
        ],
        subtotal: 118000,
        discountAmount: 15000,
        totalAmount: 103000,
        status: 'cancelled',
        orderType: 'delivery',
        deliveryAddress: AddressModel.toFirestore(addresses.first),
        voucherCode: 'GIAM15K',
        paymentMethod: 'vnpay',
        paymentStatus: 'refunded',
        cancelReason: 'Khách đổi ý',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      OrderModel(
        id: 'OD-240717-003',
        customerId: AppSession.uid,
        customerName: AppSession.name,
        customerPhone: AppSession.phone,
        items: const [
          OrderItemModel(
            productId: 'p_bacxiu',
            productName: 'Bạc xỉu',
            quantity: 1,
            unitPrice: 32000,
            totalPrice: 32000,
            customizations: {'size': 'S'},
          ),
          OrderItemModel(
            productId: 'p_cfsd',
            productName: 'Cà phê sữa đá',
            quantity: 1,
            unitPrice: 29000,
            totalPrice: 29000,
          ),
        ],
        subtotal: 61000,
        totalAmount: 61000,
        status: 'preparing',
        orderType: 'pickup',
        paymentMethod: 'momo',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(minutes: 25)),
        acceptedAt: now.subtract(const Duration(minutes: 20)),
      ),
      OrderModel(
        id: 'OD-240717-004',
        customerId: AppSession.uid,
        customerName: AppSession.name,
        customerPhone: AppSession.phone,
        items: const [
          OrderItemModel(
            productId: 'p_tdcs',
            productName: 'Trà đào cam sả',
            quantity: 1,
            unitPrice: 45000,
            totalPrice: 45000,
            customizations: {'size': 'M', 'đá': '100%'},
          ),
        ],
        subtotal: 45000,
        totalAmount: 45000,
        status: 'ready',
        orderType: 'pickup',
        paymentMethod: 'vnpay',
        paymentStatus: 'paid',
        loyaltyPointsEarned: 450,
        createdAt: now.subtract(const Duration(minutes: 12)),
        acceptedAt: now.subtract(const Duration(minutes: 10)),
        readyAt: now.subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  // ─── Loyalty ───

  static const int loyaltyPoints = 1250;

  static List<LoyaltyTransactionModel> loyaltyTransactions() {
    final now = DateTime.now();
    return [
      LoyaltyTransactionModel(
        id: 'tx4',
        type: 'earn',
        points: 550,
        description: 'Tích điểm đơn OD-240712-001',
        orderId: 'OD-240712-001',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      LoyaltyTransactionModel(
        id: 'tx3',
        type: 'redeem',
        points: -500,
        description: 'Đổi 500 điểm lấy voucher GIAM15K',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      LoyaltyTransactionModel(
        id: 'tx2',
        type: 'earn',
        points: 400,
        description: 'Tích điểm đơn tháng 6',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      LoyaltyTransactionModel(
        id: 'tx1',
        type: 'earn',
        points: 800,
        description: 'Quà chào mừng thành viên mới',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
    ];
  }

  // ─── Store config (khớp /config/store defaults trong core) ───

  static const double deliveryFee = 15000;
  static const double minDeliveryOrder = 50000;
  static const double loyaltyRate = 0.01;
}
