import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/foundation.dart';

import '../../../data/app_session.dart';
import '../../../data/profile_repository.dart';

/// LoyaltyProvider — UC-27 (xem điểm + lịch sử), UC-28 (đổi điểm lấy voucher).
class LoyaltyProvider extends ChangeNotifier {
  LoyaltyProvider(this._repository);

  /// Số điểm cần cho 1 lần đổi voucher.
  static const int redeemCost = 500;

  final ProfileRepository _repository;

  int _points = 0;
  List<LoyaltyTransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isRedeeming = false;
  String? _error;

  int get points => _points;
  List<LoyaltyTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isRedeeming => _isRedeeming;
  String? get error => _error;
  bool get canRedeem => _points >= redeemCost && !_isRedeeming;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getLoyaltyPoints(AppSession.uid),
        _repository.getLoyaltyTransactions(AppSession.uid),
      ]);
      _points = results[0] as int;
      _transactions = results[1] as List<LoyaltyTransactionModel>;
    } catch (e) {
      _error = 'Không tải được điểm thưởng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// UC-28 — đổi [redeemCost] điểm, trả về mã voucher (null nếu lỗi).
  /// Reload điểm + lịch sử sau khi đổi thành công.
  Future<String?> redeemPoints() async {
    _isRedeeming = true;
    _error = null;
    notifyListeners();
    try {
      final code = await _repository.redeemPoints(
        uid: AppSession.uid,
        points: redeemCost,
      );
      await load();
      return code;
    } catch (e) {
      _error = 'Đổi điểm thất bại. Vui lòng thử lại.';
      return null;
    } finally {
      _isRedeeming = false;
      notifyListeners();
    }
  }
}
