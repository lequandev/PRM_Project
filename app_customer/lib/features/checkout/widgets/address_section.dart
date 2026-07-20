import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';
import 'section_card.dart';

/// UC-15 — Chọn địa chỉ giao hàng (chỉ hiện khi orderType == delivery).
class AddressSection extends StatelessWidget {
  const AddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final address = provider.selectedAddress;

    return SectionCard(
      title: 'Giao đến',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.isLoadingAddresses)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else if (provider.addresses.isEmpty)
            _EmptyAddresses(onAdd: () => _addAddressThenReload(context))
          else
            _SelectedAddressTile(
              address: address,
              onTap: () => _showAddressPicker(context),
            ),
          if (provider.isBelowDeliveryMinimum) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Đơn giao hàng tối thiểu '
                      '${provider.minDeliveryOrder.toVnd}. '
                      'Bạn thêm món nhé!',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// UC-05 từ checkout: khách chưa có địa chỉ → đi THẲNG tới form (không vòng
  /// qua màn danh sách), lưu xong quay lại checkout và reload để địa chỉ mới
  /// hiện + tự chọn. Bug cũ: đẩy sang màn danh sách và không reload → kẹt.
  Future<void> _addAddressThenReload(BuildContext context) async {
    final checkout = context.read<CheckoutProvider>();
    final added = await context.push<bool>('/profile/addresses/form');
    if (added == true) {
      await checkout.loadAddresses();
    }
  }

  void _showAddressPicker(BuildContext context) {
    final provider = context.read<CheckoutProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _AddressPickerSheet(),
      ),
    );
  }
}

class _SelectedAddressTile extends StatelessWidget {
  const _SelectedAddressTile({required this.address, required this.onTap});

  final AddressModel? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.beigeWarm,
              child: Icon(Icons.location_on_outlined,
                  size: 20, color: AppColors.brownAccent),
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
            Expanded(
              child: address == null
                  ? Text('Chọn địa chỉ giao hàng',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textHint))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(address!.label, style: AppTypography.h4),
                            if (address!.isDefault) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const _MiniBadge('Mặc định'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fullAddress(address!),
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bạn chưa lưu địa chỉ nào.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_location_alt_outlined, size: 18),
          label: const Text('Thêm địa chỉ giao hàng'),
        ),
      ],
    );
  }
}

/// Bottom sheet danh sách địa chỉ đã lưu — mỗi item một radio.
class _AddressPickerSheet extends StatelessWidget {
  const _AddressPickerSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Chọn địa chỉ giao hàng', style: AppTypography.h3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: RadioGroup<String>(
                groupValue: provider.selectedAddress?.id,
                onChanged: (id) {
                  final picked =
                      provider.addresses.where((a) => a.id == id).firstOrNull;
                  if (picked != null) provider.setAddress(picked);
                  Navigator.of(context).pop();
                },
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final a in provider.addresses)
                      RadioListTile<String>(
                        value: a.id,
                        activeColor: AppColors.goldPrimary,
                        title: Row(
                          children: [
                            Text(a.label, style: AppTypography.h4),
                            if (a.isDefault) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const _MiniBadge('Mặc định'),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          _fullAddress(a),
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextButton.icon(
                onPressed: () async {
                  // Bắt provider + router TRƯỚC khi pop (context sheet sẽ hết
                  // hiệu lực sau khi đóng).
                  final checkout = context.read<CheckoutProvider>();
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop(); // đóng sheet chọn địa chỉ
                  await router.push('/profile/addresses');
                  await checkout.loadAddresses(); // reload sau khi quản lý
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Quản lý địa chỉ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.beigeWarm,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: AppColors.brownAccent),
      ),
    );
  }
}

String _fullAddress(AddressModel a) => [a.street, a.ward, a.district, a.city]
    .where((part) => part.isNotEmpty)
    .join(', ');
