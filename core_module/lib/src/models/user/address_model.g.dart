// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressModelImpl _$$AddressModelImplFromJson(Map<String, dynamic> json) =>
    _$AddressModelImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      ward: json['ward'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$AddressModelImplToJson(_$AddressModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'street': instance.street,
      'ward': instance.ward,
      'district': instance.district,
      'city': instance.city,
      'isDefault': instance.isDefault,
      'lat': instance.lat,
      'lng': instance.lng,
    };
