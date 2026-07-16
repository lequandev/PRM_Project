// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoucherModelImpl _$$VoucherModelImplFromJson(Map<String, dynamic> json) =>
    _$VoucherModelImpl(
      code: json['code'] as String,
      description: json['description'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      perUserLimit: (json['perUserLimit'] as num?)?.toInt() ?? 1,
      isActive: json['isActive'] as bool? ?? true,
      startDate: DateTime.parse(json['startDate'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$VoucherModelImplToJson(_$VoucherModelImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'discountType': instance.discountType,
      'discountValue': instance.discountValue,
      'maxDiscountAmount': instance.maxDiscountAmount,
      'minOrderValue': instance.minOrderValue,
      'usageLimit': instance.usageLimit,
      'usageCount': instance.usageCount,
      'perUserLimit': instance.perUserLimit,
      'isActive': instance.isActive,
      'startDate': instance.startDate.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
