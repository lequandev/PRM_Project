// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomizationChoiceImpl _$$CustomizationChoiceImplFromJson(
  Map<String, dynamic> json,
) => _$CustomizationChoiceImpl(
  value: json['value'] as String,
  label: json['label'] as String,
  extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$CustomizationChoiceImplToJson(
  _$CustomizationChoiceImpl instance,
) => <String, dynamic>{
  'value': instance.value,
  'label': instance.label,
  'extraPrice': instance.extraPrice,
};

_$CustomizationModelImpl _$$CustomizationModelImplFromJson(
  Map<String, dynamic> json,
) => _$CustomizationModelImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  label: json['label'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => CustomizationChoice.fromJson(e as Map<String, dynamic>))
      .toList(),
  isRequired: json['isRequired'] as bool? ?? true,
);

Map<String, dynamic> _$$CustomizationModelImplToJson(
  _$CustomizationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'label': instance.label,
  'choices': instance.choices,
  'isRequired': instance.isRequired,
};
