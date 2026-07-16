import 'package:freezed_annotation/freezed_annotation.dart';

part 'customization_model.freezed.dart';
part 'customization_model.g.dart';

/// CustomizationChoice — Một lựa chọn trong nhóm tùy chỉnh (vd: "Lớn (L)").
@freezed
class CustomizationChoice with _$CustomizationChoice {
  const factory CustomizationChoice({
    required String value,      // vd: 'large'
    required String label,      // vd: 'Lớn (L)'
    @Default(0.0) double extraPrice, // Phụ thu thêm (VND)
  }) = _CustomizationChoice;

  factory CustomizationChoice.fromJson(Map<String, dynamic> json) =>
      _$CustomizationChoiceFromJson(json);
}

/// CustomizationModel — Nhóm tùy chỉnh của sản phẩm.
/// Map với Firestore subcollection: /products/{id}/customizations/{id}
///
/// Các loại type hợp lệ:
///   'size'  → Kích thước (S / M / L)
///   'ice'   → Lượng đá (0% / 30% / 50% / 100%)
///   'sugar' → Lượng đường (0% / 30% / 50% / 70% / 100%)
///   'milk'  → Loại sữa (Tươi / Đặc / Yến mạch / Hạnh nhân)
///
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class CustomizationModel with _$CustomizationModel {
  const factory CustomizationModel({
    required String id,
    required String type,    // 'size' | 'ice' | 'sugar' | 'milk'
    required String label,   // Tên hiển thị tiếng Việt
    required List<CustomizationChoice> choices,
    @Default(true) bool isRequired,
  }) = _CustomizationModel;

  factory CustomizationModel.fromJson(Map<String, dynamic> json) =>
      _$CustomizationModelFromJson(json);

  factory CustomizationModel.fromFirestore(Map<String, dynamic> data, String id) {
    final choicesData = data['choices'] as List? ?? [];
    return CustomizationModel(
      id: id,
      type: data['type'] as String? ?? '',
      label: data['label'] as String? ?? '',
      choices: choicesData
          .map((c) => CustomizationChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
      isRequired: data['isRequired'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toFirestore(CustomizationModel c) {
    return {
      'type': c.type,
      'label': c.label,
      'choices': c.choices.map((ch) => ch.toJson()).toList(),
      'isRequired': c.isRequired,
    };
  }
}
