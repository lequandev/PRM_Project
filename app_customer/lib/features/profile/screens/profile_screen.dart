import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final String initial = (user?.name != null && user!.name.isNotEmpty) ? user.name[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.beigeWarm,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Khách hàng',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Chưa cập nhật email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.goldPrimary),
                    onPressed: () {
                      // TODO: Navigate to Edit Profile
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Menu Items
            _buildMenuGroup([
              _buildMenuItem(context, Icons.receipt_long, 'Lịch sử đơn hàng', onTap: () {}),
              _buildMenuItem(context, Icons.favorite_border, 'Sản phẩm yêu thích', onTap: () {}),
              _buildMenuItem(context, Icons.location_on_outlined, 'Sổ địa chỉ', onTap: () {}),
            ]),
            const SizedBox(height: 12),
            _buildMenuGroup([
              _buildMenuItem(context, Icons.card_giftcard, 'Ưu đãi & Voucher', onTap: () {}),
              _buildMenuItem(context, Icons.notifications_none, 'Cài đặt thông báo', onTap: () {}),
              _buildMenuItem(context, Icons.help_outline, 'Hỗ trợ & Trợ giúp', onTap: () {}),
            ]),
            const SizedBox(height: 12),
            _buildMenuGroup([
              _buildMenuItem(
                context, 
                Icons.logout, 
                'Đăng xuất', 
                color: AppColors.error, 
                showDivider: false,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    IconData icon, 
    String title, {
    Color? color, 
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color ?? AppColors.textSecondary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: color ?? AppColors.textPrimary,
                      fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.borderLight, size: 24),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, thickness: 1, indent: 60, endIndent: 20, color: AppColors.borderLight),
        ],
      ),
    );
  }
}
