import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

class MenuProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  String _selectedCategoryId = '';
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  String get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;

  List<ProductModel> get filteredProducts {
    if (_selectedCategoryId.isEmpty) return _products;
    return _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  MenuProvider() {
    _loadMockData();
  }

  void _loadMockData() async {
    _isLoading = true;
    notifyListeners();

    // Giả lập load API
    await Future.delayed(const Duration(milliseconds: 800));

    _categories = [
      const CategoryModel(id: '', name: 'Tất cả', displayOrder: 0),
      const CategoryModel(id: 'c1', name: 'Cà phê', displayOrder: 1),
      const CategoryModel(id: 'c2', name: 'Trà', displayOrder: 2),
      const CategoryModel(id: 'c3', name: 'Bánh ngọt', displayOrder: 3),
    ];

    _products = [
      const ProductModel(
        id: 'p1',
        name: 'Cà phê đen đá',
        categoryId: 'c1',
        basePrice: 29000,
        description: 'Cà phê đen nguyên chất, pha phin truyền thống.',
        imageUrl: 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=500&auto=format&fit=crop&q=60',
      ),
      const ProductModel(
        id: 'p2',
        name: 'Bạc xỉu',
        categoryId: 'c1',
        basePrice: 35000,
        description: 'Cà phê sữa nhiều sữa, béo ngậy.',
        imageUrl: 'https://images.unsplash.com/photo-1579888944111-ce1543719d36?w=500&auto=format&fit=crop&q=60',
      ),
      const ProductModel(
        id: 'p3',
        name: 'Trà đào cam sả',
        categoryId: 'c2',
        basePrice: 45000,
        description: 'Trà trái cây thanh mát, giải nhiệt mùa hè.',
        imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&auto=format&fit=crop&q=60',
      ),
      const ProductModel(
        id: 'p4',
        name: 'Tiramisu',
        categoryId: 'c3',
        basePrice: 49000,
        description: 'Bánh Tiramisu mềm mịn, thơm mùi cà phê.',
        imageUrl: 'https://images.unsplash.com/photo-1571115177098-24ec42ed204d?w=500&auto=format&fit=crop&q=60',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}
