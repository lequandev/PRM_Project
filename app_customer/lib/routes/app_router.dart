import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/checkout/screens/checkout_screen.dart';
import '../features/checkout/screens/order_success_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/orders/screens/order_history_screen.dart';
import '../features/orders/screens/order_tracking_screen.dart';
import '../features/profile/screens/address_form_screen.dart';
import '../features/profile/screens/addresses_screen.dart';
import '../features/profile/screens/loyalty_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/reset_password_screen.dart';
import '../navigation/main_navigation_screen.dart';
import '../providers/auth_provider.dart';

// Global keys for navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _menuNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'menu');
final _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final _ordersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// [authProvider] == null → DEMO MODE (Firebase chưa cấu hình): bỏ qua đăng nhập.
GoRouter createAppRouter(AuthProvider? authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/menu',
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (authProvider == null) return null; // DEMO MODE — không chặn route

      final isLoggedIn = authProvider.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/menu';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Dev 3: full-screen routes (đè lên bottom nav) ──
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/success/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => OrderSuccessScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/orders/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/profile/addresses',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/profile/addresses/form',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            AddressFormScreen(initial: state.extra as AddressModel?),
      ),
      GoRoute(
        path: '/profile/loyalty',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoyaltyScreen(),
      ),
      GoRoute(
        path: '/profile/reset-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Bottom Navigation Bar Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _menuNavigatorKey,
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _cartNavigatorKey,
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _ordersNavigatorKey,
            routes: [
              GoRoute(
                path: '/orders',
                // Dev 3: lịch sử đơn UC-18 (thay placeholder OrdersScreen)
                builder: (context, state) => const OrderHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                // Dev 3: hồ sơ UC-04 (bản đầy đủ address/loyalty/GDPR)
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
