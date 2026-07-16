// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  List<OrderItemModel> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get orderType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get deliveryAddress =>
      throw _privateConstructorUsedError;
  String? get voucherCode => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;
  int get loyaltyPointsEarned => throw _privateConstructorUsedError;
  int get loyaltyPointsUsed => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  DateTime? get readyAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
    OrderModel value,
    $Res Function(OrderModel) then,
  ) = _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call({
    String id,
    String customerId,
    String customerName,
    String? customerPhone,
    List<OrderItemModel> items,
    double subtotal,
    double discountAmount,
    double totalAmount,
    String status,
    String orderType,
    Map<String, dynamic>? deliveryAddress,
    String? voucherCode,
    String paymentMethod,
    String paymentStatus,
    String? note,
    String? cancelReason,
    int loyaltyPointsEarned,
    int loyaltyPointsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
  });
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? items = null,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? orderType = null,
    Object? deliveryAddress = freezed,
    Object? voucherCode = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? note = freezed,
    Object? cancelReason = freezed,
    Object? loyaltyPointsEarned = null,
    Object? loyaltyPointsUsed = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? acceptedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItemModel>,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            orderType: null == orderType
                ? _value.orderType
                : orderType // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryAddress: freezed == deliveryAddress
                ? _value.deliveryAddress
                : deliveryAddress // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            voucherCode: freezed == voucherCode
                ? _value.voucherCode
                : voucherCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancelReason: freezed == cancelReason
                ? _value.cancelReason
                : cancelReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            loyaltyPointsEarned: null == loyaltyPointsEarned
                ? _value.loyaltyPointsEarned
                : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            loyaltyPointsUsed: null == loyaltyPointsUsed
                ? _value.loyaltyPointsUsed
                : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            acceptedAt: freezed == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            readyAt: freezed == readyAt
                ? _value.readyAt
                : readyAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
    _$OrderModelImpl value,
    $Res Function(_$OrderModelImpl) then,
  ) = __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerId,
    String customerName,
    String? customerPhone,
    List<OrderItemModel> items,
    double subtotal,
    double discountAmount,
    double totalAmount,
    String status,
    String orderType,
    Map<String, dynamic>? deliveryAddress,
    String? voucherCode,
    String paymentMethod,
    String paymentStatus,
    String? note,
    String? cancelReason,
    int loyaltyPointsEarned,
    int loyaltyPointsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
  });
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
    _$OrderModelImpl _value,
    $Res Function(_$OrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? items = null,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? orderType = null,
    Object? deliveryAddress = freezed,
    Object? voucherCode = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? note = freezed,
    Object? cancelReason = freezed,
    Object? loyaltyPointsEarned = null,
    Object? loyaltyPointsUsed = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? acceptedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
  }) {
    return _then(
      _$OrderModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItemModel>,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        orderType: null == orderType
            ? _value.orderType
            : orderType // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryAddress: freezed == deliveryAddress
            ? _value._deliveryAddress
            : deliveryAddress // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        voucherCode: freezed == voucherCode
            ? _value.voucherCode
            : voucherCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancelReason: freezed == cancelReason
            ? _value.cancelReason
            : cancelReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        loyaltyPointsEarned: null == loyaltyPointsEarned
            ? _value.loyaltyPointsEarned
            : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        loyaltyPointsUsed: null == loyaltyPointsUsed
            ? _value.loyaltyPointsUsed
            : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        acceptedAt: freezed == acceptedAt
            ? _value.acceptedAt
            : acceptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        readyAt: freezed == readyAt
            ? _value.readyAt
            : readyAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl extends _OrderModel {
  const _$OrderModelImpl({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required final List<OrderItemModel> items,
    required this.subtotal,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.status = 'pending',
    this.orderType = 'pickup',
    final Map<String, dynamic>? deliveryAddress,
    this.voucherCode,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'pending',
    this.note,
    this.cancelReason,
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsUsed = 0,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.readyAt,
    this.deliveredAt,
  }) : _items = items,
       _deliveryAddress = deliveryAddress,
       super._();

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String customerName;
  @override
  final String? customerPhone;
  final List<OrderItemModel> _items;
  @override
  List<OrderItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double subtotal;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  final double totalAmount;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String orderType;
  final Map<String, dynamic>? _deliveryAddress;
  @override
  Map<String, dynamic>? get deliveryAddress {
    final value = _deliveryAddress;
    if (value == null) return null;
    if (_deliveryAddress is EqualUnmodifiableMapView) return _deliveryAddress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? voucherCode;
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  final String? note;
  @override
  final String? cancelReason;
  @override
  @JsonKey()
  final int loyaltyPointsEarned;
  @override
  @JsonKey()
  final int loyaltyPointsUsed;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? acceptedAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? deliveredAt;

  @override
  String toString() {
    return 'OrderModel(id: $id, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, items: $items, subtotal: $subtotal, discountAmount: $discountAmount, totalAmount: $totalAmount, status: $status, orderType: $orderType, deliveryAddress: $deliveryAddress, voucherCode: $voucherCode, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, note: $note, cancelReason: $cancelReason, loyaltyPointsEarned: $loyaltyPointsEarned, loyaltyPointsUsed: $loyaltyPointsUsed, createdAt: $createdAt, updatedAt: $updatedAt, acceptedAt: $acceptedAt, readyAt: $readyAt, deliveredAt: $deliveredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            const DeepCollectionEquality().equals(
              other._deliveryAddress,
              _deliveryAddress,
            ) &&
            (identical(other.voucherCode, voucherCode) ||
                other.voucherCode == voucherCode) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.loyaltyPointsEarned, loyaltyPointsEarned) ||
                other.loyaltyPointsEarned == loyaltyPointsEarned) &&
            (identical(other.loyaltyPointsUsed, loyaltyPointsUsed) ||
                other.loyaltyPointsUsed == loyaltyPointsUsed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.readyAt, readyAt) || other.readyAt == readyAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    customerId,
    customerName,
    customerPhone,
    const DeepCollectionEquality().hash(_items),
    subtotal,
    discountAmount,
    totalAmount,
    status,
    orderType,
    const DeepCollectionEquality().hash(_deliveryAddress),
    voucherCode,
    paymentMethod,
    paymentStatus,
    note,
    cancelReason,
    loyaltyPointsEarned,
    loyaltyPointsUsed,
    createdAt,
    updatedAt,
    acceptedAt,
    readyAt,
    deliveredAt,
  ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(this);
  }
}

