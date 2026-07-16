import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// CategoryModel — Danh mục menu (Cà phê, Trà sữa, Nước ép...).
/// Map với Firestore collection: /categories/{categoryId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    String? imageUrl,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      displayOrder: data['displayOrder'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(CategoryModel cat) {
    return {
      'name': cat.name,
      if (cat.imageUrl != null) 'imageUrl': cat.imageUrl,
      'displayOrder': cat.displayOrder,
      'isActive': cat.isActive,
      'createdAt': DateTime.now(),
    };
  }
}
