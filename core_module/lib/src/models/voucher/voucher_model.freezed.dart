// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VoucherModel _$VoucherModelFromJson(Map<String, dynamic> json) {
  return _VoucherModel.fromJson(json);
}

/// @nodoc
mixin _$VoucherModel {
  String get code => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get discountType =>
      throw _privateConstructorUsedError; // 'percentage' | 'fixed'
  double get discountValue => throw _privateConstructorUsedError; // % hoặc VND
  double? get maxDiscountAmount =>
      throw _privateConstructorUsedError; // Trần giảm tối đa (cho loại %)
  double get minOrderValue => throw _privateConstructorUsedError;
  int? get usageLimit =>
      throw _privateConstructorUsedError; // null = không giới hạn
  int get usageCount => throw _privateConstructorUsedError;
  int get perUserLimit => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this VoucherModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoucherModelCopyWith<VoucherModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoucherModelCopyWith<$Res> {
  factory $VoucherModelCopyWith(
    VoucherModel value,
    $Res Function(VoucherModel) then,
  ) = _$VoucherModelCopyWithImpl<$Res, VoucherModel>;
  @useResult
  $Res call({
    String code,
    String description,
    String discountType,
    double discountValue,
    double? maxDiscountAmount,
    double minOrderValue,
    int? usageLimit,
    int usageCount,
    int perUserLimit,
    bool isActive,
    DateTime startDate,
    DateTime expiresAt,
    String? createdBy,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$VoucherModelCopyWithImpl<$Res, $Val extends VoucherModel>
    implements $VoucherModelCopyWith<$Res> {
  _$VoucherModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? description = null,
    Object? discountType = null,
    Object? discountValue = null,
    Object? maxDiscountAmount = freezed,
    Object? minOrderValue = null,
    Object? usageLimit = freezed,
    Object? usageCount = null,
    Object? perUserLimit = null,
    Object? isActive = null,
    Object? startDate = null,
    Object? expiresAt = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            discountType: null == discountType
                ? _value.discountType
                : discountType // ignore: cast_nullable_to_non_nullable
                      as String,
            discountValue: null == discountValue
                ? _value.discountValue
                : discountValue // ignore: cast_nullable_to_non_nullable
                      as double,
            maxDiscountAmount: freezed == maxDiscountAmount
                ? _value.maxDiscountAmount
                : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            minOrderValue: null == minOrderValue
                ? _value.minOrderValue
                : minOrderValue // ignore: cast_nullable_to_non_nullable
                      as double,
            usageLimit: freezed == usageLimit
                ? _value.usageLimit
                : usageLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            perUserLimit: null == perUserLimit
                ? _value.perUserLimit
                : perUserLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
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
abstract class _$$VoucherModelImplCopyWith<$Res>
    implements $VoucherModelCopyWith<$Res> {
  factory _$$VoucherModelImplCopyWith(
    _$VoucherModelImpl value,
    $Res Function(_$VoucherModelImpl) then,
  ) = __$$VoucherModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String description,
    String discountType,
    double discountValue,
    double? maxDiscountAmount,
    double minOrderValue,
    int? usageLimit,
    int usageCount,
    int perUserLimit,
    bool isActive,
    DateTime startDate,
    DateTime expiresAt,
    String? createdBy,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$VoucherModelImplCopyWithImpl<$Res>
    extends _$VoucherModelCopyWithImpl<$Res, _$VoucherModelImpl>
    implements _$$VoucherModelImplCopyWith<$Res> {
  __$$VoucherModelImplCopyWithImpl(
    _$VoucherModelImpl _value,
    $Res Function(_$VoucherModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? description = null,
    Object? discountType = null,
    Object? discountValue = null,
    Object? maxDiscountAmount = freezed,
    Object? minOrderValue = null,
    Object? usageLimit = freezed,
    Object? usageCount = null,
    Object? perUserLimit = null,
    Object? isActive = null,
    Object? startDate = null,
    Object? expiresAt = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$VoucherModelImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        discountType: null == discountType
            ? _value.discountType
            : discountType // ignore: cast_nullable_to_non_nullable
                  as String,
        discountValue: null == discountValue
            ? _value.discountValue
            : discountValue // ignore: cast_nullable_to_non_nullable
                  as double,
        maxDiscountAmount: freezed == maxDiscountAmount
            ? _value.maxDiscountAmount
            : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        minOrderValue: null == minOrderValue
            ? _value.minOrderValue
            : minOrderValue // ignore: cast_nullable_to_non_nullable
                  as double,
        usageLimit: freezed == usageLimit
            ? _value.usageLimit
            : usageLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        perUserLimit: null == perUserLimit
            ? _value.perUserLimit
            : perUserLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
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
class _$VoucherModelImpl extends _VoucherModel {
  const _$VoucherModelImpl({
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minOrderValue = 0.0,
    this.usageLimit,
    this.usageCount = 0,
    this.perUserLimit = 1,
    this.isActive = true,
    required this.startDate,
    required this.expiresAt,
    this.createdBy,
    this.createdAt,
  }) : super._();

  factory _$VoucherModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoucherModelImplFromJson(json);

  @override
  final String code;
  @override
  final String description;
  @override
  final String discountType;
  // 'percentage' | 'fixed'
  @override
  final double discountValue;
  // % hoặc VND
  @override
  final double? maxDiscountAmount;
  // Trần giảm tối đa (cho loại %)
  @override
  @JsonKey()
  final double minOrderValue;
  @override
  final int? usageLimit;
  // null = không giới hạn
  @override
  @JsonKey()
  final int usageCount;
  @override
  @JsonKey()
  final int perUserLimit;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime startDate;
  @override
  final DateTime expiresAt;
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'VoucherModel(code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, maxDiscountAmount: $maxDiscountAmount, minOrderValue: $minOrderValue, usageLimit: $usageLimit, usageCount: $usageCount, perUserLimit: $perUserLimit, isActive: $isActive, startDate: $startDate, expiresAt: $expiresAt, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoucherModelImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            (identical(other.maxDiscountAmount, maxDiscountAmount) ||
                other.maxDiscountAmount == maxDiscountAmount) &&
            (identical(other.minOrderValue, minOrderValue) ||
                other.minOrderValue == minOrderValue) &&
            (identical(other.usageLimit, usageLimit) ||
                other.usageLimit == usageLimit) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.perUserLimit, perUserLimit) ||
                other.perUserLimit == perUserLimit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    description,
    discountType,
    discountValue,
    maxDiscountAmount,
    minOrderValue,
    usageLimit,
    usageCount,
    perUserLimit,
    isActive,
    startDate,
    expiresAt,
    createdBy,
    createdAt,
  );

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoucherModelImplCopyWith<_$VoucherModelImpl> get copyWith =>
      __$$VoucherModelImplCopyWithImpl<_$VoucherModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoucherModelImplToJson(this);
  }
}

abstract class _VoucherModel extends VoucherModel {
  const factory _VoucherModel({
    required final String code,
    required final String description,
    required final String discountType,
    required final double discountValue,
    final double? maxDiscountAmount,
    final double minOrderValue,
    final int? usageLimit,
    final int usageCount,
    final int perUserLimit,
    final bool isActive,
    required final DateTime startDate,
    required final DateTime expiresAt,
    final String? createdBy,
    final DateTime? createdAt,
  }) = _$VoucherModelImpl;
  const _VoucherModel._() : super._();

  factory _VoucherModel.fromJson(Map<String, dynamic> json) =
      _$VoucherModelImpl.fromJson;

  @override
  String get code;
  @override
  String get description;
  @override
  String get discountType; // 'percentage' | 'fixed'
  @override
  double get discountValue; // % hoặc VND
  @override
  double? get maxDiscountAmount; // Trần giảm tối đa (cho loại %)
  @override
  double get minOrderValue;
  @override
  int? get usageLimit; // null = không giới hạn
  @override
  int get usageCount;
  @override
  int get perUserLimit;
  @override
  bool get isActive;
  @override
  DateTime get startDate;
  @override
  DateTime get expiresAt;
  @override
  String? get createdBy;
  @override
  DateTime? get createdAt;

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoucherModelImplCopyWith<_$VoucherModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
