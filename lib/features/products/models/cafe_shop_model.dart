class CafeShop {
  final String id;
  final String name;
  final String address;
  final String distance;

  CafeShop({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
  });

  factory CafeShop.fromMap(String id, Map<String, dynamic> data) {
    return CafeShop(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      distance: data['distance'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'distance': distance,
  };
}
