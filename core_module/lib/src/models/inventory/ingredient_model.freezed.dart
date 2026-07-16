// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IngredientModel _$IngredientModelFromJson(Map<String, dynamic> json) {
  return _IngredientModel.fromJson(json);
}

/// @nodoc
mixin _$IngredientModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get unit =>
      throw _privateConstructorUsedError; // 'kg' | 'lít' | 'hộp' | 'cái'
  double get currentStock => throw _privateConstructorUsedError;
  double get minStock => throw _privateConstructorUsedError; // Ngưỡng cảnh báo
  String get status =>
      throw _privateConstructorUsedError; // 'available' | 'low' | 'out_of_stock'
  String? get updatedBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this IngredientModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IngredientModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientModelCopyWith<IngredientModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientModelCopyWith<$Res> {
  factory $IngredientModelCopyWith(
    IngredientModel value,
    $Res Function(IngredientModel) then,
  ) = _$IngredientModelCopyWithImpl<$Res, IngredientModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String unit,
    double currentStock,
    double minStock,
    String status,
    String? updatedBy,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$IngredientModelCopyWithImpl<$Res, $Val extends IngredientModel>
    implements $IngredientModelCopyWith<$Res> {
  _$IngredientModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IngredientModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? unit = null,
    Object? currentStock = null,
    Object? minStock = null,
    Object? status = null,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            currentStock: null == currentStock
                ? _value.currentStock
                : currentStock // ignore: cast_nullable_to_non_nullable
                      as double,
            minStock: null == minStock
                ? _value.minStock
                : minStock // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedBy: freezed == updatedBy
                ? _value.updatedBy
                : updatedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IngredientModelImplCopyWith<$Res>
    implements $IngredientModelCopyWith<$Res> {
  factory _$$IngredientModelImplCopyWith(
    _$IngredientModelImpl value,
    $Res Function(_$IngredientModelImpl) then,
  ) = __$$IngredientModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String unit,
    double currentStock,
    double minStock,
    String status,
    String? updatedBy,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$IngredientModelImplCopyWithImpl<$Res>
    extends _$IngredientModelCopyWithImpl<$Res, _$IngredientModelImpl>
    implements _$$IngredientModelImplCopyWith<$Res> {
  __$$IngredientModelImplCopyWithImpl(
    _$IngredientModelImpl _value,
    $Res Function(_$IngredientModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IngredientModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? unit = null,
    Object? currentStock = null,
    Object? minStock = null,
    Object? status = null,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$IngredientModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        currentStock: null == currentStock
            ? _value.currentStock
            : currentStock // ignore: cast_nullable_to_non_nullable
                  as double,
        minStock: null == minStock
            ? _value.minStock
            : minStock // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedBy: freezed == updatedBy
            ? _value.updatedBy
            : updatedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientModelImpl implements _IngredientModel {
  const _$IngredientModelImpl({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    this.status = 'available',
    this.updatedBy,
    this.updatedAt,
  });

  factory _$IngredientModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String unit;
  // 'kg' | 'lít' | 'hộp' | 'cái'
  @override
  final double currentStock;
  @override
  final double minStock;
  // Ngưỡng cảnh báo
  @override
  @JsonKey()
  final String status;
  // 'available' | 'low' | 'out_of_stock'
  @override
  final String? updatedBy;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'IngredientModel(id: $id, name: $name, unit: $unit, currentStock: $currentStock, minStock: $minStock, status: $status, updatedBy: $updatedBy, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    unit,
    currentStock,
    minStock,
    status,
    updatedBy,
    updatedAt,
  );

  /// Create a copy of IngredientModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientModelImplCopyWith<_$IngredientModelImpl> get copyWith =>
      __$$IngredientModelImplCopyWithImpl<_$IngredientModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientModelImplToJson(this);
  }
}

abstract class _IngredientModel implements IngredientModel {
  const factory _IngredientModel({
    required final String id,
    required final String name,
    required final String unit,
    required final double currentStock,
    required final double minStock,
    final String status,
    final String? updatedBy,
    final DateTime? updatedAt,
  }) = _$IngredientModelImpl;

  factory _IngredientModel.fromJson(Map<String, dynamic> json) =
      _$IngredientModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get unit; // 'kg' | 'lít' | 'hộp' | 'cái'
  @override
  double get currentStock;
  @override
  double get minStock; // Ngưỡng cảnh báo
  @override
  String get status; // 'available' | 'low' | 'out_of_stock'
  @override
  String? get updatedBy;
  @override
  DateTime? get updatedAt;

  /// Create a copy of IngredientModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientModelImplCopyWith<_$IngredientModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
