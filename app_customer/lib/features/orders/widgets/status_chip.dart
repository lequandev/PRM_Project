import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';

/// Chip nhỏ hiển thị trạng thái đơn: nền nhạt + chữ đậm cùng tông.
/// - pending/accepted/preparing/ready → gold nhạt / chữ nâu
/// - delivered → xanh success nhạt / chữ success
/// - cancelled → đỏ nhạt / chữ error
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    switch (status) {
      case OrderStatus.delivered:
        background = AppColors.successLight;
        foreground = AppColors.success;
      case OrderStatus.cancelled:
        background = AppColors.errorLight;
        foreground = AppColors.error;
      case OrderStatus.pending:
      case OrderStatus.accepted:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        background = AppColors.goldPrimary.withValues(alpha: .14);
        foreground = AppColors.brownAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: AppTypography.label.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
