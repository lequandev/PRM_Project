import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory/ingredient_model.dart';
import '../models/common/app_exception.dart';

/// InventoryService — Quản lý kho nguyên liệu (UC-34, UC-35).
/// Dev 1 owns — không tự sửa ngoài core_module.
class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // UC-34: Theo dõi tồn kho nguyên liệu
  // ─────────────────────────────────────────────

  Future<List<IngredientModel>> getAllIngredients() async {
    try {
      final snapshot = await _db
          .collection('inventory')
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => IngredientModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Stream realtime cho inventory dashboard
  Stream<List<IngredientModel>> watchInventory() {
    return _db
        .collection('inventory')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => IngredientModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Lấy các nguyên liệu sắp hết hoặc đã hết
  Future<List<IngredientModel>> getLowStockIngredients() async {
    try {
      final snapshot = await _db
          .collection('inventory')
          .where('status', whereIn: ['low', 'out_of_stock'])
          .get();
      return snapshot.docs
          .map((doc) => IngredientModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  // ─────────────────────────────────────────────
  // UC-35: Cập nhật trạng thái kho
  // ─────────────────────────────────────────────

  Future<void> updateStock({
    required String ingredientId,
    required double newStock,
    required String updatedBy,
  }) async {
    try {
      // Tính status mới dựa trên stock
      final doc =
          await _db.collection('inventory').doc(ingredientId).get();
      if (!doc.exists) throw DatabaseException.notFound('Nguyên liệu');

      final ingredient =
          IngredientModel.fromFirestore(doc.data()!, doc.id);
      final updated = ingredient.copyWith(
        currentStock: newStock,
        updatedBy: updatedBy,
        updatedAt: DateTime.now(),
      );

      await _db.collection('inventory').doc(ingredientId).update({
        'currentStock': newStock,
        'status': updated.computedStatus,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException.unknown(e);
    }
  }

  Future<IngredientModel> addIngredient(IngredientModel ingredient) async {
    try {
      final ref = _db.collection('inventory').doc();
      final newIngredient = ingredient.copyWith(
        id: ref.id,
        updatedAt: DateTime.now(),
      );
      await ref.set(IngredientModel.toFirestore(newIngredient));
      return newIngredient;
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }
}
