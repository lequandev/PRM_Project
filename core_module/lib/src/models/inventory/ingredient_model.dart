import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_model.freezed.dart';
part 'ingredient_model.g.dart';

/// IngredientModel — Nguyên liệu trong kho hàng.
/// Map với Firestore collection: /inventory/{ingredientId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class IngredientModel with _$IngredientModel {
  const factory IngredientModel({
    required String id,
    required String name,
    required String unit,           // 'kg' | 'lít' | 'hộp' | 'cái'
    required double currentStock,
    required double minStock,       // Ngưỡng cảnh báo
    @Default('available') String status, // 'available' | 'low' | 'out_of_stock'
    String? updatedBy,
    DateTime? updatedAt,
  }) = _IngredientModel;

  factory IngredientModel.fromJson(Map<String, dynamic> json) =>
      _$IngredientModelFromJson(json);

  factory IngredientModel.fromFirestore(Map<String, dynamic> data, String id) {
    return IngredientModel(
      id: id,
      name: data['name'] as String? ?? '',
      unit: data['unit'] as String? ?? 'cái',
      currentStock: (data['currentStock'] as num?)?.toDouble() ?? 0.0,
      minStock: (data['minStock'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'available',
      updatedBy: data['updatedBy'] as String?,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(IngredientModel i) {
    return {
      'name': i.name,
      'unit': i.unit,
      'currentStock': i.currentStock,
      'minStock': i.minStock,
      'status': i.computedStatus,
      if (i.updatedBy != null) 'updatedBy': i.updatedBy,
      'updatedAt': DateTime.now(),
    };
  }
}

/// Extension để tính status tự động từ số lượng
extension IngredientStatusX on IngredientModel {
  String get computedStatus {
    if (currentStock <= 0) return 'out_of_stock';
    if (currentStock <= minStock) return 'low';
    return 'available';
  }

  bool get isLow => currentStock <= minStock && currentStock > 0;
  bool get isOutOfStock => currentStock <= 0;
}
