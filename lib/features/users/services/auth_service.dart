import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. REGISTER
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullname,
    required String phoneNumber,
    DateTime? birthday,
  }) async {
    try {
      // Step 1: Create a user in Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Step 2: Create a UserModel object
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

        // Step 3: Save user information to Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

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
      // Step 1: Authenticate with Firebase Authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Step 2: Retrieve user information from Firestore
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists && doc.data() != null) {
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
    await _auth.signOut();
  }
}
