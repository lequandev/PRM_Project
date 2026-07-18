import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/checkout_repository.dart';
import 'data/fake_cart_provider.dart';
import 'data/order_repository.dart';
import 'data/profile_repository.dart';
import 'router/app_router.dart';

/// Coffee Shop — Customer App (Dev 2: menu/cart, Dev 3: checkout/orders/profile)
///
/// MOCK MODE: chưa gọi Firebase.initializeApp vì app_customer chưa có
/// firebase_options.dart (chờ flutterfire configure với project `finalprm`).
/// Toàn bộ data đi qua Fake*Repository trong lib/data/ — swap sang service
/// thật của core_module chỉ cần đổi các dòng `create:` bên dưới.
void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepository = FakeOrderRepository();
    return MultiProvider(
      providers: [
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<CheckoutRepository>(
          create: (_) => FakeCheckoutRepository(orderRepository),
        ),
        Provider<ProfileRepository>(create: (_) => FakeProfileRepository()),
        // ⚠️ Thay bằng CartProvider thật của Dev 2 khi có (xem fake_cart_provider.dart)
        ChangeNotifierProvider(create: (_) => FakeCartProvider()),
      ],
      child: MaterialApp.router(
        title: 'Coffee Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
