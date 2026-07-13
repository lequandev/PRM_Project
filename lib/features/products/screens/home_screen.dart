import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../widgets/home_appbar.dart';
import '../widgets/category_grid.dart';
import '../widgets/product_card.dart';
import '../../../../util/colors.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  const HomeScreen({super.key, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  String _selectedCategory = 'coffee';
  String _searchQuery = '';
  List<String> _favorites = [];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 17) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? LuxeColors.bgDark
          : LuxeColors.bgLight,
      appBar: HomeAppBar(
        isDarkMode: widget.isDarkMode,
        unreadNotifications: 3,
        onMenuTap: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, Quan',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Hôm nay bạn muốn thưởng thức loại cà phê nào?',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Tìm Kiếm (Search)
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đồ uống, bánh...',
                prefixIcon: const Icon(Icons.search, size: 18),
                fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_searchQuery.isEmpty) ...[
              CategoryGrid(
                isDarkMode: widget.isDarkMode,
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) =>
                    setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: 16),
            ],

            // Lưới Sản phẩm thời gian thực kết nối Firebase
            StreamBuilder<List<Product>>(
              stream: _productService.streamProducts(
                category: _searchQuery.isEmpty ? _selectedCategory : null,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: LuxeColors.goldPrimary,
                    ),
                  );
                }
                final products = snapshot.data ?? [];

                // Client-side search logic if typing
                final filtered = products
                    .where(
                      (p) => p.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Không tìm thấy sản phẩm.'),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final prod = filtered[index];
                    return ProductCard(
                      product: prod,
                      isDarkMode: widget.isDarkMode,
                      isFavorite: _favorites.contains(prod.id),
                      onFavoriteToggle: () => setState(() {
                        _favorites.contains(prod.id)
                            ? _favorites.remove(prod.id)
                            : _favorites.add(prod.id);
                      }),
                      onAddToCart: () {},
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
