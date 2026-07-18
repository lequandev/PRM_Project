import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';
import 'section_card.dart';

/// Card tổng kết tiền: tạm tính, giảm giá, phí giao, tổng cộng, điểm thưởng.
class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return SectionCard(
      title: 'Tổng kết đơn hàng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(label: 'Tạm tính', value: provider.subtotal.toVnd),
          if (provider.discount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Giảm giá (${provider.voucher?.code ?? ''})',
              value: '-${provider.discount.toVnd}',
              valueColor: AppColors.success,
            ),
          ],
          if (provider.orderType == OrderType.delivery) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
                label: 'Phí giao hàng', value: provider.deliveryFee.toVnd),
          ],
          const Divider(
              height: AppSpacing.lg, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: AppTypography.h4),
              Text(
                provider.total.toVnd,
                style:
                    AppTypography.price.copyWith(color: AppColors.brownAccent),
              ),
            ],
          ),
          if (provider.estimatedPoints > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.stars_rounded,
                    size: 16, color: AppColors.goldPrimary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Tích được ~${provider.estimatedPoints} điểm',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.priceSmall
              .copyWith(color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
