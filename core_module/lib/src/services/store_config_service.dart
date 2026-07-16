import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/common/app_exception.dart';

/// StoreConfig — Cấu hình cửa hàng (singleton Firestore document).
/// Firestore path: /config/store
class StoreConfig {
  final String storeName;
  final String address;
  final String phone;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final double deliveryFee;
  final double minDeliveryOrder;
  final double loyaltyRate; // VD: 0.01 = 1 điểm / 100đ

  const StoreConfig({
    required this.storeName,
    required this.address,
    required this.phone,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    required this.deliveryFee,
    required this.minDeliveryOrder,
    required this.loyaltyRate,
  });

  factory StoreConfig.fromFirestore(Map<String, dynamic> data) {
    return StoreConfig(
      storeName: data['storeName'] as String? ?? 'Coffee Shop',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      openTime: data['openTime'] as String? ?? '07:00',
      closeTime: data['closeTime'] as String? ?? '22:00',
      isOpen: data['isOpen'] as bool? ?? true,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 15000.0,
      minDeliveryOrder:
          (data['minDeliveryOrder'] as num?)?.toDouble() ?? 50000.0,
      loyaltyRate: (data['loyaltyRate'] as num?)?.toDouble() ?? 0.01,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeName': storeName,
      'address': address,
      'phone': phone,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'deliveryFee': deliveryFee,
      'minDeliveryOrder': minDeliveryOrder,
      'loyaltyRate': loyaltyRate,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Tính điểm loyalty cho một đơn hàng
  int calculateLoyaltyPoints(double orderTotal) {
    return (orderTotal * loyaltyRate).floor();
  }
}

/// StoreConfigService — Đọc/ghi cấu hình cửa hàng (UC-36).
/// Dev 1 owns — không tự sửa ngoài core_module.
class StoreConfigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _configPath = 'config';
  static const _storeDoc = 'store';

  // ─────────────────────────────────────────────
  // UC-36: Lấy & cập nhật cấu hình cửa hàng
  // ─────────────────────────────────────────────

  Future<StoreConfig> getStoreConfig() async {
    try {
      final doc = await _db
          .collection(_configPath)
          .doc(_storeDoc)
          .get();
      if (!doc.exists || doc.data() == null) {
        return const StoreConfig(
          storeName: 'Coffee Shop',
          address: '',
          phone: '',
          openTime: '07:00',
          closeTime: '22:00',
          isOpen: true,
          deliveryFee: 15000,
          minDeliveryOrder: 50000,
          loyaltyRate: 0.01,
        );
      }
      return StoreConfig.fromFirestore(doc.data()!);
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Stream realtime — UI tự update khi admin thay đổi cấu hình
  Stream<StoreConfig> watchStoreConfig() {
    return _db
        .collection(_configPath)
        .doc(_storeDoc)
        .snapshots()
        .map((doc) => doc.exists
            ? StoreConfig.fromFirestore(doc.data()!)
            : const StoreConfig(
                storeName: 'Coffee Shop',
                address: '',
                phone: '',
                openTime: '07:00',
                closeTime: '22:00',
                isOpen: true,
                deliveryFee: 15000,
                minDeliveryOrder: 50000,
                loyaltyRate: 0.01,
              ));
  }

  Future<void> updateStoreConfig(StoreConfig config) async {
    try {
      await _db
          .collection(_configPath)
          .doc(_storeDoc)
          .set(config.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }

  /// Toggle mở/đóng cửa nhanh
  Future<void> toggleStoreOpen(bool isOpen) async {
    try {
      await _db.collection(_configPath).doc(_storeDoc).update({
        'isOpen': isOpen,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException.unknown(e);
    }
  }
}
