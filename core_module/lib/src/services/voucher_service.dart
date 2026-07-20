import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/common/app_exception.dart';
import '../models/voucher/voucher_model.dart';
import '../utils/extensions/num_extensions.dart';

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
  }) async {
    final normalized = code.trim().toUpperCase();
    late final VoucherModel voucher;
    try {
      final doc = await _db.collection('vouchers').doc(normalized).get();
      if (!doc.exists || doc.data() == null) {
        throw AppException(
          code: 'voucher/not-found',
          message: 'Mã "$normalized" không tồn tại.',
        );
      }
      voucher = VoucherModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException.unknown(e);
    }

    // Business checks — message hiển thị thẳng lên UI checkout
    final now = DateTime.now();
    if (!voucher.isActive) {
      throw AppException(
        code: 'voucher/inactive',
        message: 'Mã $normalized đã bị vô hiệu hóa.',
      );
    }
    if (now.isBefore(voucher.startDate)) {
      throw AppException(
        code: 'voucher/not-started',
        message: 'Mã $normalized chưa đến đợt áp dụng.',
      );
    }
    if (now.isAfter(voucher.expiresAt)) {
      throw AppException(
        code: 'voucher/expired',
        message: 'Mã $normalized đã hết hạn.',
      );
    }
    if (voucher.usageLimit != null &&
        voucher.usageCount >= voucher.usageLimit!) {
      throw AppException(
        code: 'voucher/out-of-uses',
        message: 'Mã $normalized đã hết lượt sử dụng.',
      );
    }
    if (orderTotal < voucher.minOrderValue) {
      throw AppException(
        code: 'voucher/min-order',
        message:
            'Đơn tối thiểu ${voucher.minOrderValue.toVnd} mới dùng được mã này.',
      );
    }
    // TODO(Dev 1): perUserLimit chưa enforce được — cần subcollection
    // /vouchers/{code}/usages/{uid} hoặc đếm trong orders. Ghi nhận ở PR này.
    return voucher;
  }

  Future<void> incrementUsageCount(String code) async {
    try {
      await _db.collection('vouchers').doc(code.trim().toUpperCase()).update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
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
