import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher/voucher_model.dart';

/// VoucherService — Firestore access layer cho Vouchers.
///
/// ⚠️  PHÂN CÔNG:
///   - UC-14 (Áp dụng mã giảm giá)    : Dev 3 gọi từ CheckoutProvider
///   - UC-29 (Tạo & quản lý voucher)  : Dev 5 gọi từ AdminVoucherProvider
///
/// Dev 1 owns file này — chỉ Dev 1 được sửa.
/// Dev 3/5: KHÔNG sửa file này, gọi methods qua Provider của mình.
class VoucherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── UC-14: Validate mã giảm giá ──────────────────────
  // Dev 3 dùng — CheckoutProvider

  Future<VoucherModel> validateVoucher({
    required String code,
    required double orderTotal,
    required String userId,
  }) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-14)
    throw UnimplementedError('VoucherService.validateVoucher — chưa implement');
  }

  Future<void> incrementUsageCount(String code) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-14, sau createOrder)
    throw UnimplementedError('VoucherService.incrementUsageCount — chưa implement');
  }

  // ─── UC-29: Admin quản lý voucher ─────────────────────
  // Dev 5 dùng — AdminVoucherProvider

  Future<void> createVoucher(VoucherModel voucher) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-29)
    throw UnimplementedError('VoucherService.createVoucher — chưa implement');
  }

  Future<List<VoucherModel>> getAllVouchers() {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-29)
    throw UnimplementedError('VoucherService.getAllVouchers — chưa implement');
  }

  Future<void> deactivateVoucher(String code) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-29)
    throw UnimplementedError('VoucherService.deactivateVoucher — chưa implement');
  }
}
