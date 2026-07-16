import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item_model.dart';
import 'order_status.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// OrderModel — Đơn hàng đầy đủ trong hệ thống.
/// Map với Firestore collection: /orders/{orderId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String customerId,
    required String customerName,
    String? customerPhone,
    required List<OrderItemModel> items,
    required double subtotal,
    @Default(0.0) double discountAmount,
    required double totalAmount,
    @Default('pending') String status,
    @Default('pickup') String orderType,
    Map<String, dynamic>? deliveryAddress,
    String? voucherCode,
    @Default('cash') String paymentMethod,
    @Default('pending') String paymentStatus,
    String? note,
    String? cancelReason,
    @Default(0) int loyaltyPointsEarned,
    @Default(0) int loyaltyPointsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    final itemsData = data['items'] as List? ?? [];
    return OrderModel(
      id: id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String?,
      items: itemsData
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      orderType: data['orderType'] as String? ?? 'pickup',
      deliveryAddress: data['deliveryAddress'] as Map<String, dynamic>?,
      voucherCode: data['voucherCode'] as String?,
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      note: data['note'] as String?,
      cancelReason: data['cancelReason'] as String?,
      loyaltyPointsEarned: data['loyaltyPointsEarned'] as int? ?? 0,
      loyaltyPointsUsed: data['loyaltyPointsUsed'] as int? ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() as DateTime?,
      acceptedAt: (data['acceptedAt'] as dynamic)?.toDate() as DateTime?,
      readyAt: (data['readyAt'] as dynamic)?.toDate() as DateTime?,
      deliveredAt: (data['deliveredAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(OrderModel order) {
    return {
      'customerId': order.customerId,
      'customerName': order.customerName,
      if (order.customerPhone != null) 'customerPhone': order.customerPhone,
      'items': order.items.map((i) => i.toJson()).toList(),
      'subtotal': order.subtotal,
      'discountAmount': order.discountAmount,
      'totalAmount': order.totalAmount,
      'status': order.status,
      'orderType': order.orderType,
      if (order.deliveryAddress != null) 'deliveryAddress': order.deliveryAddress,
      if (order.voucherCode != null) 'voucherCode': order.voucherCode,
      'paymentMethod': order.paymentMethod,
      'paymentStatus': order.paymentStatus,
      if (order.note != null) 'note': order.note,
      'loyaltyPointsEarned': order.loyaltyPointsEarned,
      'loyaltyPointsUsed': order.loyaltyPointsUsed,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  /// Helper — Trả về OrderStatus enum từ status string
  OrderStatus get orderStatus => OrderStatus.fromString(status);
}
