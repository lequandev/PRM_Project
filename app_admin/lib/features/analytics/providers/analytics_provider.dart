import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// AnalyticsProvider — Doanh thu (UC-37) + Sản phẩm bán chạy (UC-38).
class AnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Date range
  DateTime _from = DateTime.now().subtract(const Duration(days: 7));
  DateTime _to = DateTime.now();

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get from => _from;
  DateTime get to => _to;

  // ─── Computed ─────────────────────────────────────────────────────────────

  double get totalRevenue =>
      _orders.where((o) => o.status == 'delivered').fold(0, (s, o) => s + o.totalAmount);

  int get totalOrders => _orders.length;
  int get deliveredOrders => _orders.where((o) => o.status == 'delivered').length;

  double get avgOrderValue =>
      deliveredOrders == 0 ? 0 : totalRevenue / deliveredOrders;

  /// Doanh thu theo từng ngày trong khoảng (cho line chart)
  List<DailyRevenue> get dailyRevenue {
    final Map<String, double> map = {};
    final days = _to.difference(_from).inDays + 1;

    for (int i = 0; i < days; i++) {
      final d = _from.add(Duration(days: i));
      final key = '${d.day}/${d.month}';
      map[key] = 0;
    }

    for (final order in _orders) {
      if (order.status != 'delivered') continue;
      final d = order.createdAt;
      if (d == null) continue;
      final key = '${d.day}/${d.month}';
      map[key] = (map[key] ?? 0) + order.totalAmount;
    }

    return map.entries
        .map((e) => DailyRevenue(label: e.key, revenue: e.value))
        .toList();
  }

  /// Top 10 sản phẩm bán chạy nhất
  List<ProductStat> get topProducts {
    final Map<String, ProductStat> map = {};

    for (final order in _orders) {
      if (order.status != 'delivered') continue;
      for (final item in order.items) {
        final existing = map[item.productId];
        if (existing != null) {
          map[item.productId] = ProductStat(
            productId: item.productId,
            name: item.productName,
            totalQuantity: existing.totalQuantity + item.quantity,
            totalRevenue: existing.totalRevenue + item.totalPrice,
          );
        } else {
          map[item.productId] = ProductStat(
            productId: item.productId,
            name: item.productName,
            totalQuantity: item.quantity,
            totalRevenue: item.totalPrice,
          );
        }
      }
    }

    final list = map.values.toList()
      ..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return list.take(10).toList();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  AnalyticsProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadOrders();
      } else {
        _orders = [];
        notifyListeners();
      }
    });
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final startTs = Timestamp.fromDate(
          DateTime(_from.year, _from.month, _from.day));
      final endTs = Timestamp.fromDate(
          DateTime(_to.year, _to.month, _to.day, 23, 59, 59));

      final snap = await _db
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startTs)
          .where('createdAt', isLessThanOrEqualTo: endTs)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snap.docs
          .map((doc) {
            try {
              return OrderModel.fromFirestore(doc.data(), doc.id);
            } catch (e) {
              AppLogger.error('Lỗi parse đơn hàng ${doc.id}: $e');
              return null;
            }
          })
          .whereType<OrderModel>()
          .toList();
    } catch (e) {
      _errorMessage = 'Lỗi tải dữ liệu: $e';
      AppLogger.error('AnalyticsProvider.loadOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange(DateTime from, DateTime to) {
    _from = from;
    _to = to;
    loadOrders();
  }

  void setPreset(String preset) {
    final now = DateTime.now();
    switch (preset) {
      case '7d':
        _from = now.subtract(const Duration(days: 6));
        _to = now;
        break;
      case '30d':
        _from = now.subtract(const Duration(days: 29));
        _to = now;
        break;
      case 'today':
        _from = DateTime(now.year, now.month, now.day);
        _to = now;
        break;
    }
    loadOrders();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

class DailyRevenue {
  final String label;
  final double revenue;
  const DailyRevenue({required this.label, required this.revenue});
}

class ProductStat {
  final String productId;
  final String name;
  final int totalQuantity;
  final double totalRevenue;
  const ProductStat({
    required this.productId,
    required this.name,
    required this.totalQuantity,
    required this.totalRevenue,
  });
}
