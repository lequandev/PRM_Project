import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import '../providers/review_provider.dart';

class ReviewModerationScreen extends StatelessWidget {
  const ReviewModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kiểm duyệt Đánh giá',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brownAccent,
                        ),
                      ),
                      Text(
                        'Duyệt hoặc từ chối đánh giá khách hàng • ${provider.pendingReviews.length} chờ duyệt',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Tải lại',
                    onPressed: provider.loadAllReviews,
                  ),
                ],
              ),
              const SizedBox(height: 24),
      
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Text(provider.errorMessage!,
                          style: const TextStyle(color: AppColors.error)),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: provider.clearError),
                    ],
                  ),
                ),

              // TabBar for different review statuses
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                ),
                child: TabBar(
                  labelColor: AppColors.brownAccent,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.brownAccent,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  tabs: [
                    Tab(text: 'Chờ duyệt (${provider.pendingReviews.length})'),
                    Tab(text: 'Đã duyệt (${provider.approvedReviews.length})'),
                    Tab(text: 'Đã từ chối (${provider.rejectedReviews.length})'),
                  ],
                ),
              ),
      
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        children: [
                          _buildList(context, provider.pendingReviews, 'pending'),
                          _buildList(context, provider.approvedReviews, 'approved'),
                          _buildList(context, provider.rejectedReviews, 'rejected'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ReviewWithProduct> list, String status) {
    if (list.isEmpty) {
      String title = '';
      String subtitle = '';
      IconData icon = Icons.check_circle_outline_rounded;
      Color iconColor = AppColors.success;

      if (status == 'pending') {
        title = 'Không có đánh giá chờ duyệt';
        subtitle = 'Tất cả đánh giá đã được xử lý!';
        icon = Icons.check_circle_outline_rounded;
        iconColor = AppColors.success;
      } else if (status == 'approved') {
        title = 'Chưa có đánh giá nào được duyệt';
        subtitle = 'Các đánh giá được chấp nhận sẽ hiển thị ở đây.';
        icon = Icons.rate_review_outlined;
        iconColor = AppColors.textHint;
      } else {
        title = 'Chưa có đánh giá nào bị từ chối';
        subtitle = 'Các đánh giá bị từ chối sẽ hiển thị ở đây.';
        icon = Icons.block_flipped;
        iconColor = AppColors.textHint;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final r = list[i];
        return _ReviewCard(
          reviewWithProduct: r,
          onApprove: () async {
            final ok = await context
                .read<ReviewProvider>()
                .approveReview(r.productId, r.review.id);
            if (ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã duyệt đánh giá'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
          onReject: () async {
            final ok = await context
                .read<ReviewProvider>()
                .rejectReview(r.productId, r.review.id);
            if (ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã từ chối đánh giá'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewWithProduct reviewWithProduct;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ReviewCard({
    required this.reviewWithProduct,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final review = reviewWithProduct.review;
    final productName = reviewWithProduct.productName;

    // Change card border color based on status for better aesthetics
    Color borderColor = AppColors.warningLight;
    if (review.status == 'approved') {
      borderColor = AppColors.success.withValues(alpha: 0.2);
    } else if (review.status == 'rejected') {
      borderColor = AppColors.error.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer + product
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.15),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      productName,
                      style: const TextStyle(
                        color: AppColors.brownAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.goldPrimary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment
          Expanded(
            child: Text(
              review.comment ?? '(Không có bình luận)',
              style: TextStyle(
                color: review.comment != null
                    ? AppColors.textPrimary
                    : AppColors.textHint,
                fontSize: 14,
                fontStyle: review.comment == null ? FontStyle.italic : null,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Actions builder based on status
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final status = reviewWithProduct.review.status;

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.error, size: 16),
              label: const Text('Từ chối',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16),
              label: const Text('Duyệt',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    } else if (status == 'approved') {
      return Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 18),
          const SizedBox(width: 6),
          const Text(
            'Đã duyệt',
            style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.block_rounded,
                color: AppColors.error, size: 14),
            label: const Text('Từ chối lại',
                style: TextStyle(color: AppColors.error, fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(Icons.cancel_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 6),
          const Text(
            'Đã từ chối',
            style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onApprove,
            icon: const Icon(Icons.check_rounded,
                color: Colors.white, size: 14),
            label: const Text('Duyệt lại',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      );
    }
  }
}

