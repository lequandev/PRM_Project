import 'package:flutter/foundation.dart';

/// AppLogger — Wrapper log nhất quán. Chỉ in khi kDebugMode = true.
/// Dev 1 owns — không tự sửa ngoài core_module.
class AppLogger {
  AppLogger._();

  static const String _tag = '[CoffeeShop]';

  /// Log thông tin thông thường
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('$_tag${tag != null ? "[$tag]" : ""} ℹ️  $message');
    }
  }

  /// Log cảnh báo
  static void warn(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('$_tag${tag != null ? "[$tag]" : ""} ⚠️  $message');
    }
  }

  /// Log lỗi (luôn in, kể cả production để debug crash)
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    debugPrint('$_tag${tag != null ? "[$tag]" : ""} ❌  $message');
    if (error != null) debugPrint('   Error: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint('   StackTrace: $stackTrace');
    }
  }

  /// Log Firestore/API calls (chỉ debug)
  static void network(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('$_tag${tag != null ? "[$tag]" : ""} 🌐  $message');
    }
  }

  /// Log auth events
  static void auth(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('$_tag${tag != null ? "[$tag]" : ""} 🔐  $message');
    }
  }
}
