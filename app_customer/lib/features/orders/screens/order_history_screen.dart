import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../common/order_code.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../data/order_repository.dart';
import '../../../data/session.dart';
import '../providers/order_history_provider.dart';
import '../widgets/review_sheet.dart';
import '../widgets/status_chip.dart';

/// UC-18 — Lịch sử đơn hàng + entry đánh giá (UC-39) cho đơn hoàn thành.
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          OrderHistoryProvider(
        context.read<OrderRepository>(),
        context.read<CurrentSession>(),
      ),
      child: const _OrderHistoryView(),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderHistoryProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: Column(
        children: [
          _FilterBar(provider: provider),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderHistoryProvider provider) {
    if (provider.isLoading) return const _SkeletonList();

    if (provider.error != null) {
      return _ErrorState(message: provider.error!, onRetry: provider.refresh);
    }

    final orders = provider.filteredOrders;
    return RefreshIndicator(
      color: AppColors.goldPrimary,
      onRefresh: provider.refresh,
      child: orders.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
    );
  }
}

// ─────────────────────────── Filter chips ───────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.provider});

  final OrderHistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          for (final filter in OrderHistoryFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: provider.filter == filter,
              onSelected: (_) => provider.setFilter(filter),
              showCheckmark: false,
              selectedColor: AppColors.goldPrimary,
              backgroundColor: AppColors.cardBackground,
              labelStyle: AppTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: provider.filter == filter
                    ? AppColors.textOnGold
                    : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                side: BorderSide(
                  color: provider.filter == filter
                      ? AppColors.goldPrimary
                      : AppColors.borderLight,
                ),
              ),
            ),
            if (filter != OrderHistoryFilter.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────── Order card ───────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus;
    final itemsSummary = order.items
        .map((i) => '${i.quantity}x ${i.productName}')
        .join(', ');
    final typeAndPayment =
        '${OrderType.fromString(order.orderType).label}'
        ' · ${PaymentMethod.fromString(order.paymentMethod).label}';

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppRadius.card),
      shadowColor: AppColors.black.withValues(alpha: .06),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.push('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mã đơn + trạng thái
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.shortCode,
                      style: AppTypography.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.createdAt.toVnDateTimeOrDash,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Thumbnail các món (tối đa 4, dư thì +N)
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    for (final item in order.items.take(4)) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: AppNetworkImage(
                          item.productImageUrl,
                          width: 44,
                          height: 44,
                          background: AppColors.beigeWarm,
                          iconColor: AppColors.brownAccent,
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    if (order.items.length > 4)
                      Text(
                        '+${order.items.length - 4}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textHint),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Tóm tắt món
              Text(
                itemsSummary,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: AppSpacing.sm),

              // Loại đơn + thanh toán | tổng tiền
              Row(
                children: [
                  Expanded(
                    child: Text(
                      typeAndPayment,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    order.totalAmount.toVnd,
                    style: AppTypography.priceSmall.copyWith(
                      color: AppColors.brownAccent,
                    ),
                  ),
                ],
              ),

              // Đánh giá — chỉ đơn hoàn thành
              if (status == OrderStatus.delivered) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => ReviewSheet.show(context, order),
                    icon: const Icon(Icons.star_outline_rounded, size: 18),
                    label: const Text('Đánh giá'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldPrimary,
                      textStyle: AppTypography.buttonSmall,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── States ───────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    // ListView để RefreshIndicator vẫn kéo được khi rỗng.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Icon(
          Icons.receipt_long_outlined,
          size: 72,
          color: AppColors.textHint.withValues(alpha: .6),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Chưa có đơn hàng nào',
          textAlign: TextAlign.center,
          style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Đặt món đầu tiên và theo dõi đơn tại đây nhé!',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: FilledButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.local_cafe_outlined),
            label: const Text('Đặt hàng ngay'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textOnGold,
              textStyle: AppTypography.button,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownAccent,
                side: const BorderSide(color: AppColors.brownAccent),
                textStyle: AppTypography.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading — 4 card giả lập trong lúc chờ dữ liệu.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => Container(
        height: 120,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadow.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _bone(width: 120, height: 16),
                const Spacer(),
                _bone(width: 72, height: 20, radius: AppRadius.pill),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _bone(width: 90, height: 10),
            const SizedBox(height: AppSpacing.md),
            _bone(width: double.infinity, height: 12),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _bone(width: 110, height: 10),
                const Spacer(),
                _bone(width: 64, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bone({
    required double width,
    required double height,
    double radius = AppRadius.sm,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
