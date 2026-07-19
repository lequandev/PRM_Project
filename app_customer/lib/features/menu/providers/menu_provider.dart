import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class MenuProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  String _selectedCategoryId = '';
  String _searchQuery = '';
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<ProductModel> get filteredProducts {
    List<ProductModel> result = _products;

    if (_selectedCategoryId.isNotEmpty) {
      final selectedCategory = _categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => const CategoryModel(id: '', name: ''),
      );
      
      final categoryIdLower = _selectedCategoryId.toLowerCase().trim();
      final categoryNameLower = selectedCategory.name.toLowerCase().trim();

      result = result.where((p) {
        final productCatLower = p.categoryId.toLowerCase().trim();
        return productCatLower == categoryIdLower || productCatLower == categoryNameLower;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    return result;
  }

  final ProductService _productService = ProductService();

  MenuProvider() {
    loadData();
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
    } catch (e) {
      debugPrint('⚠️ Error loading real menu data: $e');
      _categories = [
        const CategoryModel(id: '', name: 'Tất cả', displayOrder: 0),
      ];
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
