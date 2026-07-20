import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/checkout_repository.dart';
import 'data/core_repositories.dart';
import 'data/order_repository.dart';
import 'data/profile_repository.dart';
import 'data/session.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/menu/providers/menu_provider.dart';
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';

class App extends StatefulWidget {
  const App({super.key, this.firebaseReady = false});

  /// false = DEMO MODE: không AuthProvider, data chạy fake, banner DEMO ở góc.
  final bool firebaseReady;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    // Fake giữ làm "túi khí": Firebase lỗi (config/index/rules) vẫn demo được.
    final fakeOrders = widget.firebaseReady ? null : FakeOrderRepository();
    return MultiProvider(
      providers: [
        // ── Dev 2 / Tú ──
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        if (widget.firebaseReady) ...[
          // Profile lai: hồ sơ/điểm/reset-password thật, phần UserService
          // còn stub chạy fake (xem CoreProfileRepository).
          Provider<ProfileRepository>(
            create: (_) =>
                CoreProfileRepository(
                    UserService(), AuthService(), LoyaltyService()),
          ),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          // Session thật từ user đăng nhập — order phải mang uid thật,
          // không thì security rules (customerId == auth.uid) chặn đọc đơn.
          ProxyProvider<AuthProvider, CurrentSession>(
            update: (_, auth, __) => CurrentSession.fromUser(auth.currentUser),
          ),
          ProxyProvider<CurrentSession, OrderRepository>(
            update: (_, session, __) =>
                CoreOrderRepository(
                    OrderService(), ProductService(), session, LoyaltyService()),
          ),
          Provider<CheckoutRepository>(
            create: (_) => CoreCheckoutRepository(
              VoucherService(), OrderService(), StoreConfigService(),
            ),
          ),
        ] else ...[
          Provider<ProfileRepository>(create: (_) => FakeProfileRepository()),
          Provider<CurrentSession>(create: (_) => const CurrentSession.demo()),
          Provider<OrderRepository>.value(value: fakeOrders!),
          Provider<CheckoutRepository>(
            create: (_) => FakeCheckoutRepository(fakeOrders),
          ),
        ],
      ],
      child: widget.firebaseReady
          ? Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (_showSplash || authProvider.isInitializing) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    home: AnimatedSplashScreen(
                      onFinished: () {
                        if (mounted) setState(() => _showSplash = false);
                      },
                    ),
                  );
                }
                return _RouterApp(authProvider: authProvider);
              },
            )
          : (_showSplash
              ? MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  home: AnimatedSplashScreen(
                    onFinished: () {
                      if (mounted) setState(() => _showSplash = false);
                    },
                  ),
                )
              : const _RouterApp(authProvider: null)),
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
      builder: (context, child) {
        // Minh bạch với người xem: đang chạy data giả thì nói thẳng.
        if (widget.authProvider != null) return child!;
        return Banner(
          message: 'DEMO',
          location: BannerLocation.topEnd,
          color: AppColors.error,
          child: child!,
        );
      },
    );
  }
}
