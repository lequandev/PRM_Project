import 'package:flutter/material.dart';

/// AppSpacing — Khoảng cách nhất quán toàn dự án.
/// Dev 1 owns — dùng constants này thay vì hardcode số.
abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// AppRadius — Border radius nhất quán.
abstract class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double pill = 100.0;   // Fully rounded (buttons, chips)
  static const double card = 12.0;    // Standard card radius
}

/// AppShadow — Box shadows nhất quán.
abstract class AppShadow {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D6F4E37),  // Primary với opacity thấp
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
