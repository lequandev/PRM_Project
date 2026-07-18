import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/app_session.dart';
import '../../data/fake_cart_provider.dart';

/// Hub demo tạm thời — KHÔNG phải màn hình menu thật.
/// Menu/danh mục/tìm kiếm (UC-07 → UC-12) là phần của Dev 2; khi Dev 2 có
/// MenuScreen thì route '/' trỏ về đó, hub này bỏ đi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<FakeCartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Coffee Shop ☕')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Banner chào
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldPrimary, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào ${AppSession.name.split(' ').last} 👋',
                  style: AppTypography.h2.copyWith(color: AppColors.textOnGold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Hôm nay uống gì nhỉ?',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textOnGold.withValues(alpha: .8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _HubTile(
            icon: Icons.local_cafe_outlined,
            title: 'Menu & Giỏ hàng',
            subtitle: 'Phần của Dev 2 (Trung) — đang chờ tích hợp',
            enabled: false,
            onTap: () {},
          ),
          _HubTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Thanh toán',
            subtitle: cart.isEmpty
                ? 'Giỏ hàng trống'
                : '${cart.itemCount} món trong giỏ — ${cart.subtotal.toVnd}',
            badge: cart.isEmpty ? null : '${cart.itemCount}',
            onTap: () => context.push('/checkout'),
          ),
          _HubTile(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng của tôi',
            subtitle: 'Lịch sử & theo dõi trạng thái realtime',
            onTap: () => context.push('/orders'),
          ),
          _HubTile(
            icon: Icons.person_outline,
            title: 'Tài khoản',
            subtitle: 'Hồ sơ, địa chỉ, điểm thưởng',
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor:
              enabled ? AppColors.beigeWarm : AppColors.backgroundAlt,
          child: Icon(icon,
              color: enabled ? AppColors.brownAccent : AppColors.textHint),
        ),
        title: Text(title, style: AppTypography.h4),
        subtitle: Text(subtitle,
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary)),
        trailing: badge != null
            ? CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.goldPrimary,
                child: Text(
                  badge!,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textOnGold),
                ),
              )
            : const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
