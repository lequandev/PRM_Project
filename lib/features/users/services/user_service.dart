import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload the user's avatar to Firebase Storage and return the public URL
  Future<String> uploadAvatar(String userId, File file) async {
    try {
      final ref = _storage.ref().child('users/$userId/avatar.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload avatar to Firebase Storage: $e');
    }
  }

  /// Update the user's complete profile in Firestore
  Future<void> updateUserProfile({
    required String userId,
    required String fullname,
    required String email,
    required List<SavedAddress> addresses,
    File? avatarFile,
  }) async {
    try {
      String? newAvatarUrl;

      // If the user selected a new avatar, upload it to Firebase Storage first
      if (avatarFile != null) {
        newAvatarUrl = await uploadAvatar(userId, avatarFile);
      }

      final Map<String, dynamic> updateData = {
        'fullname': fullname,
        'email': email,
        'saved_addresses': addresses.map((e) => e.toMap()).toList(),
        'update_at': Timestamp.now(),
      };

      // Only update the avatar field if a new avatar has been uploaded
      if (newAvatarUrl != null) {
        updateData['avatar_url'] = newAvatarUrl;
      }

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile in Firestore: $e');
    }
  }
}
