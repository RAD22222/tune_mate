// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Call _$CallFromJson(Map<String, dynamic> json) {
  return _Call.fromJson(json);
}

/// @nodoc
mixin _$Call {
  String get id => throw _privateConstructorUsedError;
  String get callerId => throw _privateConstructorUsedError;
  String get calleeId => throw _privateConstructorUsedError;
  CallType get type => throw _privateConstructorUsedError;
  CallStatus get status => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  int? get durationSeconds => throw _privateConstructorUsedError;

  /// Serializes this Call to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Call
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallCopyWith<Call> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallCopyWith<$Res> {
  factory $CallCopyWith(Call value, $Res Function(Call) then) =
      _$CallCopyWithImpl<$Res, Call>;
  @useResult
  $Res call({
    String id,
    String callerId,
    String calleeId,
    CallType type,
    CallStatus status,
    DateTime? startedAt,
    int? durationSeconds,
  });
}

/// @nodoc
class _$CallCopyWithImpl<$Res, $Val extends Call>
    implements $CallCopyWith<$Res> {
  _$CallCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Call
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callerId = null,
    Object? calleeId = null,
    Object? type = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? durationSeconds = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            callerId: null == callerId
                ? _value.callerId
                : callerId // ignore: cast_nullable_to_non_nullable
                      as String,
            calleeId: null == calleeId
                ? _value.calleeId
                : calleeId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as CallType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CallStatus,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationSeconds: freezed == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CallImplCopyWith<$Res> implements $CallCopyWith<$Res> {
  factory _$$CallImplCopyWith(
    _$CallImpl value,
    $Res Function(_$CallImpl) then,
  ) = __$$CallImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String callerId,
    String calleeId,
    CallType type,
    CallStatus status,
    DateTime? startedAt,
    int? durationSeconds,
  });
}

/// @nodoc
class __$$CallImplCopyWithImpl<$Res>
    extends _$CallCopyWithImpl<$Res, _$CallImpl>
    implements _$$CallImplCopyWith<$Res> {
  __$$CallImplCopyWithImpl(_$CallImpl _value, $Res Function(_$CallImpl) _then)
    : super(_value, _then);

  /// Create a copy of Call
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callerId = null,
    Object? calleeId = null,
    Object? type = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? durationSeconds = freezed,
  }) {
    return _then(
      _$CallImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        callerId: null == callerId
            ? _value.callerId
            : callerId // ignore: cast_nullable_to_non_nullable
                  as String,
        calleeId: null == calleeId
            ? _value.calleeId
            : calleeId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CallType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CallStatus,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationSeconds: freezed == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CallImpl implements _Call {
  const _$CallImpl({
    required this.id,
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.status,
    this.startedAt,
    this.durationSeconds,
  });

  factory _$CallImpl.fromJson(Map<String, dynamic> json) =>
      _$$CallImplFromJson(json);

  @override
  final String id;
  @override
  final String callerId;
  @override
  final String calleeId;
  @override
  final CallType type;
  @override
  final CallStatus status;
  @override
  final DateTime? startedAt;
  @override
  final int? durationSeconds;

  @override
  String toString() {
    return 'Call(id: $id, callerId: $callerId, calleeId: $calleeId, type: $type, status: $status, startedAt: $startedAt, durationSeconds: $durationSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.callerId, callerId) ||
                other.callerId == callerId) &&
            (identical(other.calleeId, calleeId) ||
                other.calleeId == calleeId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    callerId,
    calleeId,
    type,
    status,
    startedAt,
    durationSeconds,
  );

  /// Create a copy of Call
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallImplCopyWith<_$CallImpl> get copyWith =>
      __$$CallImplCopyWithImpl<_$CallImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CallImplToJson(this);
  }
}

abstract class _Call implements Call {
  const factory _Call({
    required final String id,
    required final String callerId,
    required final String calleeId,
    required final CallType type,
    required final CallStatus status,
    final DateTime? startedAt,
    final int? durationSeconds,
  }) = _$CallImpl;

  factory _Call.fromJson(Map<String, dynamic> json) = _$CallImpl.fromJson;

  @override
  String get id;
  @override
  String get callerId;
  @override
  String get calleeId;
  @override
  CallType get type;
  @override
  CallStatus get status;
  @override
  DateTime? get startedAt;
  @override
  int? get durationSeconds;

  /// Create a copy of Call
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallImplCopyWith<_$CallImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
