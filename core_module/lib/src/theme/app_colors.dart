import 'package:flutter/material.dart';

/// AppColors — Bảng màu chính thức của Coffee Shop.
/// Dev 1 owns — Dev 2/3/4/5 dùng constants này, KHÔNG hardcode màu.
///
/// Cập nhật: 16/07/2026 — Brand palette chính thức
abstract class AppColors {

  // ════════════════════════════════════════════════════════
  // 1. NHÓM MÀU THƯƠNG HIỆU (Brand & Accent Colors - Soft Academic Palette)
  // ════════════════════════════════════════════════════════

  /// Vàng Cổ Điển (Soft Academic Antique Gold) — #A67C1E
  /// Đã hạ bão hòa để giảm mỏi mắt, tăng tính chuyên nghiệp học thuật.
  static const Color goldPrimary = Color(0xFFA67C1E);

  /// Vàng Giấy Cũ (Scholarly Gold Parchment) — #DEC58A
  /// Hài hòa làm màu sáng cho gradient và highlight.
  static const Color goldLight = Color(0xFFDEC58A);

  /// Nâu Gỗ Mahogany (Dark Library Mahogany) — #452D1E
  /// Màu gỗ thư viện tối sẫm, mang cảm giác yên tĩnh và tập trung.
  static const Color brownAccent = Color(0xFF452D1E);

  /// Kem Giấy Sách (Warm Book Paper) — #F4ECE1
  /// Hạn chế tối đa ánh sáng xanh, lý tưởng khi chấm bài ca đêm.
  static const Color beigeWarm = Color(0xFFF4ECE1);

  /// Kem Ấm Sáng (Soft Warm Ivory) — #FAF5ED
  /// Highlight nền rất nhẹ nhàng.
  static const Color beigeLight = Color(0xFFFAF5ED);

  // ════════════════════════════════════════════════════════
  // 2. NHÓM MÀU NỀN & KHỐI (Background & Canvas)
  // ════════════════════════════════════════════════════════

  /// Nền Chính (Parchment White) — #FAF7F2
  /// Nền tổng thể êm dịu, giảm lóa mắt.
  static const Color backgroundLight = Color(0xFFFAF7F2);

  /// Nền Phụ (Muted Desk Oak) — #F2ECE0
  /// Tạo độ sâu phân cấp layout nhẹ nhàng.
  static const Color backgroundAlt = Color(0xFFF2ECE0);

  /// Nền Thẻ — #FFFFFF
  /// Trắng nguyên bản để giữ độ tương phản cao cho nội dung.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Đường Viền Giấy — #E5DEC9
  /// Phân tách tinh tế, tiệp tông màu học thuật.
  static const Color borderLight = Color(0xFFE5DEC9);

  // ════════════════════════════════════════════════════════
  // 3. NHÓM MÀU CHỮ (Typography - WCAG AAA Compliant)
  // ════════════════════════════════════════════════════════

  /// Chữ Chính (Ebony Ink) — #161616
  /// Tương phản cực cao cho chữ nhỏ hoặc đọc lướt.
  static const Color textPrimary = Color(0xFF161616);

  /// Chữ Phụ (Dark Graphite) — #474747
  /// Vẫn đảm bảo độ tương phản AAA đối với nền kem/trắng.
  static const Color textSecondary = Color(0xFF474747);

  /// Chữ Nhạt / Hint — #767676
  /// Đảm bảo tối thiểu tỷ lệ tương phản 4.5:1.
  static const Color textHint = Color(0xFF767676);

  /// Chữ trên nền tối (Primary button, AppBar)
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Chữ trên nền Gold
  static const Color textOnGold = Color(0xFF1C1C1C);

  // ════════════════════════════════════════════════════════
  // 4. NHÓM MÀU TRẠNG THÁI (Status Colors)
  // ════════════════════════════════════════════════════════

  /// Xanh Lục Thành Công — #3BB273
  /// Xác nhận giao hàng, thanh toán thành công, mã quét thành công
  static const Color success = Color(0xFF3BB273);

  /// Nền Xanh Lục Nhạt — Success background
  static const Color successLight = Color(0xFFE8F7EF);

  /// Đỏ San Hô Lỗi — #E74C3C
  /// Nhãn giảm giá, icon yêu thích đã lưu, chấm thông báo chưa đọc
  static const Color error = Color(0xFFE74C3C);

  /// Nền Đỏ Nhạt — Error background
  static const Color errorLight = Color(0xFFFDECEA);

  /// Vàng Cam Cảnh Báo — Warning
  static const Color warning = Color(0xFFF39C12);

  /// Nền Vàng Nhạt — Warning background
  static const Color warningLight = Color(0xFFFEF9E7);

  // ════════════════════════════════════════════════════════
  // 5. MÀU TRẠNG THÁI ĐƠN HÀNG (Order Status)
  // ════════════════════════════════════════════════════════

  /// Chờ xác nhận — Orange
  static const Color statusPending = Color(0xFFF39C12);

  /// Đã xác nhận — Blue
  static const Color statusAccepted = Color(0xFF3498DB);

  /// Đang pha chế — Purple
  static const Color statusPreparing = Color(0xFF9B59B6);

  /// Sẵn sàng lấy — Green
  static const Color statusReady = Color(0xFF3BB273);

  /// Hoàn thành — Blue Grey
  static const Color statusDelivered = Color(0xFF607D8B);

  /// Đã hủy — Red
  static const Color statusCancelled = Color(0xFFE74C3C);

  // ════════════════════════════════════════════════════════
  // 6. TIỆN ÍCH & SHORTHAND
  // ════════════════════════════════════════════════════════

  /// Trắng thuần
  static const Color white = Color(0xFFFFFFFF);

  /// Đen thuần
  static const Color black = Color(0xFF000000);

  /// Transparent
  static const Color transparent = Color(0x00000000);

  /// Gradient Banner: goldLight → goldPrimary
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [goldLight, goldPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient nút CTA chính
  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [goldLight, goldPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gradient nền ấm (AppBar, header)
  static const LinearGradient warmHeaderGradient = LinearGradient(
    colors: [beigeLight, beigeWarm],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Trả về màu tương ứng với order status string
  static Color forOrderStatus(String status) {
    switch (status) {
      case 'pending':   return statusPending;
      case 'accepted':  return statusAccepted;
      case 'preparing': return statusPreparing;
      case 'ready':     return statusReady;
      case 'delivered': return statusDelivered;
      case 'cancelled': return statusCancelled;
      default:          return textHint;
    }
  }
}