abstract class _OrderModel extends OrderModel {
  const factory _OrderModel({
    required final String id,
    required final String customerId,
    required final String customerName,
    final String? customerPhone,
    required final List<OrderItemModel> items,
    required final double subtotal,
    final double discountAmount,
    required final double totalAmount,
    final String status,
    final String orderType,
    final Map<String, dynamic>? deliveryAddress,
    final String? voucherCode,
    final String paymentMethod,
    final String paymentStatus,
    final String? note,
    final String? cancelReason,
    final int loyaltyPointsEarned,
    final int loyaltyPointsUsed,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? acceptedAt,
    final DateTime? readyAt,
    final DateTime? deliveredAt,
  }) = _$OrderModelImpl;
  const _OrderModel._() : super._();

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  String get customerName;
  @override
  String? get customerPhone;
  @override
  List<OrderItemModel> get items;
  @override
  double get subtotal;
  @override
  double get discountAmount;
  @override
  double get totalAmount;
  @override
  String get status;
  @override
  String get orderType;
  @override
  Map<String, dynamic>? get deliveryAddress;
  @override
  String? get voucherCode;
  @override
  String get paymentMethod;
  @override
  String get paymentStatus;
  @override
  String? get note;
  @override
  String? get cancelReason;
  @override
  int get loyaltyPointsEarned;
  @override
  int get loyaltyPointsUsed;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get acceptedAt;
  @override
  DateTime? get readyAt;
  @override
  DateTime? get deliveredAt;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
