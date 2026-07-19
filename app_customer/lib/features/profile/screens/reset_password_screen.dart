import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/session.dart';
import '../../../data/profile_repository.dart';
import '../providers/profile_provider.dart';

/// ResetPasswordScreen — UC-03: gửi email đặt lại mật khẩu.
///
/// MOCK MODE: FakeProfileRepository chỉ giả lập độ trễ.
/// Bản thật dùng AuthService.sendPasswordResetEmail của core (đã implement) —
/// swap repository trong main.dart là xong, UI giữ nguyên.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(
        context.read<ProfileRepository>(),
        context.read<CurrentSession>(),
      ),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  // Prefill email của phiên demo.
  late final _emailController =
      TextEditingController(text: context.read<CurrentSession>().email);
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final provider = context.read<ProfileProvider>();
    final ok =
        await provider.sendPasswordResetEmail(_emailController.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(provider.error ?? 'Gửi email thất bại.'),
        ),
      );
    }
  }

  Future<void> _resend() async {
    final provider = context.read<ProfileProvider>();
    final ok =
        await provider.sendPasswordResetEmail(_emailController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.success : AppColors.error,
        content: Text(ok
            ? 'Đã gửi lại email đặt lại mật khẩu'
            : provider.error ?? 'Gửi email thất bại.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Đặt lại mật khẩu')),
      body: _sent ? _buildSentState() : _buildFormState(),
    );
  }

  // ─── Trạng thái nhập email ───

  Widget _buildFormState() {
    final isSending = context.watch<ProfileProvider>().isSaving;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.beigeWarm,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.brownAccent),
                    const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Nhập email tài khoản của bạn. Chúng tôi sẽ gửi một '
                        'liên kết để bạn đặt lại mật khẩu mới.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: FormValidators.email,
                onFieldSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ban@example.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.textOnGold,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                onPressed: isSending ? null : _send,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  isSending ? 'Đang gửi…' : 'Gửi email đặt lại mật khẩu',
                  style: AppTypography.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Trạng thái đã gửi thành công ───

  Widget _buildSentState() {
    final isSending = context.watch<ProfileProvider>().isSaving;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  size: 48, color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Đã gửi! Kiểm tra hộp thư của bạn',
              textAlign: TextAlign.center,
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Liên kết đặt lại mật khẩu đã được gửi tới\n'
              '${_emailController.text.trim()}',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Không thấy email? Kiểm tra cả mục Spam nhé.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.textHint),
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownAccent,
                side: const BorderSide(color: AppColors.brownAccent),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              onPressed: isSending ? null : _resend,
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Gửi lại', style: AppTypography.button),
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.textOnGold,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              onPressed: () => context.pop(),
              child: const Text('Quay lại', style: AppTypography.button),
            ),
          ],
        ),
      ),
    );
  }
}
