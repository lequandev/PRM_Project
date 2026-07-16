import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// ReviewModel — Đánh giá sản phẩm của khách hàng.
/// Map với Firestore subcollection: /products/{productId}/reviews/{reviewId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    required String userId,
    required String userName,   // Snapshot — không link dynamic
    required String orderId,    // Bắt buộc đã mua mới review
    required int rating,        // 1–5
    String? comment,
    @Default('pending') String status, // 'pending' | 'approved' | 'rejected'
    DateTime? createdAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Khách hàng',
      orderId: data['orderId'] as String? ?? '',
      rating: data['rating'] as int? ?? 5,
      comment: data['comment'] as String?,
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  static Map<String, dynamic> toFirestore(ReviewModel review) {
    return {
      'userId': review.userId,
      'userName': review.userName,
      'orderId': review.orderId,
      'rating': review.rating,
      if (review.comment != null) 'comment': review.comment,
      'status': review.status,
      'createdAt': DateTime.now(),
    };
  }
}
