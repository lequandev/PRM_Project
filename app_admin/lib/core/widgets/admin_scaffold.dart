import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../../features/auth/providers/admin_auth_provider.dart';

/// AdminScaffold — Desktop sidebar layout cho toàn bộ Admin Web.
/// Responsive: sidebar trên desktop, drawer trên mobile.
class AdminScaffold extends StatelessWidget {
  final String currentLocation;
  final Widget child;

  const AdminScaffold({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: Row(
          children: [
            _AdminSidebar(currentLocation: currentLocation),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile/Tablet — Drawer
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.brownAccent,
        foregroundColor: Colors.white,
        title: const Text('Coffee Shop Admin'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: _AdminSidebar(currentLocation: currentLocation, isDrawer: true),
      ),
      body: child,
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final String currentLocation;
  final bool isDrawer;

  const _AdminSidebar({
    required this.currentLocation,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();

    return Container(
      width: isDrawer ? null : 240,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo & Brand ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_cafe_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coffee Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white12, height: 1),
          ),
          const SizedBox(height: 8),

          // ── Navigation Groups ─────────────────────────────────────────
          _navGroup('TỔNG QUAN', [
            _NavItem(
              label: 'Dashboard',
              icon: Icons.dashboard_rounded,
              route: '/dashboard',
            ),
          ]),
          _navGroup('QUẢN LÝ', [
            _NavItem(
              label: 'Sản phẩm',
              icon: Icons.restaurant_menu_rounded,
              route: '/products',
            ),
            _NavItem(
              label: 'Kho hàng',
              icon: Icons.inventory_2_rounded,
              route: '/inventory',
            ),
          ]),
          _navGroup('MARKETING', [
            _NavItem(
              label: 'Voucher',
              icon: Icons.local_offer_rounded,
              route: '/vouchers',
            ),
            _NavItem(
              label: 'Thông báo',
              icon: Icons.notifications_rounded,
              route: '/notifications',
            ),
          ]),
          _navGroup('PHÂN TÍCH', [
            _NavItem(
              label: 'Doanh thu',
              icon: Icons.bar_chart_rounded,
              route: '/analytics/revenue',
            ),
            _NavItem(
              label: 'Sản phẩm hot',
              icon: Icons.trending_up_rounded,
              route: '/analytics/products',
            ),
          ]),
          _navGroup('KHÁC', [
            _NavItem(
              label: 'Đánh giá',
              icon: Icons.rate_review_rounded,
              route: '/reviews',
            ),
            _NavItem(
              label: 'Cài đặt cửa hàng',
              icon: Icons.settings_rounded,
              route: '/settings',
            ),
          ]),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white12, height: 1),
          ),

          // ── User Profile & Logout ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                  child: Text(
                    (auth.currentUser?.name.isNotEmpty == true)
                        ? auth.currentUser!.name[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.name ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.currentUser?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white38, size: 18),
                  tooltip: 'Đăng xuất',
                  onPressed: () async {
                    await context.read<AdminAuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ].map((w) => _buildNavWrapper(context, w)).toList(),
      ),
    );
  }

  Widget _navGroup(String title, List<_NavItem> items) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...items.map((item) => _buildNavItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item) {
    final isActive = currentLocation.startsWith(item.route);
    return GestureDetector(
      onTap: () {
        context.go(item.route);
        if (isDrawer) Navigator.of(context).pop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.goldPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: isActive ? AppColors.goldPrimary : Colors.white38,
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppColors.goldPrimary : Colors.white60,
                fontSize: 13,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Workaround to avoid Column inside Column issue
  Widget _buildNavWrapper(BuildContext context, Widget w) => w;
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

// ─── StatCard (shared widget) ─────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

