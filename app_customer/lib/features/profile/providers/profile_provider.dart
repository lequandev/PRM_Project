import 'package:flutter/foundation.dart';

import '../../../data/app_session.dart';
import '../../../data/profile_repository.dart';

/// ProfileProvider — UC-03 (reset password), UC-04 (hồ sơ), UC-06 (xóa tài khoản).
///
/// Nhận [ProfileRepository] qua constructor (quy ước nhóm: provider + ChangeNotifier,
/// UI không gọi thẳng service). MOCK MODE dùng FakeProfileRepository.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  ProfileData? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  ProfileData? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  /// UC-04 — tải hồ sơ hiện tại.
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.getProfile(AppSession.uid);
    } catch (e) {
      _error = 'Không tải được hồ sơ. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// UC-04 — cập nhật tên/SĐT rồi reload hồ sơ. Trả về true nếu thành công.
  Future<bool> updateProfile({String? name, String? phone}) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateProfile(
        uid: AppSession.uid,
        name: name,
        phone: phone,
      );
      _profile = await _repository.getProfile(AppSession.uid);
      return true;
    } catch (e) {
      _error = 'Cập nhật hồ sơ thất bại. Vui lòng thử lại.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// UC-06 — GDPR: vô hiệu hóa tài khoản (soft-delete).
  /// Bản thật gọi UserService.deactivateAccount qua repository.
  Future<bool> deactivateAccount() async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deactivateAccount(AppSession.uid);
      return true;
    } catch (e) {
      _error = 'Không thể xóa tài khoản. Vui lòng thử lại.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// UC-03 — gửi email đặt lại mật khẩu.
  /// Bản thật: AuthService.sendPasswordResetEmail của core (đã implement).
  Future<bool> sendPasswordResetEmail(String email) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = 'Gửi email thất bại. Vui lòng thử lại.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
