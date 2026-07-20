import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/common/app_exception.dart';
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
  }) async {
    try {
      await _db.collection('users').doc(uid).update({
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  // ─── UC-05: Quản lý địa chỉ ───────────────────────────
  // Dev 3 dùng — AddressProvider

  CollectionReference<Map<String, dynamic>> _addressCol(String uid) =>
      _db.collection('users').doc(uid).collection('addresses');

  Future<List<AddressModel>> getAddresses(String uid) async {
    try {
      final snap = await _addressCol(uid).get();
      final list = snap.docs
          .map((doc) => AddressModel.fromFirestore(doc.data(), doc.id))
          .toList();
      // Địa chỉ mặc định lên đầu danh sách
      list.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
      return list;
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  Future<AddressModel> addAddress(
      {required String uid, required AddressModel address}) async {
    try {
      if (address.isDefault) await _clearDefaultAddress(uid);
      final ref = await _addressCol(uid).add(AddressModel.toFirestore(address));
      return address.copyWith(id: ref.id);
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  Future<void> updateAddress(
      {required String uid, required AddressModel address}) async {
    try {
      if (address.isDefault) {
        await _clearDefaultAddress(uid, except: address.id);
      }
      await _addressCol(uid)
          .doc(address.id)
          .set(AddressModel.toFirestore(address));
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  Future<void> deleteAddress(
      {required String uid, required String addressId}) async {
    try {
      await _addressCol(uid).doc(addressId).delete();
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Chỉ cho phép 1 địa chỉ mặc định — bỏ cờ isDefault ở các địa chỉ khác.
  Future<void> _clearDefaultAddress(String uid, {String? except}) async {
    final snap =
        await _addressCol(uid).where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.id == except) continue;
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  // ─── UC-06: Xóa tài khoản (GDPR) ─────────────────────
  // Dev 3 dùng — ProfileProvider

  Future<void> deactivateAccount(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }
}
