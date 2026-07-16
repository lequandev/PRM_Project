// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loyalty_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoyaltyTransactionModel _$LoyaltyTransactionModelFromJson(
  Map<String, dynamic> json,
) {
  return _LoyaltyTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'earn' | 'redeem'
  int get points =>
      throw _privateConstructorUsedError; // dương = tích, âm = đổi
  String get description => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyTransactionModelCopyWith<LoyaltyTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyTransactionModelCopyWith<$Res> {
  factory $LoyaltyTransactionModelCopyWith(
    LoyaltyTransactionModel value,
    $Res Function(LoyaltyTransactionModel) then,
  ) = _$LoyaltyTransactionModelCopyWithImpl<$Res, LoyaltyTransactionModel>;
  @useResult
  $Res call({
    String id,
    String type,
    int points,
    String description,
    String? orderId,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$LoyaltyTransactionModelCopyWithImpl<
  $Res,
  $Val extends LoyaltyTransactionModel
>
    implements $LoyaltyTransactionModelCopyWith<$Res> {
  _$LoyaltyTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? orderId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoyaltyTransactionModelImplCopyWith<$Res>
    implements $LoyaltyTransactionModelCopyWith<$Res> {
  factory _$$LoyaltyTransactionModelImplCopyWith(
    _$LoyaltyTransactionModelImpl value,
    $Res Function(_$LoyaltyTransactionModelImpl) then,
  ) = __$$LoyaltyTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    int points,
    String description,
    String? orderId,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$LoyaltyTransactionModelImplCopyWithImpl<$Res>
    extends
        _$LoyaltyTransactionModelCopyWithImpl<
          $Res,
          _$LoyaltyTransactionModelImpl
        >
    implements _$$LoyaltyTransactionModelImplCopyWith<$Res> {
  __$$LoyaltyTransactionModelImplCopyWithImpl(
    _$LoyaltyTransactionModelImpl _value,
    $Res Function(_$LoyaltyTransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? orderId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LoyaltyTransactionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: freezed == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoyaltyTransactionModelImpl implements _LoyaltyTransactionModel {
  const _$LoyaltyTransactionModelImpl({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    this.orderId,
    this.createdAt,
  });

  factory _$LoyaltyTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  // 'earn' | 'redeem'
  @override
  final int points;
  // dương = tích, âm = đổi
  @override
  final String description;
  @override
  final String? orderId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'LoyaltyTransactionModel(id: $id, type: $type, points: $points, description: $description, orderId: $orderId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    points,
    description,
    orderId,
    createdAt,
  );

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyTransactionModelImplCopyWith<_$LoyaltyTransactionModelImpl>
  get copyWith =>
      __$$LoyaltyTransactionModelImplCopyWithImpl<
        _$LoyaltyTransactionModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyTransactionModelImplToJson(this);
  }
}

abstract class _LoyaltyTransactionModel implements LoyaltyTransactionModel {
  const factory _LoyaltyTransactionModel({
    required final String id,
    required final String type,
    required final int points,
    required final String description,
    final String? orderId,
    final DateTime? createdAt,
  }) = _$LoyaltyTransactionModelImpl;

  factory _LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) =
      _$LoyaltyTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // 'earn' | 'redeem'
  @override
  int get points; // dương = tích, âm = đổi
  @override
  String get description;
  @override
  String? get orderId;
  @override
  DateTime? get createdAt;

  /// Create a copy of LoyaltyTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyTransactionModelImplCopyWith<_$LoyaltyTransactionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
