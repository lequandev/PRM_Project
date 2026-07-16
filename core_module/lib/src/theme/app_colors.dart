import 'package:flutter/material.dart';

/// AppColors — Bảng màu chính thức của Coffee Shop.
/// Dev 1 owns — Dev 2/3/4/5 dùng constants này, KHÔNG hardcode màu.
///
/// Cập nhật: 16/07/2026 — Brand palette chính thức
abstract class AppColors {

  // ════════════════════════════════════════════════════════
  // 1. NHÓM MÀU THƯƠNG HIỆU (Brand & Accent Colors)
  // ════════════════════════════════════════════════════════

  /// Vàng Hoàng Kim — #D4A017
  /// Dùng cho: nút Add to Cart, Bottom Bar active, icon danh mục, nhãn quan trọng
  static const Color goldPrimary = Color(0xFFD4A017);

  /// Vàng Sáng — #F6D365
  /// Dùng cho: gradient Banner quảng cáo (kết hợp với goldPrimary)
  static const Color goldLight = Color(0xFFF6D365);

  /// Nâu Cà Phê Trầm — #5A3E2B
  /// Đặc trưng của hạt cà phê rang xay, dùng cho AppBar, heading chính
  static const Color brownAccent = Color(0xFF5A3E2B);

  /// Kem Ấm — #F8F3EA
  /// Dùng cho: nền Custom AppBar, khu vực ưu đãi đặc biệt
  static const Color beigeWarm = Color(0xFFF8F3EA);

  /// Kem Ấm Sáng — #FFF8EE
  /// Biến thể sáng hơn của beigeWarm, dùng cho highlight nhẹ
  static const Color beigeLight = Color(0xFFFFF8EE);

  // ════════════════════════════════════════════════════════
  // 2. NHÓM MÀU NỀN & KHỐI (Background & Canvas)
  // ════════════════════════════════════════════════════════

  /// Nền Chính — #FAFAFA
  /// Nền tổng thể ứng dụng — xám-trắng sạch, Modern UI
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Nền Phụ — #F8F8F8
  /// Biến thể nền phụ cho các section thứ cấp
  static const Color backgroundAlt = Color(0xFFF8F8F8);

  /// Nền Thẻ — #FFFFFF
  /// Card product, danh mục — trắng tinh khiết nổi bật trên nền xám
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Đường Viền — #ECECEC
  /// Phân tách các khu vực layout một cách tinh tế
  static const Color borderLight = Color(0xFFECECEC);

  // ════════════════════════════════════════════════════════
  // 3. NHÓM MÀU CHỮ (Typography)
  // ════════════════════════════════════════════════════════

  /// Chữ Chính — #1C1C1C
  /// Tiêu đề, tên sản phẩm — độ tương phản tối ưu
  static const Color textPrimary = Color(0xFF1C1C1C);

  /// Chữ Phụ — #6B6B6B
  /// Mô tả ngắn, giá cả, chú thích phụ
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Chữ Nhạt / Hint — #9E9E9E
  /// Placeholder tìm kiếm, icon chưa active
  static const Color textHint = Color(0xFF9E9E9E);

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
