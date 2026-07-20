import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Coffee Shop — Customer App.
/// Dev 2 (+Tú): auth/menu/cart · Dev 3: checkout/orders/profile.
///
/// Firebase init có "cầu dao": firebase_options.dart hiện dựng tay từ config
/// Dev 1 gửi (web đầy đủ, android tạm — chờ `flutterfire configure`). Nếu init
/// fail, app chạy DEMO MODE: bỏ qua màn đăng nhập, data đi qua Fake repositories.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nới cache ảnh trong RAM (mặc định 100MB) để ảnh không bị đẩy khỏi cache khi
  // lướt nhiều — kết hợp cache đĩa của cached_network_image (xem AppNetworkImage).
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200 MB

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('⚠️ Firebase chưa sẵn sàng — chạy DEMO MODE. Chi tiết: $e');
  }

  runApp(App(firebaseReady: firebaseReady));
}
