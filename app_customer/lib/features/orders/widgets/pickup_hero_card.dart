import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';

import 'coffee_cup_progress.dart';

/// Hero card cho đơn PICKUP (UC-19) — phong cách "coffee brewing tracker":
/// ly cà phê đầy dần theo trạng thái, title/subtitle đổi mượt và
/// stepper ngang 4 bước (Đã nhận / Xác nhận / Pha chế / Sẵn sàng).
class PickupHeroCard extends StatelessWidget {
  const PickupHeroCard({super.key, required this.order});

  final OrderModel order;

  static (String, String) _heroTexts(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return ('Đã nhận đơn', 'Đơn của bạn đang trong hàng đợi');
      case OrderStatus.accepted:
        return ('Đã xác nhận', 'Quán bắt đầu chuẩn bị món cho bạn');
      case OrderStatus.preparing:
        return ('Đang pha chế', 'Đang pha những ly ngon nhất cho bạn');
      case OrderStatus.ready:
        return ('Sẵn sàng lấy!', 'Cà phê của bạn đã xong — qua quầy nhé!');
      case OrderStatus.delivered:
        return ('Đã lấy hàng', 'Cảm ơn bạn, hẹn gặp lại ☕');
      case OrderStatus.cancelled:
        // Không xảy ra — đơn hủy dùng card hủy riêng ở screen.
        return ('Đã hủy', '');
    }
  }

  /// Tóm tắt món gọn: "1x Trà đào cam sả — size M · +1 món khác".
  String get _itemsSummary {
    if (order.items.isEmpty) return '';
    final first = order.items.first;
    final size = first.customizations['size'];
    final buffer = StringBuffer('${first.quantity}x ${first.productName}');
    if (size != null) buffer.write(' — size $size');
    final more = order.items.length - 1;
    if (more > 0) buffer.write(' · +$more món khác');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus;
    final (title, subtitle) = _heroTexts(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          CoffeeCupProgress(status: status, size: 190),
          const SizedBox(height: AppSpacing.sm),
          if (_itemsSummary.isNotEmpty)
            Text(
              _itemsSummary,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          // Title + subtitle đổi theo status: fade + slide nhẹ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .12),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey(status),
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownAccent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _HorizontalStepper(status: status),
        ],
      ),
    );
  }
}

// ─────────────────────── Stepper ngang 4 bước ───────────────────────

enum _StepState { done, current, upcoming }

class _HorizontalStepper extends StatelessWidget {
  const _HorizontalStepper({required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
  ];
  static const _labels = ['Đã nhận', 'Xác nhận', 'Pha chế', 'Sẵn sàng'];

  /// delivered → coi như hoàn thành cả 4 bước.
  int get _currentIndex {
    if (status == OrderStatus.delivered) return _steps.length;
    final i = _steps.indexOf(status);
    return i < 0 ? 0 : i;
  }

  _StepState _stateFor(int i) {
    if (i < _currentIndex) return _StepState.done;
    if (i == _currentIndex) return _StepState.current;
    return _StepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Đường nối giữa TÂM các ô (4 ô đều nhau → flex 1-2-2-2-1),
        // nằm ngang tâm chấm (cao 32 → top 16).
        Positioned(
          left: 0,
          right: 0,
          top: 16 - 1.5,
          child: Row(
            children: [
              const Spacer(),
              for (var i = 0; i < _steps.length - 1; i++)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i < _currentIndex
                          ? AppColors.goldPrimary
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(child: _StepDot(state: _stateFor(i))),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _labels[i],
                      textAlign: TextAlign.center,
                      style: _stateFor(i) == _StepState.upcoming
                          ? AppTypography.label.copyWith(
                              color: AppColors.textHint,
                            )
                          : AppTypography.label.copyWith(
                              color: AppColors.brownAccent,
                              fontWeight: FontWeight.w700,
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.done:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.goldPrimary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.white,
          ),
        );
      case _StepState.current:
        return const _StepPingDot();
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

/// Chấm vàng bước hiện tại — tái dùng pattern "radar ping" của timeline dọc.
class _StepPingDot extends StatefulWidget {
  const _StepPingDot();

  @override
  State<_StepPingDot> createState() => _StepPingDotState();
}

class _StepPingDotState extends State<_StepPingDot>
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
