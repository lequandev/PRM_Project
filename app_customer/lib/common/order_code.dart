import 'package:coffee_shop_core/coffee_shop_core.dart';

/// Mã đơn hiển thị cho người dùng: '#' + 5 ký tự cuối của order.id, viết HOA.
///
/// Đồng bộ với cách app_staff hiển thị (order_queue / order_detail) để khách và
/// nhân viên nhìn thấy CÙNG một mã. QR nhận hàng vẫn mã hoá full order.id để
/// scanner tra cứu chính xác — chỉ phần chữ hiển thị mới rút gọn.
extension OrderShortCode on OrderModel {
  String get shortCode {
    final tail = id.length > 5 ? id.substring(id.length - 5) : id;
    return '#${tail.toUpperCase()}';
  }
}
