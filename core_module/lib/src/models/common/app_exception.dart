/// AppException — Custom exception class dùng chung toàn dự án.
/// Dev 1 owns — không tự sửa ngoài core_module.
class AppException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const AppException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'AppException[$code]: $message';
}

/// Auth exceptions
class AuthException extends AppException {
  const AuthException({required super.code, required super.message, super.details});

  factory AuthException.invalidCredentials() => const AuthException(
        code: 'auth/invalid-credentials',
        message: 'Email hoặc mật khẩu không đúng.',
      );

  factory AuthException.emailAlreadyInUse() => const AuthException(
        code: 'auth/email-already-in-use',
        message: 'Email này đã được đăng ký.',
      );

  factory AuthException.userNotFound() => const AuthException(
        code: 'auth/user-not-found',
        message: 'Tài khoản không tồn tại.',
      );

  factory AuthException.weakPassword() => const AuthException(
        code: 'auth/weak-password',
        message: 'Mật khẩu quá yếu. Vui lòng dùng ít nhất 8 ký tự.',
      );

  factory AuthException.networkError() => const AuthException(
        code: 'auth/network-error',
        message: 'Lỗi kết nối mạng. Vui lòng thử lại.',
      );
}

/// Firestore / data exceptions
class DatabaseException extends AppException {
  const DatabaseException({required super.code, required super.message, super.details});

  factory DatabaseException.notFound(String entity) => DatabaseException(
        code: 'db/not-found',
        message: '$entity không tồn tại.',
      );

  factory DatabaseException.permissionDenied() => const DatabaseException(
        code: 'db/permission-denied',
        message: 'Bạn không có quyền thực hiện thao tác này.',
      );

  factory DatabaseException.unknown(dynamic error) => DatabaseException(
        code: 'db/unknown',
        message: 'Đã xảy ra lỗi. Vui lòng thử lại.',
        details: error,
      );
}
