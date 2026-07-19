import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/common/app_exception.dart';
import '../models/product/product_model.dart';
import '../models/product/category_model.dart';
import '../models/product/review_model.dart';

/// ProductService — Firestore access layer cho Products & Categories.
///
/// ⚠️  PHÂN CÔNG:
///   - UC-07 → UC-09   : Dev 2 gọi methods này từ MenuProvider
///   - UC-31 → UC-33   : Dev 5 gọi methods này từ AdminProductProvider
///   - UC-39 → UC-40   : Dev 3 (submit), Dev 5 (moderate) gọi từ Provider tương ứng
///
/// Dev 1 owns file này — chỉ Dev 1 được sửa.
/// Dev 2/3/5: KHÔNG sửa file này, gọi methods qua Provider của mình.
class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Categories ────────────────────────────────────────
  // Dev 2 dùng cho UC-07

  Future<List<CategoryModel>> getCategories() {
    // TODO: Dev 1 implements khi bắt đầu Phase 2 (hoặc Dev 2 request)
    throw UnimplementedError('ProductService.getCategories — chưa implement');
  }

  // ─── Products ──────────────────────────────────────────
  // Dev 2 dùng cho UC-07, UC-08, UC-09

  Future<List<ProductModel>> getProductsByCategory(String categoryId) {
    // TODO: Dev 1 implements khi Dev 2 cần (UC-07)
    throw UnimplementedError('ProductService.getProductsByCategory — chưa implement');
  }

  Future<List<ProductModel>> searchProducts(String query) {
    // TODO: Dev 1 implements khi Dev 2 cần (UC-08)
    throw UnimplementedError('ProductService.searchProducts — chưa implement');
  }

  Future<ProductModel> getProductById(String productId) {
    // TODO: Dev 1 implements khi Dev 2 cần (UC-09)
    throw UnimplementedError('ProductService.getProductById — chưa implement');
  }

  // ─── Admin CRUD ────────────────────────────────────────
  // Dev 5 dùng cho UC-31, UC-32, UC-33

  Future<ProductModel> createProduct(ProductModel product) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-31)
    throw UnimplementedError('ProductService.createProduct — chưa implement');
  }

  Future<void> updateProduct(ProductModel product) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-32)
    throw UnimplementedError('ProductService.updateProduct — chưa implement');
  }

  Future<void> archiveProduct(String productId) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-33)
    throw UnimplementedError('ProductService.archiveProduct — chưa implement');
  }

  // ─── Reviews ───────────────────────────────────────────
  // Dev 3 (submit UC-39), Dev 5 (moderate UC-40)

  Future<void> submitReview({required String productId, required ReviewModel review}) async {
    try {
      await _db
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add(ReviewModel.toFirestore(review));
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  Future<List<ReviewModel>> getPendingReviews(String productId) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-40)
    throw UnimplementedError('ProductService.getPendingReviews — chưa implement');
  }

  Future<void> moderateReview({
    required String productId,
    required String reviewId,
    required String status,
  }) {
    // TODO: Dev 1 implements khi Dev 5 cần (UC-40)
    throw UnimplementedError('ProductService.moderateReview — chưa implement');
  }
}
