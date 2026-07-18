import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

import '../providers/menu_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_bottom_sheet.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Khám phá Menu', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          return CustomScrollView(
            slivers: [
              // Banners hoặc lời chào hấp dẫn
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.warmHeaderGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chào buổi sáng! ☕',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brownAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hãy bắt đầu ngày mới với một ly thức uống tuyệt hảo từ chúng tôi.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.brownAccent.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: menuProvider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm đồ uống...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.goldPrimary),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Category Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: CategoryFilterBar(
                    categories: menuProvider.categories,
                    selectedCategoryId: menuProvider.selectedCategoryId,
                    onCategorySelected: menuProvider.selectCategory,
                  ),
                ),
              ),

              // Product Grid
              menuProvider.isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = menuProvider.filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                ProductDetailBottomSheet.show(context, product);
                              },
                              onAddTap: () {
                                if (product.customizations.isNotEmpty) {
                                  ProductDetailBottomSheet.show(context, product);
                                  return;
                                }
                                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                // Quick add for no-customization products
                                cartProvider.addItem(product, {}, 0, 1);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white24,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Đã thêm 1 ${product.name}',
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(milliseconds: 1500),
                                    backgroundColor: AppColors.goldPrimary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16, left: 32, right: 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    elevation: 8,
                                  ),
                                );
                              },
                            );
                          },
                          childCount: menuProvider.filteredProducts.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

