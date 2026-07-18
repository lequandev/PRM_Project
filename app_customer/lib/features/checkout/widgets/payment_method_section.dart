import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';
import 'section_card.dart';

/// UC-16 — Chọn phương thức thanh toán.
/// Cổng online (VNPay/MoMo/ZaloPay) đang chạy Demo — chờ tích hợp SDK thật.
class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({super.key});

  static const _icons = <PaymentMethod, IconData>{
    PaymentMethod.cash: Icons.payments_outlined,
    PaymentMethod.vnpay: Icons.account_balance_outlined,
    PaymentMethod.momo: Icons.account_balance_wallet_outlined,
    PaymentMethod.zalopay: Icons.qr_code_2_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return SectionCard(
      title: 'Phương thức thanh toán',
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: RadioGroup<PaymentMethod>(
        groupValue: provider.paymentMethod,
        onChanged: (method) {
          if (method != null) provider.setPaymentMethod(method);
        },
        child: Column(
          children: [
            for (final method in PaymentMethod.values)
              RadioListTile<PaymentMethod>(
                value: method,
                dense: true,
                activeColor: AppColors.goldPrimary,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                secondary: Icon(
                  _icons[method],
                  color: provider.paymentMethod == method
                      ? AppColors.goldPrimary
                      : AppColors.textSecondary,
                ),
                title: Row(
                  children: [
                    Text(method.label, style: AppTypography.bodyMedium),
                    if (method != PaymentMethod.cash) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const _DemoChip(),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Nhãn 'Demo' cho cổng thanh toán online chưa tích hợp thật.
class _DemoChip extends StatelessWidget {
  const _DemoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.warning),
      ),
      child: Text(
        'Demo',
        style: AppTypography.caption.copyWith(color: AppColors.warning),
      ),
    );
  }
}
