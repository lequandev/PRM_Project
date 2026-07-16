// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientModelImpl _$$IngredientModelImplFromJson(
  Map<String, dynamic> json,
) => _$IngredientModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  unit: json['unit'] as String,
  currentStock: (json['currentStock'] as num).toDouble(),
  minStock: (json['minStock'] as num).toDouble(),
  status: json['status'] as String? ?? 'available',
  updatedBy: json['updatedBy'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$IngredientModelImplToJson(
  _$IngredientModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'unit': instance.unit,
  'currentStock': instance.currentStock,
  'minStock': instance.minStock,
  'status': instance.status,
  'updatedBy': instance.updatedBy,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
