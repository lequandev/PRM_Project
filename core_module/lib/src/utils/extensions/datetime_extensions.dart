import 'package:intl/intl.dart';

/// DateTime extensions dùng chung toàn dự án.
/// Dev 1 owns — không tự sửa ngoài core_module.
extension DateTimeExtensions on DateTime {
  // ─── Format ────────────────────────────────────

  /// "16/07/2026"
  String get toVnDate => DateFormat('dd/MM/yyyy').format(this);

  /// "15:30"
  String get toTime => DateFormat('HH:mm').format(this);

  /// "16/07/2026 15:30"
  String get toVnDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// "Thứ Tư, 16/07/2026"
  String get toVnFullDate {
    const days = [
      '', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư',
      'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
    ];
    return '${days[weekday]}, ${toVnDate}';
  }

  // ─── Relative time ────────────────────────────

  /// "Vừa xong" / "5 phút trước" / "2 giờ trước" / "Hôm qua" / "16/07"
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua lúc ${toTime}';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return toVnDate;
  }

  // ─── Comparison helpers ───────────────────────

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    return difference(now).inDays.abs() < 7;
  }

  /// Đầu ngày (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Cuối ngày (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}

extension NullableDateTimeExtensions on DateTime? {
  String get toVnDateOrDash => this == null ? '—' : this!.toVnDate;
  String get toVnDateTimeOrDash => this == null ? '—' : this!.toVnDateTime;
  String get timeAgoOrDash => this == null ? '—' : this!.timeAgo;
}
