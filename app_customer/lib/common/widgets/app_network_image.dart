import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';

/// Ảnh mạng có CACHE (RAM + ổ đĩa) — drop-in thay cho `Image.network`.
///
/// Hai chốt chống "tải lại khi cuộn":
/// 1) Dùng `Image(image: ...Provider)` (KHÔNG dùng widget `CachedNetworkImage`)
///    → khi ảnh đã ở ImageCache thì render ĐỒNG BỘ tức thì, không nháy placeholder.
/// 2) `ResizeImage` giải mã ảnh ĐÚNG CỠ HIỂN THỊ (vd 200px thay vì 1000px gốc)
///    → mỗi ảnh nhẹ RAM ~20-30 lần → cache 200MB giữ được cả menu, không bị đẩy
///    ra → cuộn xuống rồi lên lại KHÔNG phải decode lại.
/// Cache đĩa vẫn còn (sống qua restart). Fallback icon khi URL rỗng/lỗi.
///
/// Dùng chung cho mọi feature (menu/cart của Dev 2, orders của Dev 3...).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.icon = Icons.coffee,
    this.background,
    this.iconColor,
    this.iconSize,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Icon fallback khi URL rỗng / ảnh lỗi.
  final IconData icon;

  /// Màu nền + màu/cỡ icon fallback (mặc định: borderLight + textHint).
  final Color? background;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: background ?? AppColors.borderLight,
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor ?? AppColors.textHint, size: iconSize),
    );
    if (url == null || url!.isEmpty) return fallback;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        // Cỡ hiển thị thực: ưu tiên width truyền vào, rồi tới ràng buộc layout,
        // cuối cùng là bề ngang màn hình (cho ảnh full-width).
        final logicalW = (width != null && width!.isFinite)
            ? width!
            : (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width);
        final cacheW = (logicalW * dpr).round().clamp(1, 4096);

        return Image(
          image: ResizeImage(
            CachedNetworkImageProvider(url!),
            width: cacheW,
            allowUpscaling: false,
          ),
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          // Cache hit → wasSync=true → hiện NGAY. Lần đầu tải mạng → hiện fallback.
          frameBuilder: (context, child, frame, wasSync) {
            if (wasSync || frame != null) return child;
            return fallback;
          },
          errorBuilder: (_, __, ___) => fallback,
        );
      },
    );
  }
}
