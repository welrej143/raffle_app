// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BetOption {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;

  /// Create a copy of BetOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BetOptionCopyWith<BetOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BetOptionCopyWith<$Res> {
  factory $BetOptionCopyWith(BetOption value, $Res Function(BetOption) then) =
      _$BetOptionCopyWithImpl<$Res, BetOption>;
  @useResult
  $Res call({String id, String title, String imagePath});
}

/// @nodoc
class _$BetOptionCopyWithImpl<$Res, $Val extends BetOption>
    implements $BetOptionCopyWith<$Res> {
  _$BetOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BetOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imagePath = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BetOptionImplCopyWith<$Res>
    implements $BetOptionCopyWith<$Res> {
  factory _$$BetOptionImplCopyWith(
          _$BetOptionImpl value, $Res Function(_$BetOptionImpl) then) =
      __$$BetOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String imagePath});
}

/// @nodoc
class __$$BetOptionImplCopyWithImpl<$Res>
    extends _$BetOptionCopyWithImpl<$Res, _$BetOptionImpl>
    implements _$$BetOptionImplCopyWith<$Res> {
  __$$BetOptionImplCopyWithImpl(
      _$BetOptionImpl _value, $Res Function(_$BetOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of BetOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imagePath = null,
  }) {
    return _then(_$BetOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BetOptionImpl implements _BetOption {
  const _$BetOptionImpl(
      {required this.id, required this.title, required this.imagePath});

  @override
  final String id;
  @override
  final String title;
  @override
  final String imagePath;

  @override
  String toString() {
    return 'BetOption(id: $id, title: $title, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BetOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, imagePath);

  /// Create a copy of BetOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BetOptionImplCopyWith<_$BetOptionImpl> get copyWith =>
      __$$BetOptionImplCopyWithImpl<_$BetOptionImpl>(this, _$identity);
}

abstract class _BetOption implements BetOption {
  const factory _BetOption(
      {required final String id,
      required final String title,
      required final String imagePath}) = _$BetOptionImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get imagePath;

  /// Create a copy of BetOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BetOptionImplCopyWith<_$BetOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
