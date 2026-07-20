import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/common/app_exception.dart';
import '../models/order/order_model.dart';
import '../models/user/loyalty_transaction_model.dart';

/// LoyaltyService — điểm thưởng khách hàng (UC-27 xem, UC-28 đổi).
///
/// Stack là Firebase THUẦN (không Cloud Functions) nên điểm được cộng/trừ ở
/// phía client bằng Firestore transaction. Cộng điểm là IDEMPOTENT theo orderId
/// (doc id cố định `earn_{orderId}`) nên gọi lại nhiều lần vẫn chỉ cộng 1 lần.
///
/// Dev 1 owns file này — chỉ Dev 1 được sửa.
class LoyaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _txCol(String uid) =>
      _userRef(uid).collection('loyaltyTransactions');

  /// Điểm hiện tại (đọc users/{uid}.loyaltyPoints).
  Future<int> getPoints(String uid) async {
    try {
      final doc = await _userRef(uid).get();
      return (doc.data()?['loyaltyPoints'] as int?) ?? 0;
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Lịch sử tích/đổi điểm, mới nhất trước (UC-27).
  Future<List<LoyaltyTransactionModel>> getTransactions(String uid) async {
    try {
      final snap =
          await _txCol(uid).orderBy('createdAt', descending: true).get();
      return snap.docs
          .map((d) => LoyaltyTransactionModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Cộng điểm cho một đơn đã hoàn thành — IDEMPOTENT (mỗi đơn cộng 1 lần).
  ///
  /// Vì không có Cloud Functions, hàm này được gọi từ phía customer khi họ xem
  /// đơn đã `delivered` (order tracking / lịch sử). Doc `earn_{orderId}` là chốt
  /// chống cộng trùng: transaction kiểm tra tồn tại trước khi cộng.
  Future<void> awardPointsForOrder(String uid, OrderModel order) async {
    final points = order.loyaltyPointsEarned;
    if (points <= 0 || order.id.isEmpty) return;
    final txRef = _txCol(uid).doc('earn_${order.id}');
    final userRef = _userRef(uid);
    try {
      await _db.runTransaction((tx) async {
        final earned = await tx.get(txRef);
        if (earned.exists) return; // đã cộng cho đơn này rồi
        final userSnap = await tx.get(userRef);
        final current = (userSnap.data()?['loyaltyPoints'] as int?) ?? 0;
        tx.set(txRef, {
          'type': 'earn',
          'points': points,
          'description': 'Tích điểm đơn ${order.id}',
          'orderId': order.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(userRef, {'loyaltyPoints': current + points});
      });
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Đổi [points] điểm — trừ điểm + ghi transaction 'redeem' atomic (UC-28).
  /// Ném [AppException] nếu không đủ điểm.
  Future<void> redeemPoints({
    required String uid,
    required int points,
    required String description,
  }) async {
    if (points <= 0) return;
    final userRef = _userRef(uid);
    final txRef = _txCol(uid).doc();
    try {
      await _db.runTransaction((tx) async {
        final userSnap = await tx.get(userRef);
        final current = (userSnap.data()?['loyaltyPoints'] as int?) ?? 0;
        if (current < points) {
          throw const AppException(
            code: 'loyalty/insufficient',
            message: 'Bạn không đủ điểm để đổi.',
          );
        }
        tx.set(txRef, {
          'type': 'redeem',
          'points': -points,
          'description': description,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(userRef, {'loyaltyPoints': current - points});
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException.unknown(e);
    }
  }
}
