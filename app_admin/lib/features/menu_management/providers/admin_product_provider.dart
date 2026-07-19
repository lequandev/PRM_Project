import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// AdminProductProvider — CRUD sản phẩm cho Admin (UC-31, UC-32, UC-33).
/// Gọi Firestore trực tiếp vì ProductService là stub chưa được implement bởi Dev 1.
class AdminProductProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = 'active'; // 'active' | 'archived' | 'all'
  String _searchQuery = '';
  String _filterCategoryId = '';

  List<ProductModel> get products => _filteredProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;
  String get filterCategoryId => _filterCategoryId;

  List<ProductModel> get _filteredProducts {
    var list = _products.where((p) {
      if (_filterStatus == 'active') return !p.isArchived;
      if (_filterStatus == 'archived') return p.isArchived;
      return true;
    }).toList();

    if (_filterCategoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == _filterCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  AdminProductProvider() {
    _initData();
  }

  Future<void> _initData() async {
    await loadCategories();
    await loadProducts();
    await _correctProductCategories();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snap =
          await _db.collection('products').orderBy('name').get();
      _products = snap.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách sản phẩm: $e';
      AppLogger.error('AdminProductProvider.loadProducts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      final snap = await _db
          .collection('categories')
          .orderBy('displayOrder')
          .get();
      _categories = snap.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      AppLogger.error('AdminProductProvider.loadCategories: $e');
    }
  }

  // ─── Tự động sửa lỗi dữ liệu danh mục sản phẩm trên Firestore ──────────────

  Future<void> _correctProductCategories() async {
    if (_categories.isEmpty || _products.isEmpty) return;

    final cafeCat = _categories.firstWhere((c) => c.name.toLowerCase().contains('cà phê'), orElse: () => _categories[0]);
    final teaCat = _categories.firstWhere((c) => c.name.toLowerCase().contains('trà') || c.name.toLowerCase().contains('nước'), orElse: () => _categories[0]);
    final cakeCat = _categories.firstWhere((c) => c.name.toLowerCase().contains('bánh') || c.name.toLowerCase().contains('snack') || c.name.toLowerCase().contains('tráng miệng'), orElse: () => _categories[0]);
    final iceCat = _categories.firstWhere((c) => c.name.toLowerCase().contains('đá xay') || c.name.toLowerCase().contains('blended'), orElse: () => _categories[0]);
    final specialCat = _categories.firstWhere((c) => c.name.toLowerCase().contains('đặc biệt') || c.name.toLowerCase().contains('khác'), orElse: () => _categories[0]);

    bool hasUpdates = false;

    for (final p in _products) {
      String targetCatId = p.categoryId;
      final nameLower = p.name.toLowerCase();

      // Check "Đá xay" first to prevent blended drinks from leaking into Tea or Cakes
      if (nameLower.contains('đá xay') || nameLower.contains('blended')) {
        targetCatId = iceCat.id;
      } else if (nameLower.contains('americano') ||
          nameLower.contains('bạc sỉu') ||
          nameLower.contains('cà phê') ||
          nameLower.contains('cappuccino') ||
          nameLower.contains('espresso')) {
        targetCatId = cafeCat.id;
      } else if (nameLower.contains('trà') ||
          nameLower.contains('nước ép') ||
          nameLower.contains('matcha') ||
          nameLower.contains('sinh tố') ||
          nameLower.contains('juice') ||
          nameLower.contains('tea')) {
        targetCatId = teaCat.id;
      } else if (nameLower.contains('bánh') ||
          nameLower.contains('croissant') ||
          nameLower.contains('cookie') ||
          nameLower.contains('hạt') ||
          nameLower.contains('snack') ||
          nameLower.contains('hướng dương')) {
        targetCatId = cakeCat.id;
      } else if (nameLower.contains('combo') ||
          nameLower.contains('ly sứ') ||
          nameLower.contains('đặc biệt')) {
        targetCatId = specialCat.id;
      }

      final isCatValid = _categories.any((c) => c.id == p.categoryId);
      if (!isCatValid || p.categoryId != targetCatId) {
        try {
          await _db.collection('products').doc(p.id).update({'categoryId': targetCatId});
          AppLogger.info('Corrected category for ${p.name} -> $targetCatId');
          hasUpdates = true;
        } catch (e) {
          AppLogger.error('Error correcting category for ${p.name}: $e');
        }
      }
    }

    if (hasUpdates) {
      // Refresh local list
      final snap = await _db.collection('products').orderBy('name').get();
      _products = snap.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
      notifyListeners();
    }
  }

  // ─── UC-31: Tạo sản phẩm ─────────────────────────────────────────────────

  Future<bool> createProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ref = _db.collection('products').doc();
      final newProduct = product.copyWith(
        id: ref.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.set(ProductModel.toFirestore(newProduct));
      _products.insert(0, newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo sản phẩm: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── UC-32: Cập nhật sản phẩm ────────────────────────────────────────────

  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = product.copyWith(updatedAt: DateTime.now());
      await _db
          .collection('products')
          .doc(product.id)
          .update(ProductModel.toFirestore(updated));
      final idx = _products.indexWhere((p) => p.id == product.id);
      if (idx != -1) _products[idx] = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật sản phẩm: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── UC-33: Archive/Restore sản phẩm ─────────────────────────────────────

  Future<bool> archiveProduct(String productId) async {
    return _setArchiveStatus(productId, true);
  }

  Future<bool> restoreProduct(String productId) async {
    return _setArchiveStatus(productId, false);
  }

  Future<bool> _setArchiveStatus(String productId, bool archived) async {
    try {
      await _db.collection('products').doc(productId).update({
        'isArchived': archived,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(isArchived: archived);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi ${archived ? 'archive' : 'restore'} sản phẩm: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAvailability(String productId, bool isAvailable) async {
    try {
      await _db.collection('products').doc(productId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(isAvailable: isAvailable);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật trạng thái: $e';
      notifyListeners();
      return false;
    }
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
