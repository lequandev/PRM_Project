enum AddressType { home, work, other }

class SavedAddress {
  final AddressType type;
  String address;

  SavedAddress({required this.type, required this.address});

  // Chuyển đối tượng Address sang Map để lưu vào mảng của Firestore
  Map<String, dynamic> toMap() => {'type': type.name, 'address': address};

  // Khởi tạo từ Map lấy về từ Firestore
  factory SavedAddress.fromMap(Map<String, dynamic> map) {
    return SavedAddress(
      type: AddressType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'other'),
        orElse: () => AddressType.other,
      ),
      address: map['address'] ?? '',
    );
  }
}
