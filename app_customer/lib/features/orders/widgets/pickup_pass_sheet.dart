import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../common/order_code.dart';
import '../../../common/widgets/app_network_image.dart';

/// Bottom sheet "thẻ nhận hàng" cho đơn pickup đã sẵn sàng (UC-19).
///
/// Mã QR chứa chính orderId — app_staff (Dev 4) quét mã này tại quầy
/// để xác nhận bàn giao đơn (UC-24).
Future<void> showPickupPassSheet(BuildContext context, OrderModel order) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (sheetContext) => _PickupPassSheet(order: order),
  );
}

class _PickupPassSheet extends StatelessWidget {
  const _PickupPassSheet({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.beigeWarm,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle — vuốt xuống để đóng (mặc định của bottom sheet)
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text('Mã nhận hàng', style: AppTypography.h3),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Đóng',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    _PassCard(order: order),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Đưa mã này cho nhân viên tại quầy để nhận hàng',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({required this.order});

  final OrderModel order;

  static String _customizationsText(Map<String, String> customizations) =>
      customizations.entries.map((e) => '${e.key} ${e.value}').join(' · ');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '☕ Coffee Shop',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.brownAccent,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Sẵn sàng lấy',
                  style: AppTypography.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Mã QR chứa order.id — app_staff (Dev 4) quét để xác nhận UC-24
          QrImageView(
            data: order.id,
            version: QrVersions.auto,
            size: 190,
            backgroundColor: AppColors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.brownAccent,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.brownAccent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'MÃ NHẬN HÀNG',
            style: AppTypography.caption.copyWith(
              color: AppColors.textHint,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            order.shortCode,
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(letterSpacing: 3),
          ),

          const Divider(height: AppSpacing.xl, color: AppColors.borderLight),

          for (final item in order.items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AppNetworkImage(
                    item.productImageUrl,
                    width: 44,
                    height: 44,
                    background: AppColors.beigeWarm,
                    iconColor: AppColors.brownAccent,
                    iconSize: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}x ${item.productName}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.customizations.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _customizationsText(item.customizations),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng đã thanh toán',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                order.totalAmount.toVnd,
                style: AppTypography.price.copyWith(
                  color: AppColors.brownAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
