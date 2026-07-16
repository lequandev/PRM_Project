// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoyaltyTransactionModelImpl _$$LoyaltyTransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$LoyaltyTransactionModelImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  points: (json['points'] as num).toInt(),
  description: json['description'] as String,
  orderId: json['orderId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$LoyaltyTransactionModelImplToJson(
  _$LoyaltyTransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'points': instance.points,
  'description': instance.description,
  'orderId': instance.orderId,
  'createdAt': instance.createdAt?.toIso8601String(),
};
