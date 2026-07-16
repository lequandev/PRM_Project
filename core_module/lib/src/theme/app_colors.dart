import 'package:flutter/material.dart';

/// AppColors — Bảng màu Coffee Shop.
/// Dev 1 owns — Dev 2/3/4/5 dùng constants này, không hardcode màu.
abstract class AppColors {
  // ─── Primary (Coffee Brown) ───────────────────
  static const primary = Color(0xFF6F4E37);       // Màu nâu cà phê
  static const primaryLight = Color(0xFF9C7B5A);
  static const primaryDark = Color(0xFF4A3020);

  // ─── Secondary (Cream / Warm Gold) ───────────
  static const secondary = Color(0xFFF5DEB3);      // Wheat / Kem
  static const secondaryLight = Color(0xFFFFF8ED);
  static const secondaryDark = Color(0xFFD4A96A);  // Caramel

  // ─── Accent ───────────────────────────────────
  static const accent = Color(0xFFE8A838);          // Vàng caramel

  // ─── Neutrals ─────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF1A1A1A);
  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey900 = Color(0xFF212121);

  // ─── Semantic ─────────────────────────────────
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);
  static const warning = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFF3E0);
  static const error = Color(0xFFF44336);
  static const errorLight = Color(0xFFFFEBEE);
  static const info = Color(0xFF2196F3);
  static const infoLight = Color(0xFFE3F2FD);

  // ─── Order Status Colors ──────────────────────
  static const statusPending = Color(0xFFFF9800);    // Orange
  static const statusAccepted = Color(0xFF2196F3);   // Blue
  static const statusPreparing = Color(0xFF9C27B0);  // Purple
  static const statusReady = Color(0xFF4CAF50);      // Green
  static const statusDelivered = Color(0xFF607D8B);  // Blue Grey
  static const statusCancelled = Color(0xFFF44336);  // Red

  // ─── Background ───────────────────────────────
  static const background = Color(0xFFFFF8F0);       // Warm off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5EFE6);

  // ─── Text ─────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textDisabled = Color(0xFFBDBDBD);
  static const textOnPrimary = Color(0xFFFFFFFF);
}
