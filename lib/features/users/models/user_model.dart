import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';
import 'payment_method_model.dart';

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

  // Các trường bổ sung theo yêu cầu dự án & kết nối UI Profile
  final String? avatarUrl; // Chứa link ảnh từ Firebase Storage
  final List<SavedAddress> savedAddresses;
  final List<SavedPaymentMethod> savedPaymentMethods;

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
    this.avatarUrl,
    this.savedAddresses = const [],
    this.savedPaymentMethods = const [],
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
    'avatar_url': avatarUrl,
    // Map danh sách Object thành danh sách các bản ghi json thuần túy để lưu trữ
    'saved_addresses': savedAddresses.map((e) => e.toMap()).toList(),
    'saved_payment_methods': savedPaymentMethods.map((e) => e.toMap()).toList(),
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
      avatarUrl: map['avatar_url'],
      // Xử lý bóc tách mảng danh sách địa chỉ một cách an toàn
      savedAddresses: map['saved_addresses'] != null
          ? List<SavedAddress>.from(
              (map['saved_addresses'] as List).map(
                (item) => SavedAddress.fromMap(Map<String, dynamic>.from(item)),
              ),
            )
          : [],
      // Xử lý bóc tách mảng danh sách phương thức thanh toán an toàn
      savedPaymentMethods: map['saved_payment_methods'] != null
          ? List<SavedPaymentMethod>.from(
              (map['saved_payment_methods'] as List).map(
                (item) =>
                    SavedPaymentMethod.fromMap(Map<String, dynamic>.from(item)),
              ),
            )
          : [],
    );
  }
}
