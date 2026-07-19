import 'package:flutter/material.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';

/// NotificationProvider — Gửi Push Notification (UC-30).
/// Mock implementation: Dev 1 sẽ cung cấp Firebase Functions endpoint sau.
class NotificationProvider extends ChangeNotifier {
  bool _isSending = false;
  String? _errorMessage;
  String? _successMessage;

  final List<NotificationRecord> _history = [
    NotificationRecord(
      title: 'Ưu đãi cuối tuần 🎉',
      body: 'Giảm 20% tất cả đồ uống từ 14h-20h thứ 7 này!',
      target: 'all',
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationRecord(
      title: 'Thêm sản phẩm mới!',
      body: 'Trà Oolong Sữa Muối vừa ra mắt, thử ngay nhé!',
      target: 'all',
      sentAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<NotificationRecord> get history =>
      List.unmodifiable(_history);

  Future<bool> sendNotification({
    required String title,
    required String body,
    required String target, // 'all' | 'customer'
  }) async {
    _isSending = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // TODO: Thay bằng Firebase Functions endpoint khi Dev 1 cung cấp
      // await http.post('https://.../sendNotification', body: {...})
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _history.insert(
        0,
        NotificationRecord(
          title: title,
          body: body,
          target: target,
          sentAt: DateTime.now(),
        ),
      );
      _successMessage = 'Đã gửi thông báo thành công!';
      AppLogger.info('Notification sent: $title → $target');
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi gửi thông báo: $e';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

class NotificationRecord {
  final String title;
  final String body;
  final String target;
  final DateTime sentAt;

  NotificationRecord({
    required this.title,
    required this.body,
    required this.target,
    required this.sentAt,
  });
}
