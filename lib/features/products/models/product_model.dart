class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final double rating;
  final int reviewsCount;
  final bool isNew;
  final bool isBestSeller;
  final bool isPopular;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    this.isNew = false,
    this.isBestSeller = false,
    this.isPopular = false,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: data['reviewsCount'] ?? 0,
      isNew: data['isNew'] ?? false,
      isBestSeller: data['isBestSeller'] ?? false,
      isPopular: data['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'isNew': isNew,
    'isBestSeller': isBestSeller,
    'isPopular': isPopular,
  };
}
