import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

/// AddressModel — Địa chỉ giao hàng đã lưu của customer.
/// Map với Firestore subcollection: /users/{uid}/addresses/{addressId}
/// Dev 1 owns — không tự sửa ngoài core_module.
@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    required String label,    // 'Nhà' | 'Cơ quan' | custom
    required String street,
    required String ward,
    required String district,
    required String city,
    @Default(false) bool isDefault,
    double? lat,
    double? lng,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  factory AddressModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AddressModel(
      id: id,
      label: data['label'] as String? ?? 'Địa chỉ',
      street: data['street'] as String? ?? '',
      ward: data['ward'] as String? ?? '',
      district: data['district'] as String? ?? '',
      city: data['city'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> toFirestore(AddressModel address) {
    return {
      'label': address.label,
      'street': address.street,
      'ward': address.ward,
      'district': address.district,
      'city': address.city,
      'isDefault': address.isDefault,
      if (address.lat != null) 'lat': address.lat,
      if (address.lng != null) 'lng': address.lng,
    };
  }
}
