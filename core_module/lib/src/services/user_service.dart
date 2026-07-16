import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/user/address_model.dart';

/// UserService — Firestore access layer cho User profile & Addresses.
///
/// ⚠️  PHÂN CÔNG:
///   - UC-04 (Xem & chỉnh sửa hồ sơ)    : Dev 3 gọi từ ProfileProvider
///   - UC-05 (Quản lý địa chỉ)           : Dev 3 gọi từ AddressProvider
///   - UC-06 (Xóa tài khoản GDPR)        : Dev 3 gọi từ ProfileProvider
///
/// Dev 1 owns file này — chỉ Dev 1 được sửa.
/// Dev 3: KHÔNG sửa file này, gọi methods qua Provider của mình.
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Internal (dùng bởi AuthService) ──────────────────
  // Dev 1 sử dụng nội bộ — không expose public

  /// Lấy UserModel sau khi login (được AuthService gọi nội bộ).
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  // ─── UC-04: Xem & chỉnh sửa hồ sơ ────────────────────
  // Dev 3 dùng — ProfileProvider

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? avatarUrl,
  }) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-04)
    throw UnimplementedError('UserService.updateProfile — chưa implement');
  }

  // ─── UC-05: Quản lý địa chỉ ───────────────────────────
  // Dev 3 dùng — AddressProvider

  Future<List<AddressModel>> getAddresses(String uid) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-05)
    throw UnimplementedError('UserService.getAddresses — chưa implement');
  }

  Future<AddressModel> addAddress({required String uid, required AddressModel address}) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-05)
    throw UnimplementedError('UserService.addAddress — chưa implement');
  }

  Future<void> updateAddress({required String uid, required AddressModel address}) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-05)
    throw UnimplementedError('UserService.updateAddress — chưa implement');
  }

  Future<void> deleteAddress({required String uid, required String addressId}) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-05)
    throw UnimplementedError('UserService.deleteAddress — chưa implement');
  }

  // ─── UC-06: Xóa tài khoản (GDPR) ─────────────────────
  // Dev 3 dùng — ProfileProvider

  Future<void> deactivateAccount(String uid) {
    // TODO: Dev 1 implements khi Dev 3 cần (UC-06)
    throw UnimplementedError('UserService.deactivateAccount — chưa implement');
  }
}
