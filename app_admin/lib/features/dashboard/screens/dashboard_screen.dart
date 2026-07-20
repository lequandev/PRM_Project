import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/admin_auth_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../marketing/providers/voucher_provider.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../../core/widgets/admin_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    final inventory = context.watch<InventoryProvider>();
    final vouchers = context.watch<VoucherProvider>();
    final analytics = context.watch<AnalyticsProvider>();
    final fmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome ───────────────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào mừng, ${auth.currentUser?.name ?? 'Admin'}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    const Text(
                      'Đây là tổng quan hoạt động hôm nay của Coffee Shop',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  DateFormat('EEEE, d MMMM y', 'vi_VN').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── KPI Cards ─────────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final cardWidth = isMobile ? double.infinity : (constraints.maxWidth - 48) / 4;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        title: 'Doanh thu hôm nay',
                        value: fmt.format(analytics.totalRevenue),
                        subtitle: '${analytics.deliveredOrders} đơn hoàn thành',
                        icon: Icons.payments_rounded,
                        color: AppColors.goldPrimary,
                        isLoading: analytics.isLoading,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        title: 'Tổng đơn hàng',
                        value: analytics.totalOrders.toString(),
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.success,
                        isLoading: analytics.isLoading,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        title: 'Nguyên liệu sắp hết',
                        value: inventory.lowStockCount.toString(),
                        subtitle: inventory.lowStockCount > 0
                            ? 'Cần bổ sung ngay!'
                            : 'Kho đang ổn',
                        icon: Icons.inventory_2_rounded,
                        color: inventory.lowStockCount > 0
                            ? AppColors.error
                            : AppColors.success,
                        isLoading: inventory.isLoading,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        title: 'Voucher đang hoạt động',
                        value: vouchers.activeVouchers.length.toString(),
                        icon: Icons.local_offer_rounded,
                        color: AppColors.brownAccent,
                        isLoading: vouchers.isLoading,
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 24),

            // ── Quick Actions ─────────────────────────────────────────────
            const Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brownAccent,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final itemW = isMobile
                    ? (constraints.maxWidth - 12) / 2
                    : (constraints.maxWidth - 36) / 4;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                      width: itemW,
                      icon: Icons.add_rounded,
                      label: 'Thêm sản phẩm',
                      color: AppColors.goldPrimary,
                      onTap: () => context.go('/products/new'),
                    ),
                    _QuickAction(
                      width: itemW,
                      icon: Icons.local_offer_rounded,
                      label: 'Tạo voucher',
                      color: AppColors.brownAccent,
                      onTap: () => context.go('/vouchers'),
                    ),
                    _QuickAction(
                      width: itemW,
                      icon: Icons.bar_chart_rounded,
                      label: 'Xem báo cáo',
                      color: AppColors.success,
                      onTap: () => context.go('/analytics/revenue'),
                    ),
                    _QuickAction(
                      width: itemW,
                      icon: Icons.rate_review_rounded,
                      label: 'Kiểm duyệt',
                      color: AppColors.statusPreparing,
                      onTap: () => context.go('/reviews'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Inventory Alert ───────────────────────────────────────────
            if (inventory.lowStockItems.isNotEmpty) ...[
              const Text(
                'Cảnh báo Kho hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownAccent,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: inventory.lowStockItems
                      .take(5)
                      .map((i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  i.isOutOfStock
                                      ? Icons.error_rounded
                                      : Icons.warning_amber_rounded,
                                  color: i.isOutOfStock
                                      ? AppColors.error
                                      : AppColors.warning,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        i.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${i.currentStock.toStringAsFixed(1)} ${i.unit} / Min: ${i.minStock.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          color: i.isOutOfStock
                                              ? AppColors.error
                                              : AppColors.warning,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.go('/inventory'),
                                  child: const Text('Cập nhật →',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Active Vouchers ───────────────────────────────────────────
            if (vouchers.activeVouchers.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Voucher đang hoạt động',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownAccent,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/vouchers'),
                    child: const Text('Xem tất cả →'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vouchers.activeVouchers.take(6).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final v = vouchers.activeVouchers[i];
                    return Container(
                      width: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.brownAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.discountType == 'percentage'
                                ? 'Giảm ${v.discountValue.toInt()}%'
                                : 'Giảm ${fmt.format(v.discountValue)}',
                            style: const TextStyle(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

