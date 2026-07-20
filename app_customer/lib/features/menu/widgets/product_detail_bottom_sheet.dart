import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../cart/providers/cart_provider.dart';
import '../providers/menu_provider.dart';

class ProductDetailBottomSheet extends StatefulWidget {
  final ProductModel product;

  const ProductDetailBottomSheet({super.key, required this.product});

  static void show(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailBottomSheet(product: product),
    );
  }

  @override
  State<ProductDetailBottomSheet> createState() => _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  final Map<String, String> _selectedCustomizations = {};
  int _quantity = 1;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  late List<CustomizationModel> _displayCustomizations;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _displayCustomizations = List.from(widget.product.customizations);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;

      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final category = menuProvider.categories.firstWhere(
        (c) => c.id == widget.product.categoryId,
        orElse: () => const CategoryModel(id: '', name: '', displayOrder: 0),
      );
      final categoryName = category.name.toLowerCase();

      // Only show Sugar and Ice for 'trà', 'ép', 'cafe', 'cà phê', 'đá xay'
      bool isDrinkWithIceAndSugar = categoryName.contains('trà') || 
                                    categoryName.contains('ép') || 
                                    categoryName.contains('cafe') || 
                                    categoryName.contains('cà phê') ||
                                    categoryName.contains('đá xay');

      if (isDrinkWithIceAndSugar) {
        _displayCustomizations.addAll([
          const CustomizationModel(
            id: 'sugar_options',
            type: 'sugar',
            label: 'Lượng đường',
            choices: [
              CustomizationChoice(value: '100', label: '100% Đường'),
              CustomizationChoice(value: '70', label: '70% Ít đường'),
              CustomizationChoice(value: '50', label: '50% Nửa đường'),
              CustomizationChoice(value: '0', label: '0% Không đường'),
            ],
          ),
          const CustomizationModel(
            id: 'ice_options',
            type: 'ice',
            label: 'Lượng đá',
            choices: [
              CustomizationChoice(value: '100', label: '100% Đá'),
              CustomizationChoice(value: '50', label: '50% Ít đá'),
              CustomizationChoice(value: '0', label: '0% (Nóng)'),
            ],
          )
        ]);
      }

      // Khởi tạo lựa chọn mặc định
      for (var cust in _displayCustomizations) {
        if (cust.choices.isNotEmpty) {
          _selectedCustomizations[cust.type] = cust.choices.first.value;
        }
      }
    }
  }

  double get _extraPrice {
    double extra = 0;
    for (var cust in _displayCustomizations) {
      final selectedValue = _selectedCustomizations[cust.type];
      if (selectedValue != null) {
        final choice = cust.choices.firstWhere(
          (c) => c.value == selectedValue,
          orElse: () => const CustomizationChoice(label: '', value: '', extraPrice: 0),
        );
        extra += choice.extraPrice;
      }
    }
    return extra;
  }

  double get _totalPrice {
    return (widget.product.basePrice + _extraPrice) * _quantity;
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(widget.product, _selectedCustomizations, _extraPrice, _quantity);
    
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đã thêm $_quantity ${widget.product.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 2000),
        backgroundColor: AppColors.brownAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.94, // Makes it behave almost like a full page
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Stack(
            children: [
              // 1. Fixed Hero Image Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 360,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          color: AppColors.beigeWarm,
                          child: const Icon(Icons.local_cafe_rounded, size: 100, color: AppColors.goldLight),
                        ),
                ),
              ),

              // 2. Main Scrollable Content (Slides over the image)
              Positioned.fill(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Transparent area so the fixed image is visible initially
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 320),
                    ),
                    // White container for product details
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'serif',
                                  color: AppColors.brownAccent,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              formatCurrency.format(widget.product.basePrice),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Description
                        if (widget.product.description != null && widget.product.description!.isNotEmpty)
                          Text(
                            widget.product.description!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Customizations Options
                        ..._displayCustomizations.map((cust) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.goldPrimary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      cust.label,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brownAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: cust.choices.map((choice) {
                                    final isSelected = _selectedCustomizations[cust.type] == choice.value;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCustomizations[cust.type] = choice.value;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.brownAccent : AppColors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected ? AppColors.brownAccent : AppColors.borderLight,
                                            width: 1.5,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.brownAccent.withValues(alpha: 0.25),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          choice.extraPrice > 0
                                              ? '${choice.label} (+${formatCurrency.format(choice.extraPrice)})'
                                              : choice.label,
                                          style: TextStyle(
                                            color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          );
                        }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Gradient Overlay at top for tags & close button visibility
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Tags Fixed Over Image
              if (widget.product.tags.isNotEmpty)
                Positioned(
                  top: 24,
                  left: 24,
                  child: Wrap(
                    spacing: 8,
                    children: widget.product.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Close Button Fixed Over Image
              Positioned(
                top: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: AppColors.white, size: 24),
                  ),
                ),
              ),


              // Floating Bottom Action Bar (Island Design)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brownAccent.withValues(alpha: 0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Quantity Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.remove_rounded, color: AppColors.brownAccent, size: 20),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 40),
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brownAccent,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_rounded, color: AppColors.brownAccent, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add to Cart Action Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Thêm - ${formatCurrency.format(_totalPrice)}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

