import 'package:freezed_annotation/freezed_annotation.dart';
import 'address_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// UserModel — Đại diện cho tài khoản người dùng trong hệ thống.
/// Map 1-1 với Firestore collection: /users/{uid}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String name,
    required String role, // 'customer' | 'staff' | 'admin'
    String? phone,
    String? avatarUrl,
    @Default(0) int loyaltyPoints,
    @Default(true) bool isActive,
    @Default([]) List<AddressModel> savedAddresses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Tạo từ Firestore document snapshot
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      phone: data['phone'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      loyaltyPoints: data['loyaltyPoints'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  /// Convert sang Map để lưu Firestore
  static Map<String, dynamic> toFirestore(UserModel user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'name': user.name,
      'role': user.role,
      if (user.phone != null) 'phone': user.phone,
      if (user.avatarUrl != null) 'avatarUrl': user.avatarUrl,
      'loyaltyPoints': user.loyaltyPoints,
      'isActive': user.isActive,
    };
  }
}
