import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/checkout_repository.dart';
import 'data/order_repository.dart';
import 'data/profile_repository.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/menu/providers/menu_provider.dart';
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key, this.firebaseReady = false});

  /// false = DEMO MODE: không có AuthProvider, router bỏ qua màn đăng nhập.
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    final orderRepository = FakeOrderRepository();
    return MultiProvider(
      providers: [
        // ── Dev 2 / Tú ──
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // ── Dev 3: fake repositories — swap sang service core khi Dev 1 implement ──
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<CheckoutRepository>(
          create: (_) => FakeCheckoutRepository(orderRepository),
        ),
        Provider<ProfileRepository>(create: (_) => FakeProfileRepository()),
        // AuthProvider chạm FirebaseAuth.instance nên chỉ tạo khi Firebase sẵn sàng
        if (firebaseReady)
          ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: firebaseReady
          ? Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isInitializing) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    home: const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.goldPrimary),
                      ),
                    ),
                  );
                }
                return _RouterApp(authProvider: authProvider);
              },
            )
          : const _RouterApp(authProvider: null),
    );
  }
}

/// Giữ GoRouter sống qua các lần AuthProvider notify (login loading...) —
/// tạo router mỗi lần rebuild sẽ reset navigation stack.
class _RouterApp extends StatefulWidget {
  const _RouterApp({required this.authProvider});

  final AuthProvider? authProvider;

  @override
  State<_RouterApp> createState() => _RouterAppState();
}

class _RouterAppState extends State<_RouterApp> {
  late final GoRouter _router = createAppRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coffee Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
