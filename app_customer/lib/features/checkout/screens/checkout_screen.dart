import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/checkout_repository.dart';
import '../../../data/profile_repository.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/address_section.dart';
import '../widgets/cart_items_section.dart';
import '../widgets/checkout_summary_card.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/section_card.dart';
import '../widgets/voucher_field.dart';

/// UC-13 → UC-17 — Màn thanh toán.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CheckoutProvider(
        checkoutRepository: context.read<CheckoutRepository>(),
        profileRepository: context.read<ProfileRepository>(),
        cart: context.read<CartProvider>(),
      ),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Thanh toán')),
      body: provider.isCartEmpty
          ? const _EmptyCartState()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const _OrderTypeSection(),
                if (provider.orderType == OrderType.delivery)
                  const AddressSection(),
                const CartItemsSection(),
                const _NoteSection(),
                const VoucherField(),
                const PaymentMethodSection(),
                const CheckoutSummaryCard(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
      bottomNavigationBar:
          provider.isCartEmpty ? null : const _PlaceOrderBar(),
    );
  }
}

/// (a) Toggle Mang về / Giao hàng.
class _OrderTypeSection extends StatelessWidget {
  const _OrderTypeSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    return SectionCard(
      title: 'Hình thức nhận hàng',
      child: SegmentedButton<OrderType>(
        segments: [
          for (final type in OrderType.values)
            ButtonSegment(
              value: type,
              label: Text(type.label),
              icon: Icon(type == OrderType.pickup
                  ? Icons.storefront_outlined
                  : Icons.delivery_dining_outlined),
            ),
        ],
        selected: {provider.orderType},
        onSelectionChanged: (selection) =>
            provider.setOrderType(selection.first),
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.beigeWarm,
          selectedForegroundColor: AppColors.brownAccent,
        ),
      ),
    );
  }
}

/// (d) Ghi chú cho quán.
class _NoteSection extends StatelessWidget {
  const _NoteSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CheckoutProvider>();
    return SectionCard(
      title: 'Ghi chú cho quán',
      child: TextField(
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Ví dụ: ít đá, để riêng đường, gọi trước khi giao…',
          isDense: true,
        ),
        onChanged: provider.setNote,
      ),
    );
  }
}

/// Nút Đặt hàng cố định dưới màn hình.
class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    String? blockReason;
    if (provider.isBelowDeliveryMinimum) {
      blockReason = 'Chưa đạt giá trị tối thiểu cho đơn giao hàng';
    } else if (provider.orderType == OrderType.delivery &&
        provider.selectedAddress == null) {
      blockReason = 'Chọn địa chỉ giao hàng để tiếp tục';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: AppShadow.md,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (blockReason != null) ...[
                Text(
                  blockReason,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.warning),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: provider.canPlaceOrder
                      ? () => _placeOrder(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.textOnGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: provider.isPlacingOrder
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.textOnGold,
                          ),
                        )
                      : Text(
                          'Đặt hàng • ${provider.total.toVnd}',
                          style: AppTypography.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final provider = context.read<CheckoutProvider>();
    try {
      final order = await provider.placeOrder();
      if (context.mounted) {
        context.go('/checkout/success/${order.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            content: Text('Đặt hàng thất bại: $e'),
          ),
        );
      }
    }
  }
}

/// (c) Empty state khi giỏ hàng trống.
class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.beigeWarm,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 44, color: AppColors.brownAccent),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Giỏ hàng đang trống', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Chọn vài món ngon rồi quay lại thanh toán nhé!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.local_cafe_outlined),
              label: const Text('Xem menu'),
            ),
          ],
        ),
      ),
    );
  }
}
