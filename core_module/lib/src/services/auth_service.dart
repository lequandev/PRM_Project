import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/common/app_exception.dart';

/// AuthService — Xử lý toàn bộ authentication (UC-01, UC-02, UC-03).
/// Dev 1 owns — không tự sửa ngoài core_module.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream theo dõi trạng thái đăng nhập realtime
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Lấy user hiện tại (null nếu chưa đăng nhập)
  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────
  // UC-01: Đăng ký tài khoản mới
  // ─────────────────────────────────────────────

  /// Đăng ký customer mới với email + password.
  /// Tạo document trong /users/{uid} sau khi đăng ký thành công.
  Future<UserModel> registerCustomer({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Cập nhật displayName trên Firebase Auth
      await user.updateDisplayName(name);

      // Tạo document Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        name: name,
        role: 'customer',
        phone: phone,
        loyaltyPoints: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db
          .collection('users')
          .doc(user.uid)
          .set(UserModel.toFirestore(userModel));

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  // ─────────────────────────────────────────────
  // UC-02: Đăng nhập (RBAC)
  // ─────────────────────────────────────────────

  /// Đăng nhập bằng email + password.
  /// Trả về UserModel kèm role để app navigate đúng màn hình.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      return await _fetchUserModel(uid);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  // ─────────────────────────────────────────────
  // UC-03: Đặt lại mật khẩu (OTP / Email)
  // ─────────────────────────────────────────────

  /// Gửi email đặt lại mật khẩu.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // ─────────────────────────────────────────────
  // Đăng xuất
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // Helpers nội bộ
  // ─────────────────────────────────────────────

  /// Lấy UserModel từ Firestore theo uid
  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw DatabaseException.notFound('Tài khoản');
    }
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  /// Map FirebaseAuthException → AppException tiếng Việt
  AppException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse();
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'network-request-failed':
        return AuthException.networkError();
      default:
        return AppException(
          code: 'auth/${e.code}',
          message: e.message ?? 'Lỗi xác thực không xác định.',
        );
    }
  }
}
