import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../../auth/providers/staff_auth_provider.dart';
import '../../orders/providers/staff_order_provider.dart';
import '../../inventory/providers/staff_inventory_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<StaffAuthProvider>();
    final orderProvider = context.watch<StaffOrderProvider>();
    final inventoryProvider = context.watch<StaffInventoryProvider>();

    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('THÔNG TIN CÁ NHÂN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Avatar Placeholder or Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.goldPrimary.withOpacity(0.15),
                    child: user?.avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(54),
                            child: Image.network(
                              user!.avatarUrl!,
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 54,
                            color: AppColors.brownAccent,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.goldPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        size: 18,
                        color: AppColors.textOnGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // User Name and Role Title
            Text(
              user?.name ?? 'Nhân viên Coffee Shop',
              style: AppTypography.h3.copyWith(color: AppColors.brownAccent),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'NHÂN VIÊN PHA CHẾ / THU NGÂN',
                style: AppTypography.caption.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile Details Section
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.email_outlined, 'Email', user?.email ?? 'Không có email'),
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow(Icons.phone_outlined, 'Số điện thoại', user?.phone ?? 'Chưa cập nhật'),
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow(Icons.badge_outlined, 'Mã số nhân viên', user?.uid.substring(0, 8).toUpperCase() ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // App Stats Section
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thống kê hôm nay', style: AppTypography.h4.copyWith(color: AppColors.brownAccent)),
                    const Divider(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox(
                          'ĐƠN CHỜ DUYỆT',
                          orderProvider.pendingOrders.length.toString(),
                          AppColors.statusPending,
                        ),
                        _buildStatBox(
                          'ĐƠN ĐANG LÀM',
                          orderProvider.preparingOrders.length.toString(),
                          AppColors.statusPreparing,
                        ),
                        _buildStatBox(
                          'HẾT NGUYÊN LIỆU',
                          inventoryProvider.ingredients.where((i) => i.isOutOfStock).length.toString(),
                          AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: AppSpacing.sm),
                    Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatBox(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: AppTypography.displayMedium.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
