import 'dart:math' as math;

import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';

/// Ly cà phê "brewing tracker" (UC-19) — mức nước trong ly tăng theo
/// trạng thái đơn: rỗng → lớp bã → chất lỏng dâng lên → đầy + crema.
///
/// Vẽ thuần CustomPaint, không dùng asset/Lottie. Fill fraction chuyển mượt
/// bằng TweenAnimationBuilder; khi preparing có gợn sóng + giọt cà phê rơi.
class CoffeeCupProgress extends StatefulWidget {
  const CoffeeCupProgress({super.key, required this.status, this.size = 200});

  final OrderStatus status;
  final double size;

  @override
  State<CoffeeCupProgress> createState() => _CoffeeCupProgressState();
}

class _CoffeeCupProgressState extends State<CoffeeCupProgress>
    with SingleTickerProviderStateMixin {
  /// Chỉ chạy khi preparing: gợn sóng mặt chất lỏng + giọt cà phê nhỏ.
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  /// Mức fill trong ly theo trạng thái đơn.
  static double _fillFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0; // Ly rỗng — chờ quán xác nhận
      case OrderStatus.accepted:
        return .25; // Lớp "bã cà phê"
      case OrderStatus.preparing:
        return .7; // Chất lỏng dâng lên
      case OrderStatus.ready:
      case OrderStatus.delivered:
        return 1; // Đầy + crema
      case OrderStatus.cancelled:
        return 0;
    }
  }

  void _syncWave() {
    if (widget.status == OrderStatus.preparing) {
      if (!_wave.isAnimating) _wave.repeat();
    } else {
      _wave.stop();
      _wave.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncWave();
  }

  @override
  void didUpdateWidget(CoffeeCupProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) _syncWave();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _fillFor(widget.status)),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        builder: (context, fill, _) => CustomPaint(
          painter: _CoffeeCupPainter(
            fillFraction: fill,
            status: widget.status,
            wave: _wave,
          ),
        ),
      ),
    );
  }
}

class _CoffeeCupPainter extends CustomPainter {
  _CoffeeCupPainter({
    required this.fillFraction,
    required this.status,
    required Animation<double> wave,
  }) : _wave = wave,
       super(repaint: wave);

  final double fillFraction;
  final OrderStatus status;
  final Animation<double> _wave;

  /// Chiều cao lớp bã cà phê (fraction của lòng ly).
  static const _groundsLevel = .25;

  /// Vị trí chấm texture "bã" — (dx: fraction ngang đáy ly, dy: fraction dọc lớp bã).
  static const _dotSpots = [
    Offset(.2, .3),
    Offset(.38, .62),
    Offset(.55, .25),
    Offset(.72, .55),
    Offset(.85, .35),
    Offset(.28, .82),
    Offset(.62, .78),
    Offset(.47, .48),
  ];

  /// Vị trí ngang các giọt cà phê rơi (fraction chiều rộng miệng ly).
  static const _dropXs = [.35, .5, .66];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Backdrop tròn beige lớn
    canvas.drawCircle(center, w / 2, Paint()..color = AppColors.beigeLight);

    // Thân ly: hình thang hơi thon đáy, bo góc đáy
    final topW = w * .44;
    final cupH = h * .5;
    final botW = topW * .74;
    final top = h * .27;
    final bottom = top + cupH;
    final lt = center.dx - topW / 2;
    final rt = center.dx + topW / 2;
    final lb = center.dx - botW / 2;
    final rb = center.dx + botW / 2;
    final r = w * .045;

    final cup = Path()
      ..moveTo(lt, top)
      ..lineTo(lb, bottom - r)
      ..quadraticBezierTo(lb, bottom, lb + r, bottom)
      ..lineTo(rb - r, bottom)
      ..quadraticBezierTo(rb, bottom, rb, bottom - r)
      ..lineTo(rt, top)
      ..close();

    // Mức fill: 0 = đáy, 1 = sát miệng ly
    const inset = 4.0;
    final usableH = cupH - inset * 2;
    double levelY(double f) => bottom - inset - usableH * f;

    final liquidColor = Color.lerp(
      AppColors.brownAccent,
      AppColors.black,
      .25,
    )!;

    canvas.save();
    canvas.clipPath(cup);

    // ── Lớp bã cà phê (đáy ly) ──
    if (fillFraction > .01) {
      final groundsTop = levelY(math.min(fillFraction, _groundsLevel));
      canvas.drawRect(
        Rect.fromLTRB(lt, groundsTop, rt, bottom),
        Paint()..color = AppColors.brownAccent,
      );
      // Texture chấm tròn nhỏ
      if (fillFraction > .08) {
        for (var i = 0; i < _dotSpots.length; i++) {
          final s = _dotSpots[i];
          canvas.drawCircle(
            Offset(lb + s.dx * botW, groundsTop + s.dy * (bottom - groundsTop)),
            w * .012,
            Paint()
              ..color = i.isEven
                  ? AppColors.black.withValues(alpha: .18)
                  : AppColors.goldPrimary.withValues(alpha: .3),
          );
        }
      }
    }

    // ── Chất lỏng dâng trên lớp bã ──
    final liquidTop = levelY(fillFraction);
    if (fillFraction > _groundsLevel) {
      final groundsTop = levelY(_groundsLevel);
      final amp = status == OrderStatus.preparing ? h * .01 : 0.0;
      final phase = _wave.value * 2 * math.pi;
      double surfaceY(double x) =>
          liquidTop + amp * math.sin(phase + (x - lt) / topW * 4 * math.pi);

      final liquid = Path()..moveTo(lt, surfaceY(lt));
      for (var x = lt; x <= rt; x += 4) {
        liquid.lineTo(x, surfaceY(x));
      }
      liquid
        ..lineTo(rt, surfaceY(rt))
        ..lineTo(rt, groundsTop)
        ..lineTo(lt, groundsTop)
        ..close();
      canvas.drawPath(liquid, Paint()..color = liquidColor);
    }

    // ── Lớp crema mỏng trên mặt khi ready/delivered ──
    if ((status == OrderStatus.ready || status == OrderStatus.delivered) &&
        fillFraction > .85) {
      final alpha = ((fillFraction - .85) / .15).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTRB(lt, liquidTop, rt, liquidTop + usableH * .1),
        Paint()..color = AppColors.goldPrimary.withValues(alpha: alpha),
      );
    }

    // ── Giọt cà phê rơi khi đang pha chế ──
    if (status == OrderStatus.preparing) {
      for (var i = 0; i < _dropXs.length; i++) {
        final t = (_wave.value + i / _dropXs.length) % 1.0;
        final fall = Curves.easeIn.transform(t);
        canvas.drawCircle(
          Offset(
            lt + topW * _dropXs[i],
            top + 6 + (liquidTop - top - 12) * fall,
          ),
          w * .011,
          Paint()..color = liquidColor.withValues(alpha: (1 - t) * .9),
        );
      }
    }

    canvas.restore();

    // Viền ly
    canvas.drawPath(
      cup,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.brownAccent,
    );
  }

  @override
  bool shouldRepaint(_CoffeeCupPainter oldDelegate) =>
      oldDelegate.fillFraction != fillFraction || oldDelegate.status != status;
}
