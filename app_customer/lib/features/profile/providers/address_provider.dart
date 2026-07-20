import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/foundation.dart';

import '../../../data/session.dart';
import '../../../data/profile_repository.dart';

/// AddressProvider — UC-05: CRUD địa chỉ đã lưu.
///
/// Nhận [ProfileRepository] qua constructor. Sau mỗi thao tác ghi đều reload
/// danh sách để UI luôn khớp nguồn dữ liệu (repo tự xử lý logic bỏ default cũ).
class AddressProvider extends ChangeNotifier {
  AddressProvider(this._repository, this._session);

  final ProfileRepository _repository;
  final CurrentSession _session;

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _repository.getAddresses(_session.uid);
    } catch (e) {
      _error = 'Không tải được danh sách địa chỉ.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm mới — truyền address với id rỗng, repo tự sinh id.
  Future<bool> addAddress(AddressModel address) async {
    return _mutate(() async {
      await _repository.addAddress(uid: _session.uid, address: address);
    });
  }

  /// Sửa — giữ nguyên id của address cũ.
  Future<bool> updateAddress(AddressModel address) async {
    return _mutate(() async {
      await _repository.updateAddress(uid: _session.uid, address: address);
    });
  }

  Future<bool> deleteAddress(String addressId) async {
    return _mutate(() async {
      await _repository.deleteAddress(
        uid: _session.uid,
        addressId: addressId,
      );
    });
  }

  /// Đặt làm mặc định — update với isDefault: true, repo tự bỏ default cũ.
  Future<bool> setDefault(AddressModel address) async {
    return updateAddress(address.copyWith(isDefault: true));
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _addresses = await _repository.getAddresses(_session.uid);
      return true;
    } catch (e) {
      _error = 'Thao tác thất bại. Vui lòng thử lại.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
