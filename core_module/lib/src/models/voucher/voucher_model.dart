import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher_model.freezed.dart';
part 'voucher_model.g.dart';

/// VoucherModel — Mã giảm giá / chương trình khuyến mãi.
/// Map với Firestore collection: /vouchers/{voucherCode}
/// Document ID = voucher code (vd: 'COFFEE20')
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class VoucherModel with _$VoucherModel {
  const VoucherModel._();

  const factory VoucherModel({
    required String code,
    required String description,
    required String discountType,       // 'percentage' | 'fixed'
    required double discountValue,      // % hoặc VND
    double? maxDiscountAmount,          // Trần giảm tối đa (cho loại %)
    @Default(0.0) double minOrderValue,
    int? usageLimit,                    // null = không giới hạn
    @Default(0) int usageCount,
    @Default(1) int perUserLimit,
    @Default(true) bool isActive,
    required DateTime startDate,
    required DateTime expiresAt,
    String? createdBy,
    DateTime? createdAt,
  }) = _VoucherModel;

  factory VoucherModel.fromJson(Map<String, dynamic> json) =>
      _$VoucherModelFromJson(json);

  factory VoucherModel.fromFirestore(Map<String, dynamic> data, String code) {
    return VoucherModel(
      code: code,
      description: data['description'] as String? ?? '',
      discountType: data['discountType'] as String? ?? 'fixed',
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (data['maxDiscountAmount'] as num?)?.toDouble(),
      minOrderValue: (data['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      usageLimit: data['usageLimit'] as int?,
      usageCount: data['usageCount'] as int? ?? 0,
      perUserLimit: data['perUserLimit'] as int? ?? 1,
      isActive: data['isActive'] as bool? ?? true,
      startDate: (data['startDate'] as dynamic).toDate() as DateTime,
      expiresAt: (data['expiresAt'] as dynamic).toDate() as DateTime,
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(VoucherModel v) {
    return {
      'code': v.code,
      'description': v.description,
      'discountType': v.discountType,
      'discountValue': v.discountValue,
      if (v.maxDiscountAmount != null) 'maxDiscountAmount': v.maxDiscountAmount,
      'minOrderValue': v.minOrderValue,
      if (v.usageLimit != null) 'usageLimit': v.usageLimit,
      'usageCount': v.usageCount,
      'perUserLimit': v.perUserLimit,
      'isActive': v.isActive,
      'startDate': v.startDate,
      'expiresAt': v.expiresAt,
      if (v.createdBy != null) 'createdBy': v.createdBy,
      'createdAt': DateTime.now(),
    };
  }

  /// Tính số tiền giảm thực tế cho một đơn hàng
  double calculateDiscount(double orderTotal) {
    if (!isActive) return 0.0;
    if (orderTotal < minOrderValue) return 0.0;
    if (DateTime.now().isAfter(expiresAt)) return 0.0;
    if (DateTime.now().isBefore(startDate)) return 0.0;

    double discount = 0.0;
    if (discountType == 'percentage') {
      discount = orderTotal * (discountValue / 100);
      if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
        discount = maxDiscountAmount!;
      }
    } else {
      discount = discountValue;
    }
    return discount > orderTotal ? orderTotal : discount;
  }
}
