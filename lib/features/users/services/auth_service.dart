import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- THÊM MỚI
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Key dùng để lưu trữ dưới Local Storage
  static const String _userIdKey = "cached_user_id";

  // 1. REGISTER
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullname,
    required String phoneNumber,
    DateTime? birthday,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        UserModel newUser = UserModel(
          id: firebaseUser.uid,
          fullname: fullname,
          email: email,
          phoneNumber: phoneNumber,
          birthday: birthday,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
          isActive: true,
          role: UserRole.CUSTOMER,
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        // Caching Session local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userIdKey, firebaseUser.uid);

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Error (Register): ${e.message}");
      rethrow;
    } catch (e) {
      print("System Error During Registration: $e");
      rethrow;
    }
    return null;
  }

  // 2. LOGIN
  Future<UserModel?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          // Caching Session local khi login thành công
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userIdKey, firebaseUser.uid);

          return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Error (Login): ${e.message}");
      rethrow;
    } catch (e) {
      print("System Error During Login: $e");
      rethrow;
    }
    return null;
  }

  // 3. LOGOUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Xóa sạch session dưới local storage khi thoát ứng dụng
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    } catch (e) {
      print("Error during sign out: $e");
      rethrow;
    }
  }

  // 4. CHECK PERSISTED SESSION (Hàm bổ trợ kiểm tra trạng thái login cũ)
  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}
