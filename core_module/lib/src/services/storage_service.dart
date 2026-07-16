import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/common/app_exception.dart';

/// StorageService — Upload/delete ảnh lên Firebase Storage.
/// Dev 1 owns — không tự sửa ngoài core_module.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─────────────────────────────────────────────
  // Upload ảnh sản phẩm (Admin — UC-31, UC-32)
  // ─────────────────────────────────────────────

  Future<String> uploadProductImage({
    required String productId,
    required File imageFile,
  }) async {
    return _uploadImage(
      path: 'products/$productId/main.jpg',
      file: imageFile,
    );
  }

  // ─────────────────────────────────────────────
  // Upload avatar người dùng (UC-04)
  // ─────────────────────────────────────────────

  Future<String> uploadUserAvatar({
    required String uid,
    required File imageFile,
  }) async {
    return _uploadImage(
      path: 'users/$uid/avatar.jpg',
      file: imageFile,
    );
  }

  // ─────────────────────────────────────────────
  // Upload ảnh danh mục (Admin)
  // ─────────────────────────────────────────────

  Future<String> uploadCategoryImage({
    required String categoryId,
    required File imageFile,
  }) async {
    return _uploadImage(
      path: 'categories/$categoryId/cover.jpg',
      file: imageFile,
    );
  }

  // ─────────────────────────────────────────────
  // Xóa ảnh
  // ─────────────────────────────────────────────

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // Không throw nếu file không tồn tại — idempotent delete
    }
  }

  // ─────────────────────────────────────────────
  // Helper chung
  // ─────────────────────────────────────────────

  Future<String> _uploadImage({
    required String path,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final task = await ref.putFile(file, metadata);
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw AppException(
        code: 'storage/upload-failed',
        message: 'Không thể tải ảnh lên. Vui lòng thử lại.',
        details: e,
      );
    }
  }
}
