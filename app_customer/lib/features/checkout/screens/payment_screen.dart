import 'dart:async';

import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/order_repository.dart';
import '../../../data/payment_service.dart';

/// UC-16 — Thanh toán PayOS (chuyển khoản/VietQR).
///
/// Hiện QR để khách quét bằng app ngân hàng. Việc "đã thanh toán" được xác nhận
/// qua WEBHOOK (server → Firestore), app chỉ NGHE đơn của mình flip sang 'paid'
/// — không tin cái QR hay redirect (chống giả).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _payment = const PaymentService();

  String? _qrData;
  String? _error;
  bool _loading = true;
  bool _paid = false;
  StreamSubscription<OrderModel>? _sub;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final orderRepo = context.read<OrderRepository>();

    // 1) Tạo QR PayOS qua server.
    try {
      final result = await _payment.createPayment(
        orderId: widget.order.id,
        amount: widget.order.totalAmount,
        description: 'DH ${widget.order.id}',
      );
      if (!mounted) return;
      setState(() {
        _qrData = result.qrCode.isEmpty ? null : result.qrCode;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tạo được thanh toán. Kiểm tra kết nối và thử lại.';
        _loading = false;
      });
      return;
    }

    // 2) Nghe đơn → 'paid' (nguồn sự thật là webhook cập nhật Firestore).
    _sub = orderRepo.watchOrder(widget.order.id).listen((o) {
      if (!_paid &&
          PaymentStatus.fromString(o.paymentStatus) == PaymentStatus.paid) {
        _paid = true;
        if (mounted) context.pushReplacement('/checkout/success/${o.id}');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _confirmCancel() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hủy thanh toán?'),
        content: const Text(
          'Đơn vẫn được giữ ở trạng thái "chờ thanh toán". Bạn có thể thanh '
          'toán lại sau trong mục Đơn hàng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ở lại'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pushReplacement('/orders/${widget.order.id}');
            },
            child: const Text('Thoát, để sau'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Thanh toán'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmCancel,
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrimary),
      );
    }
    if (_error != null || _qrData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error ?? 'Không lấy được mã thanh toán.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary),
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _start();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            children: [
              Text('Quét mã để thanh toán',
                  style: AppTypography.h3
                      .copyWith(color: AppColors.brownAccent)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Mở app ngân hàng → quét VietQR bên dưới',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: QrImageView(
                  data: _qrData!,
                  size: 220,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.brownAccent,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.brownAccent,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Số tiền', style: AppTypography.caption),
              Text(widget.order.totalAmount.toVnd, style: AppTypography.price),
              const SizedBox(height: AppSpacing.xs),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.order.totalAmount.round().toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã copy số tiền')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy số tiền'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Trạng thái chờ — tự chuyển khi webhook cập nhật đơn.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.goldPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Đang chờ thanh toán…',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Màn hình tự chuyển khi hệ thống nhận được tiền.',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}
