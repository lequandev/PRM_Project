import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/staff_auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/orders/screens/order_queue_screen.dart';
import '../features/orders/screens/order_detail_screen.dart';
import '../features/scan/qr_scan_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../screens/main_shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/orders',
  redirect: (BuildContext context, GoRouterState state) {
    final authProvider = context.read<StaffAuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn) {
      return '/login';
    }

    if (isLoggedIn && isLoggingIn) {
      return '/orders';
    }

    if (state.matchedLocation == '/') {
      return '/orders';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderQueueScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/orders/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
    // UC-24 — quét QR khách để bàn giao đơn (full-screen, ngoài shell).
    GoRoute(
      path: '/scan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QrScanScreen(),
    ),
  ],
);
