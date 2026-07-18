import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/order_repository.dart';

/// Bottom sheet đánh giá sản phẩm sau khi đơn hoàn thành (UC-39).
///
/// Mỗi món trong đơn: 5 sao chọn nhanh. Một ô nhận xét chung áp dụng cho
/// tất cả món. Gửi qua [OrderRepository.submitReview] cho từng productId.
class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key, required this.order});

  final OrderModel order;

  /// Mở sheet. Gọi từ bất kỳ đâu: `ReviewSheet.show(context, order)`.
  static Future<void> show(BuildContext context, OrderModel order) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (sheetContext) => Padding(
        // Đẩy sheet lên khi bàn phím mở (đang gõ nhận xét).
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: ReviewSheet(order: order),
      ),
    );
  }

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  /// Item đã khử trùng lặp theo productId (1 review / sản phẩm).
  late final List<OrderItemModel> _items;

  /// productId → số sao (mặc định 5 để thao tác nhanh).
  late final Map<String, int> _ratings;

  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final seen = <String>{};
    _items = widget.order.items
        .where((item) => seen.add(item.productId))
        .toList();
    _ratings = {for (final item in _items) item.productId: 5};
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repository = context.read<OrderRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final comment = _commentController.text.trim();

    setState(() => _submitting = true);
    try {
      for (final item in _items) {
        await repository.submitReview(
          productId: item.productId,
          orderId: widget.order.id,
          rating: _ratings[item.productId] ?? 5,
          comment: comment.isEmpty ? null : comment,
        );
      }
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã đánh giá!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Gửi đánh giá thất bại. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const Text('Đánh giá đơn hàng', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Đơn ${widget.order.id} · Chạm sao để chấm điểm từng món',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),

            // Danh sách món + sao
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final item in _items) ...[
                      _buildItemRow(item),
                      if (item != _items.last)
                        const Divider(
                            height: AppSpacing.md,
                            color: AppColors.borderLight),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Nhận xét chung
            TextField(
              controller: _commentController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Chia sẻ cảm nhận của bạn (không bắt buộc)...',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.backgroundAlt,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.goldPrimary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Nút gửi
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.textOnGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  textStyle: AppTypography.button,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.textOnGold,
                        ),
                      )
                    : const Text('Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    final rating = _ratings[item.productId] ?? 5;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productName,
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var star = 1; star <= 5; star++)
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: _submitting
                      ? null
                      : () => setState(
                          () => _ratings[item.productId] = star),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs / 2),
                    child: Icon(
                      star <= rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 28,
                      color: star <= rating
                          ? AppColors.goldPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
