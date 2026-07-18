import 'package:coffee_shop_core/coffee_shop_core.dart';

import 'app_session.dart';
import 'fake_seed.dart';

/// Hồ sơ hiển thị trên màn Profile (UC-04).
class ProfileData {
  const ProfileData({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.loyaltyPoints,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final int loyaltyPoints;

  ProfileData copyWith({String? name, String? phone, String? avatarUrl, int? loyaltyPoints}) {
    return ProfileData(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }
}

/// ProfileRepository — UC-03 (reset password), UC-04/05/06, UC-27/28.
///
/// Bản thật: UserService (updateProfile, addresses, deactivateAccount) +
/// AuthService.sendPasswordResetEmail (đã implement trong core) +
/// loyaltyTransactions. UI không đổi khi swap.
abstract class ProfileRepository {
  Future<ProfileData> getProfile(String uid);

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? avatarUrl,
  });

  Future<List<AddressModel>> getAddresses(String uid);

  Future<AddressModel> addAddress({required String uid, required AddressModel address});

  Future<void> updateAddress({required String uid, required AddressModel address});

  Future<void> deleteAddress({required String uid, required String addressId});

  /// UC-06 — GDPR. Bản fake chỉ giả lập; bản thật gọi UserService.deactivateAccount.
  Future<void> deactivateAccount(String uid);

  /// UC-03 — bản thật gọi AuthService.sendPasswordResetEmail (đã chạy được).
  Future<void> sendPasswordResetEmail(String email);

  // UC-27/28
  Future<int> getLoyaltyPoints(String uid);

  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactions(String uid);

  /// Đổi [points] điểm lấy voucher — trả về mã voucher nhận được.
  Future<String> redeemPoints({required String uid, required int points});
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository() {
    _profile = const ProfileData(
      uid: AppSession.uid,
      name: AppSession.name,
      email: AppSession.email,
      phone: AppSession.phone,
      loyaltyPoints: FakeSeed.loyaltyPoints,
    );
    _addresses.addAll(FakeSeed.addresses);
    _transactions.addAll(FakeSeed.loyaltyTransactions());
  }

  late ProfileData _profile;
  final List<AddressModel> _addresses = [];
  final List<LoyaltyTransactionModel> _transactions = [];
  int _addressSeq = 0;
  int _txSeq = 10;

  static const _latency = Duration(milliseconds: 350);

  @override
  Future<ProfileData> getProfile(String uid) async {
    await Future.delayed(_latency);
    return _profile;
  }

  @override
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    await Future.delayed(_latency);
    _profile = _profile.copyWith(name: name, phone: phone, avatarUrl: avatarUrl);
  }

  @override
  Future<List<AddressModel>> getAddresses(String uid) async {
    await Future.delayed(_latency);
    return List.unmodifiable(_addresses);
  }

  @override
  Future<AddressModel> addAddress(
      {required String uid, required AddressModel address}) async {
    await Future.delayed(_latency);
    final created = address.copyWith(id: 'a_new_${_addressSeq++}');
    if (created.isDefault) _clearDefault();
    _addresses.add(created);
    return created;
  }

  @override
  Future<void> updateAddress(
      {required String uid, required AddressModel address}) async {
    await Future.delayed(_latency);
    final i = _addresses.indexWhere((a) => a.id == address.id);
    if (i < 0) throw Exception('Không tìm thấy địa chỉ');
    if (address.isDefault) _clearDefault();
    _addresses[i] = address;
  }

  @override
  Future<void> deleteAddress(
      {required String uid, required String addressId}) async {
    await Future.delayed(_latency);
    _addresses.removeWhere((a) => a.id == addressId);
  }

  @override
  Future<void> deactivateAccount(String uid) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<int> getLoyaltyPoints(String uid) async {
    await Future.delayed(_latency);
    return _profile.loyaltyPoints;
  }

  @override
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactions(
      String uid) async {
    await Future.delayed(_latency);
    return List.unmodifiable(_transactions);
  }

  @override
  Future<String> redeemPoints(
      {required String uid, required int points}) async {
    await Future.delayed(_latency);
    if (points > _profile.loyaltyPoints) {
      throw Exception('Không đủ điểm để đổi.');
    }
    _profile = _profile.copyWith(loyaltyPoints: _profile.loyaltyPoints - points);
    _transactions.insert(
      0,
      LoyaltyTransactionModel(
        id: 'tx${_txSeq++}',
        type: 'redeem',
        points: -points,
        description: 'Đổi $points điểm lấy voucher',
        createdAt: DateTime.now(),
      ),
    );
    return 'GIAM15K';
  }

  void _clearDefault() {
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
  }
}
