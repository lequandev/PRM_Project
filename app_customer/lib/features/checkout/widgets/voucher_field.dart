import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';
import 'section_card.dart';

/// UC-14 — Ô nhập mã giảm giá + trạng thái áp dụng thành công / lỗi.
class VoucherField extends StatefulWidget {
  const VoucherField({super.key});

  @override
  State<VoucherField> createState() => _VoucherFieldState();
}

class _VoucherFieldState extends State<VoucherField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final voucher = provider.voucher;

    return SectionCard(
      title: 'Mã giảm giá',
      child: voucher != null
          ? _AppliedVoucherCard(
              voucher: voucher,
              onRemove: () {
                provider.removeVoucher();
                _controller.clear();
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.characters,
                        enabled: !provider.isApplyingVoucher,
                        decoration: const InputDecoration(
                          hintText: 'Nhập mã (vd: COFFEE20)',
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                          isDense: true,
                        ),
                        onSubmitted: (v) => provider.applyVoucher(v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: provider.isApplyingVoucher
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                provider.applyVoucher(_controller.text);
                              },
                        child: provider.isApplyingVoucher
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5),
                              )
                            : const Text('Áp dụng'),
                      ),
                    ),
                  ],
                ),
                if (provider.voucherError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: AppColors.error),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          provider.voucherError!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

/// Thẻ xanh khi voucher hợp lệ — hiện mã + mô tả + nút bỏ.
class _AppliedVoucherCard extends StatelessWidget {
  const _AppliedVoucherCard({required this.voucher, required this.onRemove});

  final VoucherModel voucher;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.code,
                  style:
                      AppTypography.h4.copyWith(color: AppColors.success),
                ),
                const SizedBox(height: 2),
                Text(
                  voucher.description,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Bỏ mã',
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
