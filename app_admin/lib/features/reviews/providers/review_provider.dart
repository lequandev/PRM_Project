import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// ReviewProvider — Kiểm duyệt đánh giá (UC-40).
class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  List<ReviewWithProduct> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReviewWithProduct> get reviews => _reviews;
  List<ReviewWithProduct> get pendingReviews =>
      _reviews.where((r) => r.review.status == 'pending').toList();
  List<ReviewWithProduct> get approvedReviews =>
      _reviews.where((r) => r.review.status == 'approved').toList();
  List<ReviewWithProduct> get rejectedReviews =>
      _reviews.where((r) => r.review.status == 'rejected').toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReviewProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadAllReviews();
      } else {
        _reviews = [];
        notifyListeners();
      }
    });
  }

  Future<void> loadAllReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch all products to query their reviews subcollections
      final productsSnap = await _db.collection('products').get();
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];

      for (final doc in productsSnap.docs) {
        futures.add(doc.reference
            .collection('reviews')
            .get());
      }

      // 2. Fetch all subcollection reviews in parallel
      final snaps = await Future.wait(futures);

      final List<ReviewWithProduct> tempReviews = [];
      for (int i = 0; i < snaps.length; i++) {
        final productDoc = productsSnap.docs[i];
        final productId = productDoc.id;
        final productName =
            productDoc.data()['name'] as String? ?? 'Sản phẩm #$productId';

        for (final doc in snaps[i].docs) {
          final review = ReviewModel.fromFirestore(doc.data(), doc.id);
          final docProdName = doc.data()['productName'] as String?;
          tempReviews.add(ReviewWithProduct(
            review: review,
            productId: productId,
            productName: docProdName ?? productName,
          ));
        }
      }

      _reviews = tempReviews;

      // 3. Sort by createdAt descending client-side (null-safe)
      _reviews.sort((a, b) {
        final aTime = a.review.createdAt ?? DateTime(0);
        final bTime = b.review.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      _errorMessage = 'Lỗi tải đánh giá: $e';
      AppLogger.error('ReviewProvider.loadAllReviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveReview(String productId, String reviewId) async {
    return _updateStatus(productId, reviewId, 'approved');
  }

  Future<bool> rejectReview(String productId, String reviewId) async {
    return _updateStatus(productId, reviewId, 'rejected');
  }

  Future<bool> _updateStatus(
      String productId, String reviewId, String status) async {
    try {
      await _db
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId)
          .update({'status': status});

      await loadAllReviews();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật đánh giá: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

class ReviewWithProduct {
  final ReviewModel review;
  final String productId;
  final String productName;

  const ReviewWithProduct({
    required this.review,
    required this.productId,
    required this.productName,
  });
}
