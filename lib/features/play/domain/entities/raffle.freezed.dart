// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raffle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Raffle {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get totalSlots => throw _privateConstructorUsedError;
  int get availableSlots => throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get participants =>
      throw _privateConstructorUsedError;

  /// Create a copy of Raffle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaffleCopyWith<Raffle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaffleCopyWith<$Res> {
  factory $RaffleCopyWith(Raffle value, $Res Function(Raffle) then) =
      _$RaffleCopyWithImpl<$Res, Raffle>;
  @useResult
  $Res call(
      {String id,
      String title,
      int totalSlots,
      int availableSlots,
      List<Map<String, dynamic>>? participants});
}

/// @nodoc
class _$RaffleCopyWithImpl<$Res, $Val extends Raffle>
    implements $RaffleCopyWith<$Res> {
  _$RaffleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Raffle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalSlots = null,
    Object? availableSlots = null,
    Object? participants = freezed,
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
      totalSlots: null == totalSlots
          ? _value.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      availableSlots: null == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
      participants: freezed == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaffleImplCopyWith<$Res> implements $RaffleCopyWith<$Res> {
  factory _$$RaffleImplCopyWith(
          _$RaffleImpl value, $Res Function(_$RaffleImpl) then) =
      __$$RaffleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      int totalSlots,
      int availableSlots,
      List<Map<String, dynamic>>? participants});
}

/// @nodoc
class __$$RaffleImplCopyWithImpl<$Res>
    extends _$RaffleCopyWithImpl<$Res, _$RaffleImpl>
    implements _$$RaffleImplCopyWith<$Res> {
  __$$RaffleImplCopyWithImpl(
      _$RaffleImpl _value, $Res Function(_$RaffleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Raffle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalSlots = null,
    Object? availableSlots = null,
    Object? participants = freezed,
  }) {
    return _then(_$RaffleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalSlots: null == totalSlots
          ? _value.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      availableSlots: null == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
      participants: freezed == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc

class _$RaffleImpl implements _Raffle {
  const _$RaffleImpl(
      {required this.id,
      required this.title,
      required this.totalSlots,
      required this.availableSlots,
      required final List<Map<String, dynamic>>? participants})
      : _participants = participants;

  @override
  final String id;
  @override
  final String title;
  @override
  final int totalSlots;
  @override
  final int availableSlots;
  final List<Map<String, dynamic>>? _participants;
  @override
  List<Map<String, dynamic>>? get participants {
    final value = _participants;
    if (value == null) return null;
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Raffle(id: $id, title: $title, totalSlots: $totalSlots, availableSlots: $availableSlots, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaffleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, totalSlots,
      availableSlots, const DeepCollectionEquality().hash(_participants));

  /// Create a copy of Raffle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaffleImplCopyWith<_$RaffleImpl> get copyWith =>
      __$$RaffleImplCopyWithImpl<_$RaffleImpl>(this, _$identity);
}

abstract class _Raffle implements Raffle {
  const factory _Raffle(
      {required final String id,
      required final String title,
      required final int totalSlots,
      required final int availableSlots,
      required final List<Map<String, dynamic>>? participants}) = _$RaffleImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  int get totalSlots;
  @override
  int get availableSlots;
  @override
  List<Map<String, dynamic>>? get participants;

  /// Create a copy of Raffle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaffleImplCopyWith<_$RaffleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
