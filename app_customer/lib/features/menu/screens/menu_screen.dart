import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

import '../../../common/widgets/app_network_image.dart';
import '../providers/menu_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/product_detail_bottom_sheet.dart';
import '../widgets/teacher_special_panel.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isDarkMode = false;
  
  // Premium AgentAI Dark Mode Palette
  Color get _bgColor => _isDarkMode ? const Color(0xFF0F111A) : AppColors.backgroundLight;
  Color get _cardColor => _isDarkMode ? const Color(0xFF1C1F2E) : AppColors.cardBackground;
  Color get _textColor => _isDarkMode ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
  Color get _subTextColor => _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary;
  Color get _borderColor => _isDarkMode ? const Color(0xFF2E3348) : AppColors.borderLight;
  Color get _appBarColor => _isDarkMode ? const Color(0xFF0F111A) : AppColors.white;
  Color get _iconColor => _isDarkMode ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
  Color get _goldAccent => _isDarkMode ? const Color(0xFFFBBF24) : AppColors.goldPrimary; // Brighter gold for dark mode
  Color get _glowColor => _isDarkMode ? const Color(0xFFFBBF24).withOpacity(0.15) : AppColors.textPrimary.withOpacity(0.03);
  bool _isListView = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildTopBar(),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {


          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. Category Menu Grid Card
                  SliverToBoxAdapter(
                    child: _buildCategoryGrid(menuProvider),
                  ),

                  // 2. Category Section Header Banner
                  SliverToBoxAdapter(
                    child: _buildCategoryBanner(menuProvider),
                  ),

                  // 3. Dual-Column Product Grid
                  menuProvider.isLoading
                      ? const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.goldPrimary),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Khoảng trống cho floating cart
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _isListView ? 1 : 2,
                              childAspectRatio: _isListView ? 2.8 : 0.76,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = menuProvider.filteredProducts[index];
                                return _buildProductCard(context, product);
                              },
                              childCount: menuProvider.filteredProducts.length,
                            ),
                          ),
                        ),
                ],
              ),

              // 4. Floating Cart Bar right above bottom nav
              const Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _FloatingCartPopup(),
              ),
            ],
          );
        },
      ),
    );
  }

  // A. Custom Top App Bar
  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      backgroundColor: _appBarColor,
      elevation: 0.5,
      leadingWidth: _isSearching ? 0 : 150,
      leading: _isSearching
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF1C1F2E) : _bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor),
                boxShadow: _isDarkMode ? [BoxShadow(color: _glowColor, blurRadius: 8, spreadRadius: -2)] : [],
              ),
              child: Row(
                children: [
                  Icon(Icons.apps, size: 16, color: _isDarkMode ? _goldAccent : AppColors.brownAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Danh mục',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: _subTextColor),
                ],
              ),
            ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: _subTextColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: _subTextColor, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<MenuProvider>(context, listen: false).setSearchQuery('');
                  },
                ),
              ),
              onChanged: (value) {
                Provider.of<MenuProvider>(context, listen: false).setSearchQuery(value);
              },
            )
          : null,
      actions: _isSearching
          ? [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    Provider.of<MenuProvider>(context, listen: false).setSearchQuery('');
                  });
                },
                child: Text('Hủy', style: TextStyle(color: AppColors.brownAccent)),
              ),
              const SizedBox(width: 8),
            ]
          : [
              // Dark mode toggle (Premium UI)
              Row(
                children: [
                  Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 18, color: _goldAccent),
                  Switch(
                    value: _isDarkMode,
                    activeColor: _goldAccent,
                    activeTrackColor: _goldAccent.withOpacity(0.3),
                    inactiveThumbColor: AppColors.textSecondary,
                    inactiveTrackColor: AppColors.borderLight,
                    onChanged: (val) {
                      setState(() {
                        _isDarkMode = val;
                      });
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isListView ? Icons.grid_view : Icons.view_list,
                  color: _subTextColor,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isListView = !_isListView;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.search, color: _subTextColor, size: 20),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: _subTextColor, size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
    );
  }

  // B. Category Menu Grid Card (3x2 Grid displaying 6 categories)
  Widget _buildCategoryGrid(MenuProvider provider) {
    // 6 categories matching standard setup
    final categoriesData = [
      {'id': 'A1ZglutP5091IkqOZga1', 'name': 'Cà phê', 'icon': Icons.coffee},
      {'id': 'miH0qTSZVdsneEsMN6b5', 'name': 'Trà & Ép', 'icon': Icons.local_drink},
      {'id': 'N5GPV3Bzak7UwkVZtN45', 'name': 'Bánh', 'icon': Icons.cake},
      {'id': 'RDoj8SRwWRxlcxzhC6nG', 'name': 'Đá xay', 'icon': Icons.icecream},
      {'id': 'cOQPqGseTCNScIQwBgtn', 'name': 'Đặc biệt', 'icon': Icons.star},
      {'id': '', 'name': 'Tất cả', 'icon': Icons.menu_open},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isDarkMode ? _borderColor : AppColors.goldPrimary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: _glowColor,
            blurRadius: _isDarkMode ? 12 : 10,
            spreadRadius: _isDarkMode ? 1 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: categoriesData.length,
            itemBuilder: (context, index) {
              final cat = categoriesData[index];
              final isSelected = provider.selectedCategoryId == cat['id'];

              return GestureDetector(
                onTap: () {
                  provider.selectCategory(cat['id'] as String);
                },
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? _goldAccent : (_isDarkMode ? const Color(0xFF2E3348) : AppColors.backgroundLight),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? (_isDarkMode ? _goldAccent : AppColors.goldLight) : _borderColor,
                          width: 1,
                        ),
                        boxShadow: isSelected && _isDarkMode ? [BoxShadow(color: _glowColor, blurRadius: 8, spreadRadius: 1)] : [],
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? (_isDarkMode ? const Color(0xFF0F111A) : Colors.white) : (_isDarkMode ? _iconColor : AppColors.brownAccent),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['name'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? _goldAccent : _textColor,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Small elegant page indicator line
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.goldPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // C. Category Section Header Banner (Premium Highlight Design)
  Widget _buildCategoryBanner(MenuProvider provider) {
    String categoryName = 'Menu Nổi Bật';
    IconData categoryIcon = Icons.auto_awesome;
    String subtitle = 'Hương vị tuyệt hảo dành cho bạn';

    if (provider.selectedCategoryId.isNotEmpty) {
      final activeCat = provider.categories.firstWhere(
        (c) => c.id == provider.selectedCategoryId,
        orElse: () => const CategoryModel(id: '', name: ''),
      );
      if (activeCat.name.isNotEmpty) {
        categoryName = activeCat.name;
        
        // Dynamically assign subtitle and icons based on category
        final lowerName = categoryName.toLowerCase();
        if (lowerName.contains('cà phê')) {
          categoryIcon = Icons.coffee_rounded;
          subtitle = 'Đánh thức năng lượng ngày mới';
        } else if (lowerName.contains('trà')) {
          categoryIcon = Icons.local_drink_rounded;
          subtitle = 'Thanh mát, giải nhiệt tự nhiên';
        } else if (lowerName.contains('bánh')) {
          categoryIcon = Icons.cake_rounded;
          subtitle = 'Ngọt ngào từng khoảnh khắc';
        } else if (lowerName.contains('đặc biệt')) {
          categoryIcon = Icons.star_rounded;
          subtitle = 'Công thức độc quyền từ chúng tôi';
        } else if (lowerName.contains('đá xay')) {
          categoryIcon = Icons.icecream_rounded;
          subtitle = 'Mát lạnh sảng khoái, đậm vị';
        } else {
          categoryIcon = Icons.restaurant_menu_rounded;
          subtitle = 'Khám phá thực đơn hấp dẫn';
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brownAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brownAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🌟 MỤC YÊU THÍCH',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  categoryName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: AppColors.bannerGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(categoryIcon, color: AppColors.brownAccent, size: 32),
          ),
        ],
      ),
    );
  }

  // D. Product Card (Clean White, Absolute Tags, Quick Action Button)
  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final discountText = product.tags.isNotEmpty ? product.tags.first : null;

    if (_isListView) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                product.imageUrl,
                width: 75,
                height: 75,
                background: AppColors.backgroundAlt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.basePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{3})+(?!\d)'), (Match m) => '${m[0]}.')}đ',
                    style: TextStyle(
                      color: _isDarkMode ? _goldAccent : AppColors.brownAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (product.customizations.isNotEmpty) {
                  ProductDetailBottomSheet.show(context, product);
                  return;
                }
                Provider.of<CartProvider>(context, listen: false).addItem(product, {}, 0, 1);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _goldAccent,
                  shape: BoxShape.circle,
                  boxShadow: _isDarkMode ? [BoxShadow(color: _glowColor, blurRadius: 6)] : [],
                ),
                child: Icon(Icons.add, color: _isDarkMode ? const Color(0xFF0F111A) : Colors.white, size: 18),
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        ProductDetailBottomSheet.show(context, product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Stack(
          children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: AppNetworkImage(
                      product.imageUrl,
                      background: AppColors.backgroundAlt,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.basePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{3})+(?!\d)'), (Match m) => '${m[0]}.')}đ',
                      style: TextStyle(
                        color: _isDarkMode ? _goldAccent : AppColors.brownAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Absolute positioned promotional tag
          if (discountText != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  discountText.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Circular Action Button at bottom-right corner
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                if (product.customizations.isNotEmpty) {
                  ProductDetailBottomSheet.show(context, product);
                  return;
                }
                Provider.of<CartProvider>(context, listen: false).addItem(product, {}, 0, 1);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _goldAccent,
                  shape: BoxShape.circle,
                  boxShadow: _isDarkMode ? [BoxShadow(color: _glowColor, blurRadius: 6)] : [],
                ),
                child: Icon(Icons.add, color: _isDarkMode ? const Color(0xFF0F111A) : Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _FloatingCartPopup extends StatefulWidget {
  const _FloatingCartPopup();

  @override
  State<_FloatingCartPopup> createState() => _FloatingCartPopupState();
}

class _FloatingCartPopupState extends State<_FloatingCartPopup> {
  int _previousItemCount = 0;
  bool _isVisible = false;
  Timer? _timer;
  late CartProvider _cartProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cartProvider = Provider.of<CartProvider>(context, listen: false);
      _previousItemCount = _cartProvider.items.fold(0, (sum, item) => sum + item.quantity);
      _cartProvider.addListener(_onCartChanged);
    });
  }

  @override
  void dispose() {
    _cartProvider.removeListener(_onCartChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onCartChanged() {
    if (!mounted) return;
    final currentCount = _cartProvider.items.fold(0, (sum, item) => sum + item.quantity);
    
    if (currentCount > _previousItemCount) {
      // Item added! Show the popup
      setState(() {
        _isVisible = true;
      });
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
    _previousItemCount = currentCount;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    if (cartProvider.items.isEmpty) return const SizedBox.shrink();

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: _isVisible ? Offset.zero : const Offset(0, 1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.brownAccent.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${cartProvider.items.fold(0, (sum, item) => sum + item.quantity)} món trong giỏ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '${cartProvider.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{3})+(?!\d)'), (Match m) => '${m[0]}.')}đ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.shopping_bag, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
