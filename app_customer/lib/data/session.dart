import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'app_session.dart';

/// Danh tính người dùng hiện tại cho các provider của Dev 3.
///
/// - Firebase sẵn sàng: map từ [UserModel] của AuthProvider — uid THẬT,
///   bắt buộc vì security rules đối chiếu `customerId == request.auth.uid`.
/// - Demo mode (không Firebase): hằng số [AppSession].
class CurrentSession {
  const CurrentSession({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
  });

  const CurrentSession.demo()
      : uid = AppSession.uid,
        name = AppSession.name,
        email = AppSession.email,
        phone = AppSession.phone;

  factory CurrentSession.fromUser(UserModel? user) {
    if (user == null) return const CurrentSession.demo();
    return CurrentSession(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
    );
  }

  final String uid;
  final String name;
  final String email;
  final String? phone;
}
