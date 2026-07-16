// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewModelImpl _$$ReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$ReviewModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      orderId: json['orderId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ReviewModelImplToJson(_$ReviewModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'orderId': instance.orderId,
      'rating': instance.rating,
      'comment': instance.comment,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
