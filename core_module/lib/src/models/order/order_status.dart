/// OrderStatus — Trạng thái đơn hàng trong toàn bộ vòng đời.
/// Dev 1 owns — không tự sửa ngoài core_module.
enum OrderStatus {
  /// Khách vừa đặt, chờ staff xác nhận (UC-17)
  pending,

  /// Staff đã chấp nhận đơn (UC-21)
  accepted,

  /// Đang pha chế (UC-22)
  preparing,

  /// Sẵn sàng để lấy / giao (UC-23)
  ready,

  /// Đã giao xong / khách đã nhận (UC-24)
  delivered,

  /// Đơn bị hủy (UC-26)
  cancelled;

  /// Convert từ String (Firestore) sang enum
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Nhãn tiếng Việt hiển thị trên UI
  String get label {
    switch (this) {
      case OrderStatus.pending:    return 'Chờ xác nhận';
      case OrderStatus.accepted:   return 'Đã xác nhận';
      case OrderStatus.preparing:  return 'Đang pha chế';
      case OrderStatus.ready:      return 'Sẵn sàng lấy';
      case OrderStatus.delivered:  return 'Hoàn thành';
      case OrderStatus.cancelled:  return 'Đã hủy';
    }
  }

  /// Cho phép customer tự hủy không?
  bool get canCustomerCancel => this == OrderStatus.pending;

  /// Đơn đã kết thúc (không thể thay đổi)?
  bool get isTerminal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

/// OrderType — Loại đơn hàng
enum OrderType {
  pickup,   // Mang về / tự đến lấy
  delivery; // Giao hàng tận nơi

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderType.pickup,
    );
  }

  String get label {
    switch (this) {
      case OrderType.pickup:   return 'Mang về';
      case OrderType.delivery: return 'Giao hàng';
    }
  }
}

/// PaymentMethod — Phương thức thanh toán
enum PaymentMethod {
  cash,
  vnpay,
  momo,
  zalopay;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash:    return 'Tiền mặt';
      case PaymentMethod.vnpay:   return 'VNPay';
      case PaymentMethod.momo:    return 'MoMo';
      case PaymentMethod.zalopay: return 'ZaloPay';
    }
  }
}

/// PaymentStatus
enum PaymentStatus {
  pending,
  paid,
  refunded;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// UserRole — Vai trò người dùng (RBAC)
enum UserRole {
  customer,
  staff,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.customer,
    );
  }
}
