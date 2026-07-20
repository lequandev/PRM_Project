import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';
import 'section_card.dart';

/// UC-16 — Chọn phương thức thanh toán.
///
/// 2 lựa chọn có ý nghĩa: tiền mặt (thu khi giao) và chuyển khoản/VietQR qua
/// PayOS (THẬT). Enum core không có giá trị 'payos' riêng nên dùng `vnpay` làm
/// đại diện cho "online/PayOS" — đơn sẽ lưu paymentMethod='vnpay'.
class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({super.key});

  static const _options = <_PayOption>[
    _PayOption(
      method: PaymentMethod.cash,
      label: 'Tiền mặt',
      subtitle: 'Thanh toán khi nhận hàng',
      icon: Icons.payments_outlined,
    ),
    _PayOption(
      method: PaymentMethod.vnpay,
      label: 'Chuyển khoản / Quét mã',
      subtitle: 'Quét VietQR bằng app ngân hàng (PayOS)',
      icon: Icons.qr_code_2_rounded,
    ),
  ];

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
            for (final opt in _options)
              RadioListTile<PaymentMethod>(
                value: opt.method,
                dense: true,
                activeColor: AppColors.goldPrimary,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                secondary: Icon(
                  opt.icon,
                  color: provider.paymentMethod == opt.method
                      ? AppColors.goldPrimary
                      : AppColors.textSecondary,
                ),
                title: Text(opt.label, style: AppTypography.bodyMedium),
                subtitle: Text(
                  opt.subtitle,
                  style:
                      AppTypography.caption.copyWith(color: AppColors.textHint),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PayOption {
  const _PayOption({
    required this.method,
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final PaymentMethod method;
  final String label;
  final String subtitle;
  final IconData icon;
}
