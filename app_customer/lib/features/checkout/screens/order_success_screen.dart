import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../common/order_code.dart';
import '../../../data/order_repository.dart';

/// UC-17 — Màn ăn mừng sau khi đặt hàng thành công.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late final Future<OrderModel> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<OrderRepository>().getOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: FutureBuilder<OrderModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorState(orderId: widget.orderId);
            }
            return _SuccessBody(order: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),

          // Vòng tròn check ăn mừng
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: .35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                size: 64, color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Đặt hàng thành công!', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.orderType == OrderType.delivery.name
                ? 'Quán đang chuẩn bị, đơn sẽ được giao tận nơi.'
                : 'Quán đang chuẩn bị, bạn ghé lấy khi đơn sẵn sàng nhé.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Thông tin đơn
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadow.card,
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Mã đơn hàng', value: order.shortCode),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  label: 'Thời gian đặt',
                  value: order.createdAt.toVnDateTimeOrDash,
                ),
                const Divider(
                    height: AppSpacing.lg, color: AppColors.borderLight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng tiền',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    Text(
                      order.totalAmount.toVnd,
                      style: AppTypography.price
                          .copyWith(color: AppColors.brownAccent),
                    ),
                  ],
                ),
                if (order.loyaltyPointsEarned > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.beigeWarm,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded,
                            size: 18, color: AppColors.goldPrimary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '+${order.loyaltyPointsEarned} điểm',
                          style: AppTypography.label
                              .copyWith(color: AppColors.brownAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),

          // Hành động
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.pushReplacement('/orders/${order.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.textOnGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: const Icon(Icons.location_searching_rounded, size: 20),
              label: const Text('Theo dõi đơn hàng', style: AppTypography.button),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownAccent,
                side: const BorderSide(color: AppColors.brownAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text('Về trang chủ', style: AppTypography.button),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.h4),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            const Text('Không tải được đơn hàng', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đơn $orderId đã được ghi nhận nhưng chưa hiển thị được chi tiết.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.pushReplacement('/orders/$orderId'),
              child: const Text('Xem trong đơn hàng của tôi'),
            ),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
