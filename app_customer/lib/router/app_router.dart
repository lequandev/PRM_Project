import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:go_router/go_router.dart';

import '../features/checkout/screens/checkout_screen.dart';
import '../features/checkout/screens/order_success_screen.dart';
import '../features/home/home_screen.dart';
import '../features/orders/screens/order_history_screen.dart';
import '../features/orders/screens/order_tracking_screen.dart';
import '../features/profile/screens/address_form_screen.dart';
import '../features/profile/screens/addresses_screen.dart';
import '../features/profile/screens/loyalty_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/reset_password_screen.dart';

/// Router chung của app_customer.
/// Dev 2 thêm route menu/cart tại đây (nhánh riêng, báo trước khi sửa để
/// tránh conflict — file này là shared shell).
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    // ── Dev 3: Checkout (UC-13 → UC-17) ──
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/checkout/success/:orderId',
      builder: (context, state) => OrderSuccessScreen(
        orderId: state.pathParameters['orderId']!,
      ),
    ),

    // ── Dev 3: Orders (UC-18, UC-19, UC-39) ──
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: '/orders/:orderId',
      builder: (context, state) => OrderTrackingScreen(
        orderId: state.pathParameters['orderId']!,
      ),
    ),

    // ── Dev 3: Profile (UC-03 UI, UC-04, UC-05, UC-06, UC-27, UC-28) ──
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/addresses',
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: '/profile/addresses/form',
      builder: (context, state) =>
          AddressFormScreen(initial: state.extra as AddressModel?),
    ),
    GoRoute(
      path: '/profile/loyalty',
      builder: (context, state) => const LoyaltyScreen(),
    ),
    GoRoute(
      path: '/profile/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
);
