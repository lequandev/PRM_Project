import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isPrinting = false;

  void _showCancelDialog(BuildContext context, OrderModel order) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập lý do hủy đơn hàng này:'),
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
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận hủy', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _printReceipt(BuildContext context, OrderModel order) async {
    setState(() {
      _isPrinting = true;
    });

    final success = await context.read<StaffOrderProvider>().mockPrintReceipt(order);

    setState(() {
      _isPrinting = false;
    });

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: AppColors.success),
              SizedBox(width: 8),
              Text('Đã in hóa đơn'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đã gửi lệnh in hóa đơn cho Đơn #:${order.id.substring(order.id.length - 5).toUpperCase()}'),
              const SizedBox(height: AppSpacing.md),
              const Center(
                child: Icon(Icons.print_outlined, size: 64, color: AppColors.goldPrimary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<StaffOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('CHI TIẾT ĐƠN HÀNG'),
      ),
      body: Stack(
        children: [
          FutureBuilder<OrderModel?>(
            future: orderProvider.getOrderDetails(widget.orderId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Không tìm thấy thông tin đơn hàng.', style: AppTypography.h4),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                );
              }

              final order = snapshot.data!;
              final shortId = order.id.length > 5 ? order.id.substring(order.id.length - 5).toUpperCase() : order.id.toUpperCase();
              final isDelivery = order.orderType == OrderType.delivery.name;
              final currentStatus = OrderStatus.fromString(order.status);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header Card
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mã đơn hàng: #$shortId', style: AppTypography.h3),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Đặt lúc: ${order.createdAt?.toVnDate ?? "Không rõ"} ${order.createdAt != null ? TimeOfDay.fromDateTime(order.createdAt!).format(context) : ""}',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.forOrderStatus(order.status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Text(
                                    currentStatus.label.toUpperCase(),
                                    style: AppTypography.button.copyWith(
                                      color: AppColors.forOrderStatus(order.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (order.status == OrderStatus.cancelled.name && order.cancelReason != null) ...[
                              const Divider(height: AppSpacing.md),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Lý do hủy: ${order.cancelReason}',
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Customer Details
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Thông tin khách hàng', style: AppTypography.h4.copyWith(color: AppColors.brownAccent)),
                            const Divider(height: AppSpacing.md),
                            _buildInfoRow(Icons.person_outline, 'Họ và tên', order.customerName),
                            if (order.customerPhone != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', order.customerPhone!),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            _buildInfoRow(
                              Icons.local_shipping_outlined,
                              'Hình thức nhận hàng',
                              isDelivery ? 'Giao hàng tận nơi' : 'Tự đến lấy (Mang về)',
                            ),
                            if (isDelivery && order.deliveryAddress != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              _buildInfoRow(
                                Icons.location_on_outlined,
                                'Địa chỉ giao hàng',
                                '${order.deliveryAddress!['street']}, ${order.deliveryAddress!['ward']}, ${order.deliveryAddress!['district']}, ${order.deliveryAddress!['city']}',
                              ),
                            ],
                            if (order.note != null && order.note!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note_alt_outlined, color: AppColors.warning),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ghi chú của khách:',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(order.note!, style: AppTypography.bodyMedium.copyWith(color: AppColors.warning)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Items List
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chi tiết món ăn', style: AppTypography.h4.copyWith(color: AppColors.brownAccent)),
                            const Divider(height: AppSpacing.md),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                final customText = item.customizations.entries
                                    .map((e) => '${e.key.toUpperCase()}: ${e.value}')
                                    .join(' | ');

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.beigeWarm,
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                        ),
                                        child: Text(
                                          '${item.quantity}x',
                                          style: AppTypography.bodyLarge.copyWith(
                                            color: AppColors.brownAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.productName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                            if (customText.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(customText, style: AppTypography.bodySmall),
                                            ],
                                            if (item.note != null && item.note!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text('Ghi chú: ${item.note}', style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic)),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Text(item.totalPrice.toVnd, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Payment & Bill Summary
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Thanh toán', style: AppTypography.h4.copyWith(color: AppColors.brownAccent)),
                            const Divider(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Phương thức thanh toán'),
                                Text(
                                  PaymentMethod.fromString(order.paymentMethod).label,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Trạng thái thanh toán'),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: order.paymentStatus == 'paid'
                                        ? AppColors.success.withOpacity(0.15)
                                        : AppColors.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    order.paymentStatus == 'paid' ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN',
                                    style: AppTypography.caption.copyWith(
                                      color: order.paymentStatus == 'paid' ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: AppSpacing.md),
                            _buildPriceRow('Tạm tính', order.subtotal.toVnd),
                            if (order.discountAmount > 0) ...[
                              const SizedBox(height: AppSpacing.xs),
                              _buildPriceRow('Mã giảm giá', '- ${order.discountAmount.toVnd}', isDiscount: true),
                            ],
                            if (order.loyaltyPointsUsed > 0) ...[
                              const SizedBox(height: AppSpacing.xs),
                              _buildPriceRow('Điểm Loyalty đổi', '- ${(order.loyaltyPointsUsed * 1000.0).toVnd}', isDiscount: true), // Giả định 1 điểm = 1000đ
                            ],
                            const Divider(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tổng cộng', style: AppTypography.h3.copyWith(color: AppColors.brownAccent)),
                                Text(order.totalAmount.toVnd, style: AppTypography.price.copyWith(color: AppColors.goldPrimary, fontSize: 20)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Action Controls at the bottom
                    _buildStatusControls(context, order, orderProvider),
                  ],
                ),
              );
            },
          ),
          if (_isPrinting)
            Container(
              color: AppColors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary)),
                        SizedBox(height: AppSpacing.md),
                        Text('Đang in hóa đơn...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? AppColors.error : AppColors.textPrimary,
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusControls(BuildContext context, OrderModel order, StaffOrderProvider provider) {
    final status = OrderStatus.fromString(order.status);
    
    // Nếu đơn hàng đã giao hoặc đã hủy, không hiển thị các nút đổi trạng thái nữa
    if (status.isTerminal) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              onPressed: () => _printReceipt(context, order),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.print_outlined),
                  SizedBox(width: 8),
                  Text('In lại hóa đơn'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            // Print invoice is always available for active orders
            Expanded(
              child: OutlinedButton(
                onPressed: () => _printReceipt(context, order),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.print_outlined),
                    SizedBox(width: 8),
                    Text('In hóa đơn'),
                  ],
                ),
              ),
            ),
            if (status == OrderStatus.pending) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showCancelDialog(context, order),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Từ chối', style: TextStyle(color: AppColors.white)),
                ),
              ),
            ] else if (status != OrderStatus.ready) ...[
              // active but not pending, and not ready (e.g. accepted, preparing)
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showCancelDialog(context, order),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Hủy đơn', style: TextStyle(color: AppColors.white)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _buildPrimaryActionButton(context, order, provider),
        ),
      ],
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context, OrderModel order, StaffOrderProvider provider) {
    final status = OrderStatus.fromString(order.status);
    
    switch (status) {
      case OrderStatus.pending:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.acceptOrder(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã nhận đơn hàng')),
              );
              setState(() {});
            }
          },
          child: const Text('CHẤP NHẬN ĐƠN HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
        );
      case OrderStatus.accepted:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.startPreparing(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật: Đang pha chế')),
              );
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAccepted),
          child: const Text('BẮT ĐẦU PHA CHẾ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        );
      case OrderStatus.preparing:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.markReady(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật: Sẵn sàng lấy hàng')),
              );
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusPreparing),
          child: const Text('HOÀN THÀNH PHA CHẾ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        );
      case OrderStatus.ready:
        return ElevatedButton(
          onPressed: () async {
            final success = await provider.completeOrder(order.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã giao đơn hàng thành công')),
              );
              context.pop();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusReady),
          child: const Text('XÁC NHẬN BÀN GIAO ĐƠN', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
