class SavedPaymentMethod {
  final String id;
  final String name;
  final String? last4;

  SavedPaymentMethod({required this.id, required this.name, this.last4});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'last4': last4};

  factory SavedPaymentMethod.fromMap(Map<String, dynamic> map) {
    return SavedPaymentMethod(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      last4: map['last4'],
    );
  }
}
