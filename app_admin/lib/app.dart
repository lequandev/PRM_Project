import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/admin_auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/menu_management/screens/product_list_screen.dart';
import 'features/menu_management/screens/product_form_screen.dart';
import 'features/inventory/screens/inventory_screen.dart';
import 'features/marketing/screens/voucher_screen.dart';
import 'features/marketing/screens/notification_screen.dart';
import 'features/store_settings/screens/store_settings_screen.dart';
import 'features/analytics/screens/revenue_screen.dart';
import 'features/analytics/screens/product_analytics_screen.dart';
import 'features/reviews/screens/review_moderation_screen.dart';
import 'core/widgets/admin_scaffold.dart';

// ─── Navigator Keys ───────────────────────────────────────────────────────────

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// ─── Router Factory ───────────────────────────────────────────────────────────

GoRouter createAdminRouter(AdminAuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: auth,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = auth.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && auth.isLoading) return null; // wait
      if (!isLoggedIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';
      if (state.matchedLocation == '/') return '/dashboard';

      return null;
    },
    routes: [
      // ── Login ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Admin Shell (Sidebar Layout) ───────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            AdminScaffold(currentLocation: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Menu Management (UC-31, 32, 33)
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: '/products/new',
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: '/products/:id/edit',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductFormScreen(editProductId: productId);
            },
          ),

          // Inventory (UC-34, 35)
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),

          // Marketing — Voucher (UC-29)
          GoRoute(
            path: '/vouchers',
            builder: (context, state) => const VoucherScreen(),
          ),

          // Marketing — Notification (UC-30)
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),

          // Store Settings (UC-36)
          GoRoute(
            path: '/settings',
            builder: (context, state) => const StoreSettingsScreen(),
          ),

          // Analytics — Revenue (UC-37)
          GoRoute(
            path: '/analytics/revenue',
            builder: (context, state) => const RevenueScreen(),
          ),

          // Analytics — Products (UC-38)
          GoRoute(
            path: '/analytics/products',
            builder: (context, state) => const ProductAnalyticsScreen(),
          ),

          // Reviews (UC-40)
          GoRoute(
            path: '/reviews',
            builder: (context, state) => const ReviewModerationScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri}'),
      ),
    ),
  );
}

// Helper để tạo router với context (dùng trong Consumer)
extension RouterContext on BuildContext {
  AdminAuthProvider get adminAuth => read<AdminAuthProvider>();
}
