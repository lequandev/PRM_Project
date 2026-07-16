import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

/// OrderItemModel — Một dòng sản phẩm trong đơn hàng.
/// Được lưu dạng nested array trong /orders/{orderId}.items
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String productId,
    required String productName,       // Snapshot — giữ nguyên kể cả khi product thay đổi
    String? productImageUrl,
    required int quantity,
    required double unitPrice,         // Giá tại thời điểm đặt (có tính extra)
    required double totalPrice,        // unitPrice * quantity
    @Default({}) Map<String, String> customizations, // {'size': 'large', 'ice': '50%'}
    String? note,                      // Ghi chú riêng cho item này
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}
