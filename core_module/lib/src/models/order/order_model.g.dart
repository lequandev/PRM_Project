// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      orderType: json['orderType'] as String? ?? 'pickup',
      deliveryAddress: json['deliveryAddress'] as Map<String, dynamic>?,
      voucherCode: json['voucherCode'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      note: json['note'] as String?,
      cancelReason: json['cancelReason'] as String?,
      loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num?)?.toInt() ?? 0,
      loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      readyAt: json['readyAt'] == null
          ? null
          : DateTime.parse(json['readyAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'discountAmount': instance.discountAmount,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'orderType': instance.orderType,
      'deliveryAddress': instance.deliveryAddress,
      'voucherCode': instance.voucherCode,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'note': instance.note,
      'cancelReason': instance.cancelReason,
      'loyaltyPointsEarned': instance.loyaltyPointsEarned,
      'loyaltyPointsUsed': instance.loyaltyPointsUsed,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'readyAt': instance.readyAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
    };
