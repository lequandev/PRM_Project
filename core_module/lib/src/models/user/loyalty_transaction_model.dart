import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty_transaction_model.freezed.dart';
part 'loyalty_transaction_model.g.dart';

/// LoyaltyTransactionModel — Lịch sử tích/đổi điểm của customer.
/// Map với Firestore subcollection: /users/{uid}/loyaltyTransactions/{txId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class LoyaltyTransactionModel with _$LoyaltyTransactionModel {
  const factory LoyaltyTransactionModel({
    required String id,
    required String type,        // 'earn' | 'redeem'
    required int points,         // dương = tích, âm = đổi
    required String description,
    String? orderId,
    DateTime? createdAt,
  }) = _LoyaltyTransactionModel;

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyTransactionModelFromJson(json);

  factory LoyaltyTransactionModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return LoyaltyTransactionModel(
      id: id,
      type: data['type'] as String? ?? 'earn',
      points: data['points'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      orderId: data['orderId'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(LoyaltyTransactionModel tx) {
    return {
      'type': tx.type,
      'points': tx.points,
      'description': tx.description,
      if (tx.orderId != null) 'orderId': tx.orderId,
      'createdAt': DateTime.now(),
    };
  }
}
