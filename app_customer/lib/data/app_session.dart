/// Phiên đăng nhập giả lập cho chế độ demo.
///
/// app_customer chưa có firebase_options.dart (chưa chạy flutterfire configure)
/// nên toàn bộ app chạy MOCK MODE — không khởi tạo Firebase.
/// Khi Dev 1 cấu hình Firebase cho app này, thay AppSession bằng AuthProvider
/// thật (AuthService.authStateChanges + UserService.getUserById).
class AppSession {
  AppSession._();

  static const String uid = 'u_demo_dev3';
  static const String name = 'Nguyễn Cửu Toàn';
  static const String email = 'cuutoan.nguyen@gmail.com';
  static const String phone = '0905 123 456';
}
