import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/profile_repository.dart';
import '../providers/loyalty_provider.dart';

/// LoyaltyScreen — UC-27 (xem điểm + lịch sử), UC-28 (đổi điểm lấy voucher).
class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          LoyaltyProvider(context.read<ProfileRepository>())..load(),
      child: const _LoyaltyView(),
    );
  }
}

class _LoyaltyView extends StatelessWidget {
  const _LoyaltyView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoyaltyProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Điểm thưởng')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.transactions.isEmpty) {
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
                      onPressed: provider.load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.goldPrimary,
            onRefresh: provider.load,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _PointsHeroCard(points: provider.points),
                const SizedBox(height: AppSpacing.md),
                _RedeemCard(provider: provider),
                const SizedBox(height: AppSpacing.lg),
                const Text('Lịch sử điểm', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                if (provider.transactions.isEmpty)
                  _buildEmptyHistory()
                else
                  for (final tx in provider.transactions) ...[
                    _TransactionTile(tx: tx),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded,
              size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chưa có giao dịch điểm nào.\nĐặt món để bắt đầu tích điểm nhé!',
            textAlign: TextAlign.center,
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Hero card gradient gold — số điểm hiện tại.
class _PointsHeroCard extends StatelessWidget {
  const _PointsHeroCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    // toPoints → "1.250 điểm"; tách phần số để hiển thị to.
    final pointsNumber = points.toPoints.replaceAll(' điểm', '');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.bannerGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded,
                  color: AppColors.textOnGold, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Điểm thưởng của bạn',
                style: AppTypography.label.copyWith(
                  color: AppColors.textOnGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                pointsNumber,
                style: AppTypography.displayMedium
                    .copyWith(color: AppColors.textOnGold),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'điểm',
                style:
                    AppTypography.h4.copyWith(color: AppColors.textOnGold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Mỗi 100đ chi tiêu = 1 điểm tích lũy',
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGold.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card đổi thưởng — UC-28.
class _RedeemCard extends StatelessWidget {
  const _RedeemCard({required this.provider});

  final LoyaltyProvider provider;

  @override
  Widget build(BuildContext context) {
    final missing = LoyaltyProvider.redeemCost - provider.points;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
            decoration: const BoxDecoration(
              color: AppColors.beigeWarm,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard_rounded,
                color: AppColors.goldPrimary, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đổi ${LoyaltyProvider.redeemCost} điểm lấy voucher '
                  'giảm ${15000.toVnd}',
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  provider.points >= LoyaltyProvider.redeemCost
                      ? 'Bạn đủ điểm để đổi ngay!'
                      : 'Bạn cần thêm ${missing.toPoints} nữa',
                  style: AppTypography.caption.copyWith(
                    color: provider.points >= LoyaltyProvider.redeemCost
                        ? AppColors.success
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textOnGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed:
                provider.canRedeem ? () => _confirmRedeem(context) : null,
            child: provider.isRedeeming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Đổi', style: AppTypography.buttonSmall),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRedeem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đổi điểm lấy voucher?'),
        content: Text(
          '${LoyaltyProvider.redeemCost} điểm sẽ bị trừ để đổi lấy voucher '
          'giảm ${15000.toVnd}. Tiếp tục?',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textOnGold,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đổi ngay'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final code = await provider.redeemPoints();
    if (!context.mounted) return;

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(provider.error ?? 'Đổi điểm thất bại.'),
        ),
      );
      return;
    }
    await _showVoucherDialog(context, code);
  }

  Future<void> _showVoucherDialog(BuildContext context, String code) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.celebration_rounded,
            color: AppColors.goldPrimary, size: 48),
        title: const Text('Đổi điểm thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mã voucher của bạn:',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.beigeWarm,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.goldPrimary),
              ),
              child: Text(
                code,
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  color: AppColors.brownAccent,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nhập mã này ở bước thanh toán để được giảm giá.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Đã sao chép mã voucher'),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Sao chép'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textOnGold,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }
}

/// Một dòng lịch sử tích/đổi điểm.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});

  final LoyaltyTransactionModel tx;

  @override
  Widget build(BuildContext context) {
    final isEarn = tx.points >= 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isEarn ? AppColors.successLight : AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: isEarn ? AppColors.success : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  // dd/MM/yyyy — extension toVnDate của core.
                  tx.createdAt.toVnDateOrDash,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isEarn ? '+${tx.points}' : '${tx.points}',
            style: AppTypography.price.copyWith(
              fontSize: 16,
              color: isEarn ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
