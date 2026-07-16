import 'package:freezed_annotation/freezed_annotation.dart';
import 'customization_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// ProductModel — Sản phẩm trong menu cà phê.
/// Map với Firestore collection: /products/{productId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String categoryId,
    required double basePrice,
    String? description,
    String? imageUrl,
    @Default(true) bool isAvailable,
    @Default(false) bool isArchived,
    @Default([]) List<String> tags,
    @Default(0.0) double avgRating,
    @Default(0) int totalReviews,
    @Default([]) List<CustomizationModel> customizations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      isAvailable: data['isAvailable'] as bool? ?? true,
      isArchived: data['isArchived'] as bool? ?? false,
      tags: List<String>.from(data['tags'] as List? ?? []),
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] as int? ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(ProductModel product) {
    return {
      'name': product.name,
      'categoryId': product.categoryId,
      'basePrice': product.basePrice,
      if (product.description != null) 'description': product.description,
      if (product.imageUrl != null) 'imageUrl': product.imageUrl,
      'isAvailable': product.isAvailable,
      'isArchived': product.isArchived,
      'tags': product.tags,
      'avgRating': product.avgRating,
      'totalReviews': product.totalReviews,
      'updatedAt': DateTime.now(),
    };
  }
}
