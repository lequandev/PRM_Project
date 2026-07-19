import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/common/app_exception.dart';
import '../models/product/product_model.dart';
import '../models/product/category_model.dart';
import '../models/product/customization_model.dart';
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

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection('categories').get();
    final categories = snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .where((cat) => cat.isActive)
        .toList();
    
    // Client-side sort by displayOrder
    categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return categories;
  }

  // ─── Products ──────────────────────────────────────────
  // Dev 2 dùng cho UC-07, UC-08, UC-09

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final snapshot = await _db.collection('products').get();
    final List<ProductModel> products = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      
      // Fetch customizations subcollection
      final custSnapshot = await doc.reference.collection('customizations').get();
      final customizations = custSnapshot.docs
          .map((cDoc) => CustomizationModel.fromFirestore(cDoc.data(), cDoc.id))
          .toList();
          
      final product = ProductModel.fromFirestore(data, doc.id).copyWith(
        customizations: customizations,
      );
      
      // Client-side filtering to support varying schemas and avoid index requirements
      if (product.isArchived) continue;
      if (!product.isAvailable) continue;
      if (categoryId.isNotEmpty && product.categoryId != categoryId) continue;
      
      products.add(product);
    }
    return products;
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final snapshot = await _db.collection('products')
        .where('isArchived', isEqualTo: false)
        .where('isAvailable', isEqualTo: true)
        .get();
    
    final List<ProductModel> products = [];
    final lowerQuery = query.toLowerCase();
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = (data['name'] as String? ?? '').toLowerCase();
      
      if (name.contains(lowerQuery)) {
        final custSnapshot = await doc.reference.collection('customizations').get();
        final customizations = custSnapshot.docs
            .map((cDoc) => CustomizationModel.fromFirestore(cDoc.data(), cDoc.id))
            .toList();
            
        final product = ProductModel.fromFirestore(data, doc.id).copyWith(
          customizations: customizations,
        );
        products.add(product);
      }
    }
    return products;
  }

  Future<ProductModel> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    final data = doc.data()!;
    final custSnapshot = await doc.reference.collection('customizations').get();
    final customizations = custSnapshot.docs
        .map((cDoc) => CustomizationModel.fromFirestore(cDoc.data(), cDoc.id))
        .toList();
        
    return ProductModel.fromFirestore(data, doc.id).copyWith(
      customizations: customizations,
    );
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

  Future<void> seedInitialData({
    required List<CategoryModel> categories,
    required List<ProductModel> products,
  }) async {
    try {
      // 1. Seed Categories if empty
      final categoriesSnap = await _db.collection('categories').limit(1).get();
      if (categoriesSnap.docs.isEmpty) {
        for (final cat in categories) {
          await _db.collection('categories').doc(cat.id).set(CategoryModel.toFirestore(cat));
        }
      }

      // 2. Seed Products if empty
      final productsSnap = await _db.collection('products').limit(1).get();
      if (productsSnap.docs.isEmpty) {
        for (final product in products) {
          await _db.collection('products').doc(product.id).set(ProductModel.toFirestore(product));
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
