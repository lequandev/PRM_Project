import 'dart:async';
import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class MenuProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  
  // High-performance caching and indexing
  List<ProductModel> _cachedFilteredProducts = [];
  final Map<String, List<ProductModel>> _categoryIndex = {};
  
  String _selectedCategoryId = '';
  String _searchQuery = '';
  bool _isLoading = false;
  
  // Debouncer for search to prevent stuttering
  Timer? _debounceTimer;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // O(1) getter instead of O(N) dynamic filtering
  List<ProductModel> get filteredProducts => _cachedFilteredProducts;

  final ProductService _productService = ProductService();

  MenuProvider() {
    loadData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedCategories = await _productService.getCategories();
      final fetchedProducts = await _productService.getProductsByCategory('');

      _categories = [
        const CategoryModel(id: '', name: 'Tất cả', displayOrder: 0),
        ...fetchedCategories,
      ];
      _products = fetchedProducts;
      
      _buildCategoryIndex();
      _applyFilter();
    } catch (e) {
      debugPrint('⚠️ Error loading real menu data: $e');
      _categories = [
        const CategoryModel(id: '', name: 'Tất cả', displayOrder: 0),
      ];
      _products = [];
      _cachedFilteredProducts = [];
      _categoryIndex.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pre-computes products for each category for instant O(1) switching
  void _buildCategoryIndex() {
    _categoryIndex.clear();
    // Default 'All' category
    _categoryIndex[''] = List.from(_products);
    
    for (var cat in _categories) {
      if (cat.id.isEmpty) continue;
      
      final categoryIdLower = cat.id.toLowerCase().trim();
      final categoryNameLower = cat.name.toLowerCase().trim();
      
      _categoryIndex[cat.id] = _products.where((p) {
        final productCatLower = p.categoryId.toLowerCase().trim();
        return productCatLower == categoryIdLower || productCatLower == categoryNameLower;
      }).toList();
    }
  }

  // Core filter logic that updates the cache
  void _applyFilter() {
    // 1. Fast category lookup via index (O(1))
    List<ProductModel> result = _categoryIndex[_selectedCategoryId] ?? _products;

    // 2. Apply search text filter if exists (O(N) but only done once per keystroke, not per frame)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    _cachedFilteredProducts = result;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _applyFilter();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    
    _searchQuery = query;
    
    // Debounce the filter operation by 300ms to keep typing ultra-smooth
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilter();
    });
  }
}
