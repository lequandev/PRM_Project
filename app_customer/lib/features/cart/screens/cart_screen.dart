import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:intl/intl.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xóa tất cả'),
                      content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm khỏi giỏ hàng?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            cartProvider.clearCart();
                          },
                          child: const Text('Xóa hết', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Xóa hết', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Text(
                'Giỏ hàng của bạn đang trống',
                style: TextStyle(color: AppColors.textHint, fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.productImageUrl != null && item.productImageUrl!.isNotEmpty
                                ? Image.network(
                                    item.productImageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: AppColors.beigeWarm,
                                      child: const Icon(Icons.coffee, color: AppColors.goldPrimary, size: 36),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.beigeWarm,
                                    child: const Icon(Icons.coffee, color: AppColors.goldPrimary, size: 36),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary, height: 1.3),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showDeleteConfirmDialog(context, cartProvider, index),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                      ),
                                    ),
                                  ]
                                ),
                                if (item.customizations.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    item.customizations.entries
                                        .map((e) => '${_translateCustomizationType(e.key)}: ${_translateCustomizationValue(e.value)}')
                                        .join(' • '),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      formatCurrency.format(item.unitPrice),
                                      style: const TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    _buildQuantityController(context, cartProvider, index, item),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng cộng', style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            formatCurrency.format(cartProvider.totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldPrimary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (cartProvider.items.isEmpty) return;
                          // [Dev3] Vào checkout flow thật (UC-13->17):
                          // chọn nhận hàng/địa chỉ/voucher/thanh toán rồi
                          // tạo order thật. Trước đây chỉ bung dialog giả.
                          context.push('/checkout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Thanh toán', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      )
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

  Widget _buildQuantityController(BuildContext context, CartProvider provider, int index, OrderItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (item.quantity > 1) {
                provider.updateQuantity(index, item.quantity - 1);
              } else {
                _showDeleteConfirmDialog(context, provider, index);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove_rounded, color: AppColors.brownAccent, size: 16),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.brownAccent,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => provider.updateQuantity(index, item.quantity + 1),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.brownAccent, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, CartProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.removeItem(index);
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _translateCustomizationType(String type) {
    switch (type.toLowerCase()) {
      case 'size':
        return 'Size';
      case 'ice':
        return 'Đá';
      case 'sugar':
        return 'Đường';
      case 'milk':
        return 'Sữa';
      default:
        // Capitalize first letter as fallback
        if (type.isEmpty) return type;
        return type[0].toUpperCase() + type.substring(1);
    }
  }

  String _translateCustomizationValue(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return 'Không';
      case 'less':
        return 'Ít';
      case 'normal':
        return 'Bình thường';
      case 'extra':
        return 'Nhiều';
      default:
        return value;
    }
  }
}
