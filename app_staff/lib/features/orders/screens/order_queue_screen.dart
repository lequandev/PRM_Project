import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_order_provider.dart';

class OrderQueueScreen extends StatefulWidget {
  const OrderQueueScreen({super.key});

  @override
  State<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends State<OrderQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<StaffOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HÀNG ĐỢI ĐƠN HÀNG'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.goldPrimary,
          labelStyle: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chờ duyệt'),
                  if (orderProvider.pendingOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Badge(
                      label: Text(orderProvider.pendingOrders.length.toString()),
                      backgroundColor: AppColors.statusPending,
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đang làm'),
                  if (orderProvider.preparingOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Badge(
                      label: Text(orderProvider.preparingOrders.length.toString()),
                      backgroundColor: AppColors.statusPreparing,
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sẵn sàng'),
                  if (orderProvider.readyOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Badge(
                      label: Text(orderProvider.readyOrders.length.toString()),
                      backgroundColor: AppColors.statusReady,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
              ),
            )
          : orderProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: AppSpacing.md),
                      Text(orderProvider.errorMessage!, style: AppTypography.h4),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _OrderListTab(orders: orderProvider.pendingOrders, tabIndex: 0),
                    _OrderListTab(orders: orderProvider.preparingOrders, tabIndex: 1),
                    _OrderListTab(orders: orderProvider.readyOrders, tabIndex: 2),
                  ],
                ),
    );
  }
}

class _OrderListTab extends StatelessWidget {
  final List<OrderModel> orders;
  final int tabIndex;

  const _OrderListTab({required this.orders, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tabIndex == 0
                  ? Icons.all_inbox_rounded
                  : tabIndex == 1
                      ? Icons.coffee_maker_outlined
                      : Icons.celebration_outlined,
              size: 72,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              tabIndex == 0
                  ? 'Không có đơn hàng chờ xác nhận'
                  : tabIndex == 1
                      ? 'Không có đơn nào đang pha chế'
                      : 'Không có đơn nào sẵn sàng lấy',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;

        if (crossAxisCount > 1) {
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.35,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _OrderCard(order: orders[index]);
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _OrderCard(order: orders[index]);
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  void _showCancelDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng chọn hoặc nhập lý do hủy đơn:'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do hủy...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do hủy đơn')),
                );
                return;
              }
              Navigator.pop(ctx);
              final success = await context.read<StaffOrderProvider>().cancelOrder(order.id, reason);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy đơn hàng thành công')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận hủy', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<StaffOrderProvider>();
    final shortId = order.id.length > 5 ? order.id.substring(order.id.length - 5).toUpperCase() : order.id.toUpperCase();
    final timeAgo = order.createdAt != null ? order.createdAt!.timeAgo : 'Vừa xong';
    final isDelivery = order.orderType == OrderType.delivery.name;

    return Card(
      elevation: 3,
      shadowColor: AppColors.black.withOpacity(0.08),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID + Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'ĐƠN #$shortId',
                        style: AppTypography.h4.copyWith(color: AppColors.brownAccent),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDelivery
                              ? AppColors.success.withOpacity(0.15)
                              : AppColors.goldPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          isDelivery ? 'GIAO HÀNG' : 'MANG VỀ',
                          style: AppTypography.caption.copyWith(
                            color: isDelivery ? AppColors.success : AppColors.goldPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timeAgo,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.md),

              // Customer Info
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    order.customerName,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (order.customerPhone != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      order.customerPhone!,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Items Summary
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length > 2 ? 2 : order.items.length,
                  itemBuilder: (context, idx) {
                    final item = order.items[idx];
                    final customizationText = item.customizations.entries
                        .map((e) => '${e.value}')
                        .join(', ');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        '${item.quantity}x ${item.productName}${customizationText.isNotEmpty ? ' ($customizationText)' : ''}',
                        style: AppTypography.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              if (order.items.length > 2)
                Text(
                  '... và ${order.items.length - 2} món khác',
                  style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                ),
              
              // Note
              if (order.note != null && order.note!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.note!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),

              // Footer: Total & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.totalAmount.toVnd,
                    style: AppTypography.price.copyWith(color: AppColors.goldPrimary, fontSize: 16),
                  ),
                  _buildActions(context, orderProvider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, StaffOrderProvider provider) {
    switch (OrderStatus.fromString(order.status)) {
      case OrderStatus.pending:
        return Row(
          children: [
            OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Từ chối'),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: () async {
                final success = await provider.acceptOrder(order.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã chấp nhận đơn hàng')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Chấp nhận'),
            ),
          ],
        );
      case OrderStatus.accepted:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.startPreparing(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bắt đầu pha chế đơn hàng')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusAccepted,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          child: const Text('Pha chế', style: TextStyle(color: AppColors.white)),
        );
      case OrderStatus.preparing:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.markReady(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đơn hàng đã sẵn sàng bàn giao')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusPreparing,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          child: const Text('Xong', style: TextStyle(color: AppColors.white)),
        );
      case OrderStatus.ready:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.completeOrder(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bàn giao đơn hàng thành công')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusReady,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          child: const Text('Bàn giao', style: TextStyle(color: AppColors.white)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
