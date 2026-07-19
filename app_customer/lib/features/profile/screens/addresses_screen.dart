import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/profile_repository.dart';
import '../../../data/session.dart';
import '../providers/address_provider.dart';

/// AddressesScreen — UC-05: danh sách địa chỉ đã lưu.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AddressProvider(
        context.read<ProfileRepository>(),
        context.read<CurrentSession>(),
      )..loadAddresses(),
      child: const _AddressesView(),
    );
  }
}

class _AddressesView extends StatelessWidget {
  const _AddressesView();

  Future<void> _openForm(BuildContext context, {AddressModel? address}) async {
    final provider = context.read<AddressProvider>();
    // Form là route riêng (provider riêng) — reload list khi quay lại.
    await context.push('/profile/addresses/form', extra: address);
    await provider.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Địa chỉ đã lưu')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: AppColors.textOnGold,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm địa chỉ'),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && provider.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.addresses.isEmpty) {
            return _buildError(context, provider);
          }
          if (provider.addresses.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
            itemCount: provider.addresses.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            itemBuilder: (context, index) {
              final address = provider.addresses[index];
              return _AddressCard(
                address: address,
                onEdit: () => _openForm(context, address: address),
                onSetDefault: () => _setDefault(context, address),
                onDelete: () => _confirmDelete(context, address),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, AddressProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: provider.loadAddresses,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.beigeWarm,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined,
                  size: 48, color: AppColors.brownAccent),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Chưa có địa chỉ nào', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Lưu địa chỉ để đặt giao hàng nhanh hơn.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setDefault(BuildContext context, AddressModel address) async {
    final provider = context.read<AddressProvider>();
    final ok = await provider.setDefault(address);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.success : AppColors.error,
        content: Text(ok
            ? 'Đã đặt "${address.label}" làm địa chỉ mặc định'
            : provider.error ?? 'Thao tác thất bại.'),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AddressModel address) async {
    final provider = context.read<AddressProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa địa chỉ?'),
        content: Text(
          'Địa chỉ "${address.label} — ${address.street}" sẽ bị xóa vĩnh viễn.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await provider.deleteAddress(address.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.success : AppColors.error,
        content:
            Text(ok ? 'Đã xóa địa chỉ' : provider.error ?? 'Xóa thất bại.'),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  IconData get _icon {
    switch (address.label) {
      case 'Nhà':
        return Icons.home_rounded;
      case 'Trường':
      case 'Cơ quan':
        return Icons.work_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.sm,
        border: address.isDefault
            ? Border.all(color: AppColors.goldPrimary, width: 1.2)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
            decoration: const BoxDecoration(
              color: AppColors.beigeWarm,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: AppColors.brownAccent, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(address.label,
                          style: AppTypography.h4,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'Mặc định',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${address.street}, ${address.ward}, '
                  '${address.district}, ${address.city}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textHint),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                case 'default':
                  onSetDefault();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined, size: 20),
                  title: Text('Sửa'),
                ),
              ),
              if (!address.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.star_outline_rounded, size: 20),
                    title: Text('Đặt làm mặc định'),
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline,
                      size: 20, color: AppColors.error),
                  title:
                      Text('Xóa', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
