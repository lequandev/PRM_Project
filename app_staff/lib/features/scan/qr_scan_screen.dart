import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../orders/providers/staff_order_provider.dart';

/// UC-24 — Nhân viên quét mã QR (chứa order.id) của khách để tra đơn và bàn giao.
///
/// Mã QR bên app khách chỉ chứa order.id trần (xem pickup_pass_sheet). Quét xong
/// → tra đơn qua [StaffOrderProvider.getOrderDetails] → hiện tóm tắt → xác nhận
/// bàn giao (→ [StaffOrderProvider.completeOrder], set trạng thái delivered).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  // autoStart mặc định true → MobileScanner tự start/stop theo lifecycle.
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // Chặn xử lý trùng khi đang tra đơn / mở sheet.
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    final orderId = raw?.trim();
    if (orderId == null || orderId.isEmpty) return;

    setState(() => _handling = true);

    final provider = context.read<StaffOrderProvider>();
    final order = await provider.getOrderDetails(orderId);
    if (!mounted) return;

    if (order == null) {
      _snack('Không tìm thấy đơn: $orderId', AppColors.error);
      setState(() => _handling = false);
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _ScannedOrderSheet(order: order),
    );
    if (!mounted) return;

    if (confirmed == true) {
      final ok = await provider.completeOrder(order.id);
      if (!mounted) return;
      if (ok) {
        _snack('Đã bàn giao đơn #${_short(order.id)}', AppColors.success);
        context.pop(); // đóng màn quét, về hàng đợi
        return;
      }
      _snack('Cập nhật thất bại, thử lại', AppColors.error);
    }
    // Hủy / lỗi → cho quét tiếp.
    setState(() => _handling = false);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _short(String id) => id.length > 5
      ? id.substring(id.length - 5).toUpperCase()
      : id.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Quét mã nhận hàng'),
        actions: [
          IconButton(
            tooltip: 'Đèn flash',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Khung ngắm giữa màn hình.
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white, width: 3),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          if (_handling)
            const ColoredBox(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              'Đưa mã QR của khách vào khung để tra đơn',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tóm tắt đơn sau khi quét — trả về `true` nếu nhân viên xác nhận bàn giao.
class _ScannedOrderSheet extends StatelessWidget {
  const _ScannedOrderSheet({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromString(order.status);
    final isReady = status == OrderStatus.ready;
    final isDone = status == OrderStatus.delivered;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Đơn ${order.id}', style: AppTypography.h4),
                ),
                Text(
                  order.totalAmount.toVnd,
                  style: AppTypography.price.copyWith(
                    color: AppColors.goldPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Khách: ${order.customerName}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (isDone)
              _banner(
                'Đơn này đã được bàn giao trước đó',
                AppColors.textSecondary,
                Icons.check_circle_outline,
              )
            else if (!isReady)
              _banner(
                'Đơn chưa ở trạng thái "Sẵn sàng" (đang: ${status.label})',
                AppColors.warning,
                Icons.warning_amber_rounded,
              ),

            const Divider(height: AppSpacing.lg, color: AppColors.borderLight),

            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    _thumb(item.productImageUrl),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.productName}',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Quét tiếp'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isDone ? null : () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusReady,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Xác nhận bàn giao'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Thumbnail nhỏ cho món trong sheet đã quét (sheet tạm thời nên dùng
  /// Image.network gọn, không cần cache như app khách).
  Widget _thumb(String? url) {
    const size = 40.0;
    final fallback = Container(
      width: size,
      height: size,
      color: AppColors.beigeWarm,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe_outlined,
        size: 20,
        color: AppColors.brownAccent,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: (url == null || url.isEmpty)
          ? fallback
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }

  Widget _banner(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
