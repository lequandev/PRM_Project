import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL của payment server (máy Linux ở nhà bạn, sau nginx).
/// ⚠️ TODO: đổi thành subdomain THẬT của bạn trước khi test.
const String kPaymentServerBaseUrl = 'https://pay.toandz.id.vn';

/// Kết quả tạo thanh toán từ server PayOS.
class PaymentCreateResult {
  const PaymentCreateResult({required this.checkoutUrl, required this.qrCode});

  /// Trang thanh toán PayOS đầy đủ (mở bằng WebView/browser nếu muốn).
  final String checkoutUrl;

  /// Chuỗi VietQR — render bằng qr_flutter để khách quét bằng app ngân hàng.
  final String qrCode;
}

/// PaymentService — gọi payment server để tạo link/QR PayOS (UC-16).
///
/// App KHÔNG gọi PayOS trực tiếp (secret key phải ở server). App chỉ gọi server
/// này lấy QR, rồi NGHE đơn của mình trên Firestore để biết đã trả tiền
/// (paymentStatus flip sang 'paid' qua webhook).
class PaymentService {
  const PaymentService({this.baseUrl = kPaymentServerBaseUrl});

  final String baseUrl;

  Future<PaymentCreateResult> createPayment({
    required String orderId,
    required double amount,
    String? description,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/create-payment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'orderId': orderId,
            'amount': amount.round(), // VND số nguyên
            if (description != null) 'description': description,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('Server tạo thanh toán lỗi (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return PaymentCreateResult(
      checkoutUrl: body['checkoutUrl'] as String? ?? '',
      qrCode: body['qrCode'] as String? ?? '',
    );
  }
}
