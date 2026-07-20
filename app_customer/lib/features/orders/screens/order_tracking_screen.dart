import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/order_repository.dart';
import '../providers/order_tracking_provider.dart';
import '../widgets/pickup_hero_card.dart';
import '../widgets/pickup_pass_sheet.dart';
import '../widgets/status_chip.dart';

/// UC-19 — Theo dõi đơn hàng realtime.
/// - Đơn PICKUP (chưa hủy): hero "coffee brewing tracker" — ly cà phê đầy dần
///   theo trạng thái + stepper ngang + nút hiện mã QR nhận hàng.
/// - Đơn DELIVERY hoặc đã hủy: giữ timeline dọc / card hủy như cũ.
/// Stream từ repository tự đẩy trạng thái mới (~8s/bước ở chế độ demo).
class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          OrderTrackingProvider(context.read<OrderRepository>(), orderId),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  /// Back an toàn: còn stack thì pop; vào thẳng từ màn success (stack đã bị
  /// pushReplacement) thì về lịch sử đơn — KHÔNG bao giờ để back thoát app.
  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderTrackingProvider>();
    final order = provider.order;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(context);
      },
      child: Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Theo dõi đơn hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _back(context),
        ),
      ),
      body: () {
        if (order == null && provider.error != null) {
          return _ErrorState(message: provider.error!);
        }
        if (order == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.goldPrimary),
          );
        }
        // Hero "brewing tracker" chỉ dành cho đơn pickup chưa hủy;
        // delivery / cancelled giữ nguyên giao diện cũ.
        final isPickup =
            OrderType.fromString(order.orderType) == OrderType.pickup;
        final usePickupHero =
            isPickup && order.orderStatus != OrderStatus.cancelled;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _HeaderCard(order: order),
                  const SizedBox(height: AppSpacing.md),
                  if (order.orderStatus == OrderStatus.cancelled)
                    _CancelledCard(order: order)
                  else if (usePickupHero)
                    PickupHeroCard(order: order)
                  else
                    _TimelineCard(order: order),
                  const SizedBox(height: AppSpacing.md),
                  _DetailCard(order: order),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            if (usePickupHero)
              _PickupActionBar(provider: provider, order: order)
            else if (order.orderStatus.canCustomerCancel)
              _CancelBar(provider: provider),
          ],
        );
      }(),
      ),
    );
  }
}

// ─────────────────────────── Header ───────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isLive = !order.orderStatus.isTerminal;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: AppTypography.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(order.orderStatus),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Đặt lúc ${order.createdAt.toVnDateTimeOrDash}',
            style: AppTypography.caption.copyWith(color: AppColors.textHint),
          ),
          if (isLive) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _BlinkingDot(),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Đang cập nhật trực tiếp',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chấm xanh nhấp nháy của badge "trực tiếp".
class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: .35,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────── Timeline ───────────────────────────

enum _StepState { done, current, upcoming }

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.order});

  final OrderModel order;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.delivered,
  ];

  String _labelFor(OrderStatus step) {
    final isPickup = OrderType.fromString(order.orderType) == OrderType.pickup;
    if (isPickup && step == OrderStatus.delivered) return 'Đã lấy hàng';
    if (!isPickup && step == OrderStatus.ready) return 'Sẵn sàng giao';
    return step.label;
  }

  DateTime? _timeFor(OrderStatus step) {
    switch (step) {
      case OrderStatus.pending:
        return order.createdAt;
      case OrderStatus.accepted:
        return order.acceptedAt;
      case OrderStatus.ready:
        return order.readyAt;
      case OrderStatus.delivered:
        return order.deliveredAt;
      case OrderStatus.preparing:
      case OrderStatus.cancelled:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(order.orderStatus);
    final isDeliveredAll = order.orderStatus == OrderStatus.delivered;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiến trình đơn hàng', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < _steps.length; i++)
            _TimelineRow(
              label: _labelFor(_steps[i]),
              time: _timeFor(_steps[i]),
              state: () {
                if (i < currentIndex || (i == currentIndex && isDeliveredAll)) {
                  return _StepState.done;
                }
                if (i == currentIndex) return _StepState.current;
                return _StepState.upcoming;
              }(),
              isLast: i == _steps.length - 1,
              lineDone: i < currentIndex,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.time,
    required this.state,
    required this.isLast,
    required this.lineDone,
  });

  final String label;
  final DateTime? time;
  final _StepState state;
  final bool isLast;

  /// Đường nối dưới chấm này đã "đi qua" chưa (đổi màu success).
  final bool lineDone;

  String? get _timeText {
    final t = time;
    if (t == null) return null;
    return t.isToday ? t.toTime : t.toVnDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = switch (state) {
      _StepState.done => AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      _StepState.current => AppTypography.bodyLarge.copyWith(
        color: AppColors.brownAccent,
        fontWeight: FontWeight.w700,
      ),
      _StepState.upcoming => AppTypography.bodyMedium.copyWith(
        color: AppColors.textHint,
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột chấm + đường nối
        Column(
          children: [
            SizedBox(width: 32, height: 32, child: Center(child: _buildDot())),
            if (!isLast)
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: lineDone ? AppColors.success : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),

        // Nhãn + timestamp
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label, style: labelStyle)),
                if (_timeText != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      _timeText!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot() {
    switch (state) {
      case _StepState.done:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.white,
          ),
        );
      case _StepState.current:
        return const _PulsingDot();
      case _StepState.upcoming:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight, width: 2.5),
          ),
        );
    }
  }
}

