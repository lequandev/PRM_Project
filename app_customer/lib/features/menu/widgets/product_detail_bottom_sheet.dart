import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../cart/providers/cart_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Khởi tạo lựa chọn mặc định
    for (var cust in widget.product.customizations) {
      if (cust.choices.isNotEmpty) {
        _selectedCustomizations[cust.type] = cust.choices.first.value;
      }
    }
  }

  double get _extraPrice {
    double extra = 0;
    for (var cust in widget.product.customizations) {
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
                'Đã thêm $_quantity ${widget.product.name}',
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: widget.product.imageUrl != null
                    ? Image.network(
                        widget.product.imageUrl!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 250,
                        width: double.infinity,
                        color: AppColors.beigeWarm,
                        child: const Icon(Icons.coffee, size: 80, color: AppColors.goldPrimary),
                      ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Product Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          formatCurrency.format(widget.product.basePrice),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.goldPrimary),
                        ),
                      ],
                    ),
                    if (widget.product.description != null && widget.product.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.product.description!,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Customizations
                    ...widget.product.customizations.map((cust) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cust.label,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: cust.choices.map((choice) {
                                final isSelected = _selectedCustomizations[cust.type] == choice.value;
                                return ChoiceChip(
                                  label: Text(
                                    choice.extraPrice > 0 ? '${choice.label} (+${formatCurrency.format(choice.extraPrice)})' : choice.label,
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCustomizations[cust.type] = choice.value;
                                      });
                                    }
                                  },
                                  selectedColor: AppColors.goldPrimary.withOpacity(0.2),
                                  backgroundColor: AppColors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.goldPrimary : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
                                  ),
                                  showCheckmark: false,
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

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Quantity
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.textSecondary),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.textPrimary),
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Thêm - ${formatCurrency.format(_totalPrice)}',
                          style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
