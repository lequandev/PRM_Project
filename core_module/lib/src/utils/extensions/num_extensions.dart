import 'package:intl/intl.dart';

/// Number extensions dùng chung toàn dự án.
/// Dev 1 owns — không tự sửa ngoài core_module.
extension NumExtensions on num {
  // ─── Currency ─────────────────────────────────

  /// Format VND: 35000 → "35.000đ"
  String get toVnd {
    return '${NumberFormat('#,###', 'vi_VN').format(this)}đ';
  }

  /// Format VND không đơn vị: 35000 → "35.000"
  String get toVndRaw {
    return NumberFormat('#,###', 'vi_VN').format(this);
  }

  /// Format VND với ký hiệu: 35000 → "35.000 ₫"
  String get toVndSymbol {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(this);
  }

  // ─── Loyalty Points ───────────────────────────

  /// Format điểm: 1500 → "1.500 điểm"
  String get toPoints {
    return '${NumberFormat('#,###').format(this)} điểm';
  }

  // ─── General ──────────────────────────────────

  /// Clamp giữa min và max
  num clampTo(num min, num max) => clamp(min, max);

  /// Làm tròn đến n chữ số thập phân
  double roundTo(int places) {
    final factor = 10 * places;
    return (this * factor).round() / factor;
  }

  /// Phần trăm: 0.35 → "35%"
  String get toPercent => '${(this * 100).toStringAsFixed(0)}%';

  /// Rating: 4.5 → "4.5 ★"
  String get toRating => '${toStringAsFixed(1)} ★';
}

extension IntExtensions on int {
  /// "1 sản phẩm" / "5 sản phẩm"
  String productCount() => '$this ${this == 1 ? "sản phẩm" : "sản phẩm"}';

  /// Loyalty points label: 100 → "100 điểm"
  String get pointsLabel => '$this điểm';
}