/// Chấm vàng của bước hiện tại — hiệu ứng "radar ping" lan tỏa.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_controller.value);
        return SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vòng lan tỏa
              Container(
                width: 16 + 16 * t,
                height: 16 + 16 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldPrimary.withValues(alpha: .35 * (1 - t)),
                ),
              ),
              // Lõi vàng
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldLight, width: 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Cancelled ───────────────────────────

class _CancelledCard extends StatelessWidget {
  const _CancelledCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.error.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn đã hủy',
                  style: AppTypography.h4.copyWith(color: AppColors.error),
                ),
                if (order.cancelReason != null &&
                    order.cancelReason!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Lý do: ${order.cancelReason}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Chi tiết đơn ───────────────────────────

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.order});

  final OrderModel order;

  static String _paymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Chưa thanh toán';
      case PaymentStatus.paid:
        return 'Đã thanh toán';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }

  static String _customizationsText(Map<String, String> customizations) =>
      customizations.entries.map((e) => '${e.key} ${e.value}').join(' · ');

  String? get _addressText {
    final addr = order.deliveryAddress;
    if (addr == null) return null;
    return [
      addr['street'],
      addr['ward'],
      addr['district'],
      addr['city'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final paymentStatus = PaymentStatus.fromString(order.paymentStatus);
    final isDelivery =
        OrderType.fromString(order.orderType) == OrderType.delivery;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chi tiết đơn hàng', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),

          // Danh sách món
          for (final item in order.items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}x',
                    style: AppTypography.priceSmall.copyWith(
                      color: AppColors.goldPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
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
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Ghi chú: ${item.note}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(item.totalPrice.toVnd, style: AppTypography.priceSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          const Divider(height: AppSpacing.lg, color: AppColors.borderLight),

          // Tổng kết tiền
          _SummaryRow(label: 'Tạm tính', value: order.subtotal.toVnd),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              label: order.voucherCode != null
                  ? 'Giảm giá (${order.voucherCode})'
                  : 'Giảm giá',
              value: '-${order.discountAmount.toVnd}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Expanded(child: Text('Tổng cộng', style: AppTypography.h4)),
              Text(
                order.totalAmount.toVnd,
                style: AppTypography.price.copyWith(
                  color: AppColors.brownAccent,
                ),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg, color: AppColors.borderLight),

          // Thanh toán
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  PaymentMethod.fromString(order.paymentMethod).label,
                  style: AppTypography.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: switch (paymentStatus) {
                    PaymentStatus.paid => AppColors.successLight,
                    PaymentStatus.pending => AppColors.warningLight,
                    PaymentStatus.refunded => AppColors.backgroundAlt,
                  },
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  _paymentStatusLabel(paymentStatus),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: switch (paymentStatus) {
                      PaymentStatus.paid => AppColors.success,
                      PaymentStatus.pending => AppColors.warning,
                      PaymentStatus.refunded => AppColors.textSecondary,
                    },
                  ),
                ),
              ),
            ],
          ),

          // Địa chỉ giao (chỉ delivery)
          if (isDelivery && _addressText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giao đến',
                        style: AppTypography.label.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(_addressText!, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Ghi chú đơn
          if (order.note != null && order.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sticky_note_2_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    order.note!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.priceSmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Hủy đơn ───────────────────────────

/// Dialog xác nhận hủy (bắt buộc nhập lý do) — dùng chung cho cả
/// [_CancelBar] (delivery) và [_PickupActionBar] (pickup hero).
Future<void> _confirmCancelOrder(
  BuildContext context,
  OrderTrackingProvider provider,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final controller = TextEditingController();

  final reason = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      String? errorText;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: const Text('Hủy đơn hàng?', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn chưa được quán xác nhận nên có thể hủy. '
                'Vui lòng cho quán biết lý do:',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Lý do hủy (bắt buộc)',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  errorText: errorText,
                  filled: true,
                  fillColor: AppColors.backgroundAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Đóng'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  setState(() => errorText = 'Vui lòng nhập lý do hủy');
                  return;
                }
                Navigator.of(dialogContext).pop(text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Hủy đơn'),
            ),
          ],
        ),
      );
    },
  );

  if (reason == null) return;

  final success = await provider.cancelOrder(reason);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        success
            ? 'Đã hủy đơn hàng.'
            : (provider.cancelError ?? 'Không thể hủy đơn. Thử lại sau.'),
      ),
      backgroundColor: success ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _CancelBar extends StatelessWidget {
  const _CancelBar({required this.provider});

  final OrderTrackingProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: provider.isCancelling
                  ? null
                  : () => _confirmCancelOrder(context, provider),
              icon: provider.isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(Icons.close_rounded, size: 20),
              label: Text(provider.isCancelling ? 'Đang hủy...' : 'Hủy đơn'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                textStyle: AppTypography.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────── Bottom action bar (pickup hero) ──────────────────

/// Khu vực hành động dưới cùng cho đơn pickup:
/// - pending/accepted/preparing: progress "đang chuẩn bị" + % (kèm nút
///   Hủy đơn nhỏ khi còn được phép hủy);
/// - ready: nút full-width hiện mã QR nhận hàng;
/// - delivered: xác nhận đã lấy + xem lại mã.
class _PickupActionBar extends StatelessWidget {
  const _PickupActionBar({required this.provider, required this.order});

  final OrderTrackingProvider provider;
  final OrderModel order;

  /// Progress đích của thanh "đang chuẩn bị" theo trạng thái.
  static double _progressFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return .15;
      case OrderStatus.accepted:
        return .5;
      case OrderStatus.preparing:
        return .85;
      case OrderStatus.ready:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus;
    final Widget child;
    if (status == OrderStatus.ready) {
      child = _buildReadyButton(context);
    } else if (status == OrderStatus.delivered) {
      child = _buildDeliveredRow(context);
    } else {
      child = _buildProgressCard(context);
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Column(
      key: const ValueKey('progress'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đang chuẩn bị đơn của bạn...',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Interpolate mượt về progress đích (0.15 / 0.5 / 0.85) trong 2s
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _progressFor(order.orderStatus)),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, value, _) => Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: AppColors.goldPrimary,
                    backgroundColor: AppColors.borderLight,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 42,
                child: Text(
                  '${(value * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: AppTypography.priceSmall.copyWith(
                    color: AppColors.brownAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (order.orderStatus.canCustomerCancel) ...[
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton(
              onPressed: provider.isCancelling
                  ? null
                  : () => _confirmCancelOrder(context, provider),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: AppTypography.buttonSmall,
              ),
              child: Text(provider.isCancelling ? 'Đang hủy...' : 'Hủy đơn'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadyButton(BuildContext context) {
    return SizedBox(
      key: const ValueKey('ready'),
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => showPickupPassSheet(context, order),
        icon: const Icon(Icons.qr_code_rounded, size: 22),
        label: const Text('Hiện mã nhận hàng'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.textOnGold,
          elevation: 0,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveredRow(BuildContext context) {
    return Column(
      key: const ValueKey('delivered'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'Đã lấy hàng — cảm ơn bạn!',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => showPickupPassSheet(context, order),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brownAccent,
            textStyle: AppTypography.buttonSmall,
          ),
          child: const Text('Xem lại mã'),
        ),
      ],
    );
  }
}

// ─────────────────────────── Error ───────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textHint,
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
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownAccent,
                side: const BorderSide(color: AppColors.brownAccent),
                textStyle: AppTypography.button,
              ),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
