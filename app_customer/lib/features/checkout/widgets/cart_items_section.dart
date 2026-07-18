import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';
import 'section_card.dart';

/// UC-13 — Danh sách món trong đơn (đọc từ giỏ hàng của Dev 2).
class CartItemsSection extends StatelessWidget {
  const CartItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final items = provider.items;

    return SectionCard(
      title: 'Món đã chọn (${provider.itemCount})',
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: AppSpacing.lg, color: AppColors.borderLight),
            _CartItemRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ảnh placeholder — menu thật của Dev 2 sẽ có ảnh sản phẩm.
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.beigeWarm,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.local_cafe_outlined,
              color: AppColors.brownAccent),
        ),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName, style: AppTypography.h4),
              if (item.customizations.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final entry in item.customizations.entries)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${item.unitPrice.toVnd} × ${item.quantity}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(item.totalPrice.toVnd, style: AppTypography.priceSmall),
      ],
    );
  }
}
