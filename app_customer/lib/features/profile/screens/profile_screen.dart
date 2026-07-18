import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/profile_repository.dart';
import '../providers/profile_provider.dart';

/// ProfileScreen — UC-04 (hồ sơ), điều hướng UC-05/03/27, UC-06 (xóa tài khoản).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ProfileProvider(context.read<ProfileRepository>())..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Tài khoản')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && provider.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.profile == null) {
            return _ErrorView(
              message: provider.error ?? 'Đã có lỗi xảy ra.',
              onRetry: provider.loadProfile,
            );
          }
          return _ProfileContent(provider: provider);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    final profile = provider.profile!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _HeaderCard(profile: profile),
        const SizedBox(height: AppSpacing.md),
        _MenuGroup(
          children: [
            _MenuTile(
              icon: Icons.person_outline,
              title: 'Chỉnh sửa hồ sơ',
              onTap: () => _openEditSheet(context),
            ),
            _MenuTile(
              icon: Icons.location_on_outlined,
              title: 'Địa chỉ đã lưu',
              onTap: () => context.push('/profile/addresses'),
            ),
            _MenuTile(
              icon: Icons.star_outline_rounded,
              title: 'Điểm thưởng',
              onTap: () => context.push('/profile/loyalty'),
            ),
            _MenuTile(
              icon: Icons.lock_reset_rounded,
              title: 'Đặt lại mật khẩu',
              onTap: () => context.push('/profile/reset-password'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // ── Khu vực nguy hiểm (UC-06 — GDPR) ──
        _MenuGroup(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined,
                  color: AppColors.error),
              title: Text(
                'Xóa tài khoản',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Vô hiệu hóa tài khoản và dữ liệu cá nhân',
                style:
                    AppTypography.caption.copyWith(color: AppColors.textHint),
              ),
              onTap: () => _startDeleteFlow(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Phiên demo — đăng nhập thật sẽ hoạt động khi tích hợp Firebase.',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  // ─── UC-04: bottom sheet chỉnh sửa hồ sơ ───

  void _openEditSheet(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _EditProfileSheet(),
      ),
    );
  }

  // ─── UC-06: xóa tài khoản — 2 bước xác nhận (GDPR) ───

  Future<void> _startDeleteFlow(BuildContext context) async {
    final provider = context.read<ProfileProvider>();

    // Bước 1 — giải thích hệ quả (soft-delete / GDPR).
    final step1 = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: Text(
          'Theo quy định bảo vệ dữ liệu (GDPR):\n\n'
          '• Tài khoản của bạn sẽ bị vô hiệu hóa, không thể đăng nhập.\n'
          '• Thông tin cá nhân (tên, SĐT, địa chỉ) sẽ bị ẩn khỏi hệ thống.\n'
          '• Lịch sử đơn hàng được giữ ẩn danh cho mục đích kế toán.\n\n'
          'Hành động này không thể hoàn tác.',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
    if (step1 != true || !context.mounted) return;

    // Bước 2 — gõ XOA để xác nhận.
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          _TypeToConfirmDialog(provider: provider),
    );
    if (confirmed != true || !context.mounted) return;

    // Thành công — thông báo và quay về.
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 48),
        title: const Text('Đã vô hiệu hóa tài khoản'),
        content: Text(
          'Yêu cầu xóa tài khoản đã được ghi nhận. '
          '(Phiên demo: dữ liệu giả lập, không có gì bị xóa thật.)',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}

/// Dialog bước 2 — yêu cầu gõ đúng chữ XOA mới cho phép xác nhận.
class _TypeToConfirmDialog extends StatefulWidget {
  const _TypeToConfirmDialog({required this.provider});

  final ProfileProvider provider;

  @override
  State<_TypeToConfirmDialog> createState() => _TypeToConfirmDialogState();
}

class _TypeToConfirmDialogState extends State<_TypeToConfirmDialog> {
  final _controller = TextEditingController();
  bool _processing = false;

  bool get _matched => _controller.text.trim().toUpperCase() == 'XOA';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _processing = true);
    final ok = await widget.provider.deactivateAccount();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(widget.provider.error ?? 'Có lỗi xảy ra.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận lần cuối'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gõ chữ XOA vào ô bên dưới để xác nhận xóa tài khoản.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'XOA',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _processing ? null : () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnDark,
          ),
          onPressed: _matched && !_processing ? _confirm : null,
          child: _processing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.textOnDark),
                )
              : const Text('Xóa tài khoản'),
        ),
      ],
    );
  }
}

/// Header card — avatar chữ cái đầu, tên, email, chip điểm thưởng.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.name.trim().isEmpty ? '?' : profile.name.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.beigeWarm,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.brownAccent,
            child: Text(
              initial,
              style: AppTypography.h1.copyWith(color: AppColors.textOnDark),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,
                    style: AppTypography.h3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Chip điểm thưởng → màn loyalty (UC-27)
                Material(
                  color: AppColors.goldPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    onTap: () => context.push('/profile/loyalty'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + AppSpacing.xs,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        '⭐ ${profile.loyaltyPoints.toPoints}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.textOnGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet chỉnh sửa tên + SĐT (UC-04).
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ProfileProvider>();
    final ok = await provider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Đã cập nhật hồ sơ'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(provider.error ?? 'Cập nhật thất bại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileProvider>().isSaving;
    return Padding(
      // Đẩy sheet lên khi bàn phím mở.
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Chỉnh sửa hồ sơ', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.name,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: FormValidators.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: 'VD: 0912345678',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.textOnGold,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu thay đổi', style: AppTypography.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nhóm menu dạng card trắng bo góc.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md,
                  color: AppColors.borderLight),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brownAccent),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
