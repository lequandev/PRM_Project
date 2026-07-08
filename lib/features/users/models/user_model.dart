import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { CUSTOMER, STAFF, ADMIN }

class UserModel {
  final String id; // Firebase Auth UID
  final DateTime? birthday;
  final DateTime createAt;
  final String email;
  final String fullname;
  final bool isActive;
  final String? phoneNumber;
  final UserRole role;
  final DateTime updateAt;

  UserModel({
    required this.id,
    this.birthday,
    required this.createAt,
    required this.email,
    required this.fullname,
    this.isActive = true,
    this.phoneNumber,
    this.role = UserRole.CUSTOMER,
    required this.updateAt,
  });

  // Chuyển đối tượng sang Map để đẩy lên Firestore
  Map<String, dynamic> toMap() => {
    'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
    'create_at': Timestamp.fromDate(createAt),
    'email': email,
    'fullname': fullname,
    'is_active': isActive,
    'phone_number': phoneNumber,
    'role': role.name,
    'update_at': Timestamp.fromDate(updateAt),
  };

  // Tạo đối tượng từ dữ liệu Firestore trả về
  factory UserModel.fromMap(String docId, Map<String, dynamic> map) {
    return UserModel(
      id: docId,
      birthday: map['birthday'] != null
          ? (map['birthday'] as Timestamp).toDate()
          : null,
      createAt: (map['create_at'] as Timestamp).toDate(),
      email: map['email'] ?? '',
      fullname: map['fullname'] ?? '',
      isActive: map['is_active'] ?? true,
      phoneNumber: map['phone_number'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'CUSTOMER'),
        orElse: () => UserRole.CUSTOMER,
      ),
      updateAt: (map['update_at'] as Timestamp).toDate(),
    );
  }
}
