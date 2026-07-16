// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customization_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomizationChoice _$CustomizationChoiceFromJson(Map<String, dynamic> json) {
  return _CustomizationChoice.fromJson(json);
}

/// @nodoc
mixin _$CustomizationChoice {
  String get value => throw _privateConstructorUsedError; // vd: 'large'
  String get label => throw _privateConstructorUsedError; // vd: 'Lớn (L)'
  double get extraPrice => throw _privateConstructorUsedError;

  /// Serializes this CustomizationChoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomizationChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomizationChoiceCopyWith<CustomizationChoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomizationChoiceCopyWith<$Res> {
  factory $CustomizationChoiceCopyWith(
    CustomizationChoice value,
    $Res Function(CustomizationChoice) then,
  ) = _$CustomizationChoiceCopyWithImpl<$Res, CustomizationChoice>;
  @useResult
  $Res call({String value, String label, double extraPrice});
}

/// @nodoc
class _$CustomizationChoiceCopyWithImpl<$Res, $Val extends CustomizationChoice>
    implements $CustomizationChoiceCopyWith<$Res> {
  _$CustomizationChoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomizationChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? label = null,
    Object? extraPrice = null,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            extraPrice: null == extraPrice
                ? _value.extraPrice
                : extraPrice // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomizationChoiceImplCopyWith<$Res>
    implements $CustomizationChoiceCopyWith<$Res> {
  factory _$$CustomizationChoiceImplCopyWith(
    _$CustomizationChoiceImpl value,
    $Res Function(_$CustomizationChoiceImpl) then,
  ) = __$$CustomizationChoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String label, double extraPrice});
}

/// @nodoc
class __$$CustomizationChoiceImplCopyWithImpl<$Res>
    extends _$CustomizationChoiceCopyWithImpl<$Res, _$CustomizationChoiceImpl>
    implements _$$CustomizationChoiceImplCopyWith<$Res> {
  __$$CustomizationChoiceImplCopyWithImpl(
    _$CustomizationChoiceImpl _value,
    $Res Function(_$CustomizationChoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomizationChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? label = null,
    Object? extraPrice = null,
  }) {
    return _then(
      _$CustomizationChoiceImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        extraPrice: null == extraPrice
            ? _value.extraPrice
            : extraPrice // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomizationChoiceImpl implements _CustomizationChoice {
  const _$CustomizationChoiceImpl({
    required this.value,
    required this.label,
    this.extraPrice = 0.0,
  });

  factory _$CustomizationChoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomizationChoiceImplFromJson(json);

  @override
  final String value;
  // vd: 'large'
  @override
  final String label;
  // vd: 'Lớn (L)'
  @override
  @JsonKey()
  final double extraPrice;

  @override
  String toString() {
    return 'CustomizationChoice(value: $value, label: $label, extraPrice: $extraPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomizationChoiceImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.extraPrice, extraPrice) ||
                other.extraPrice == extraPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label, extraPrice);

  /// Create a copy of CustomizationChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomizationChoiceImplCopyWith<_$CustomizationChoiceImpl> get copyWith =>
      __$$CustomizationChoiceImplCopyWithImpl<_$CustomizationChoiceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomizationChoiceImplToJson(this);
  }
}

abstract class _CustomizationChoice implements CustomizationChoice {
  const factory _CustomizationChoice({
    required final String value,
    required final String label,
    final double extraPrice,
  }) = _$CustomizationChoiceImpl;

  factory _CustomizationChoice.fromJson(Map<String, dynamic> json) =
      _$CustomizationChoiceImpl.fromJson;

  @override
  String get value; // vd: 'large'
  @override
  String get label; // vd: 'Lớn (L)'
  @override
  double get extraPrice;

  /// Create a copy of CustomizationChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomizationChoiceImplCopyWith<_$CustomizationChoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomizationModel _$CustomizationModelFromJson(Map<String, dynamic> json) {
  return _CustomizationModel.fromJson(json);
}

/// @nodoc
mixin _$CustomizationModel {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'size' | 'ice' | 'sugar' | 'milk'
  String get label =>
      throw _privateConstructorUsedError; // Tên hiển thị tiếng Việt
  List<CustomizationChoice> get choices => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;

  /// Serializes this CustomizationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomizationModelCopyWith<CustomizationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomizationModelCopyWith<$Res> {
  factory $CustomizationModelCopyWith(
    CustomizationModel value,
    $Res Function(CustomizationModel) then,
  ) = _$CustomizationModelCopyWithImpl<$Res, CustomizationModel>;
  @useResult
  $Res call({
    String id,
    String type,
    String label,
    List<CustomizationChoice> choices,
    bool isRequired,
  });
}

/// @nodoc
class _$CustomizationModelCopyWithImpl<$Res, $Val extends CustomizationModel>
    implements $CustomizationModelCopyWith<$Res> {
  _$CustomizationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? choices = null,
    Object? isRequired = null,
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
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            choices: null == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<CustomizationChoice>,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomizationModelImplCopyWith<$Res>
    implements $CustomizationModelCopyWith<$Res> {
  factory _$$CustomizationModelImplCopyWith(
    _$CustomizationModelImpl value,
    $Res Function(_$CustomizationModelImpl) then,
  ) = __$$CustomizationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String label,
    List<CustomizationChoice> choices,
    bool isRequired,
  });
}

/// @nodoc
class __$$CustomizationModelImplCopyWithImpl<$Res>
    extends _$CustomizationModelCopyWithImpl<$Res, _$CustomizationModelImpl>
    implements _$$CustomizationModelImplCopyWith<$Res> {
  __$$CustomizationModelImplCopyWithImpl(
    _$CustomizationModelImpl _value,
    $Res Function(_$CustomizationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? choices = null,
    Object? isRequired = null,
  }) {
    return _then(
      _$CustomizationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<CustomizationChoice>,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomizationModelImpl implements _CustomizationModel {
  const _$CustomizationModelImpl({
    required this.id,
    required this.type,
    required this.label,
    required final List<CustomizationChoice> choices,
    this.isRequired = true,
  }) : _choices = choices;

  factory _$CustomizationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomizationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  // 'size' | 'ice' | 'sugar' | 'milk'
  @override
  final String label;
  // Tên hiển thị tiếng Việt
  final List<CustomizationChoice> _choices;
  // Tên hiển thị tiếng Việt
  @override
  List<CustomizationChoice> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  @JsonKey()
  final bool isRequired;

  @override
  String toString() {
    return 'CustomizationModel(id: $id, type: $type, label: $label, choices: $choices, isRequired: $isRequired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomizationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    label,
    const DeepCollectionEquality().hash(_choices),
    isRequired,
  );

  /// Create a copy of CustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomizationModelImplCopyWith<_$CustomizationModelImpl> get copyWith =>
      __$$CustomizationModelImplCopyWithImpl<_$CustomizationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomizationModelImplToJson(this);
  }
}

abstract class _CustomizationModel implements CustomizationModel {
  const factory _CustomizationModel({
    required final String id,
    required final String type,
    required final String label,
    required final List<CustomizationChoice> choices,
    final bool isRequired,
  }) = _$CustomizationModelImpl;

  factory _CustomizationModel.fromJson(Map<String, dynamic> json) =
      _$CustomizationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // 'size' | 'ice' | 'sugar' | 'milk'
  @override
  String get label; // Tên hiển thị tiếng Việt
  @override
  List<CustomizationChoice> get choices;
  @override
  bool get isRequired;

  /// Create a copy of CustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomizationModelImplCopyWith<_$CustomizationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
