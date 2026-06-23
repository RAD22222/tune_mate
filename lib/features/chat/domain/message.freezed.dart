// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) {
  return _MessageReaction.fromJson(json);
}

/// @nodoc
mixin _$MessageReaction {
  String get emoji => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this MessageReaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageReactionCopyWith<MessageReaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReactionCopyWith<$Res> {
  factory $MessageReactionCopyWith(
    MessageReaction value,
    $Res Function(MessageReaction) then,
  ) = _$MessageReactionCopyWithImpl<$Res, MessageReaction>;
  @useResult
  $Res call({String emoji, String userId});
}

/// @nodoc
class _$MessageReactionCopyWithImpl<$Res, $Val extends MessageReaction>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? emoji = null, Object? userId = null}) {
    return _then(
      _value.copyWith(
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageReactionImplCopyWith<$Res>
    implements $MessageReactionCopyWith<$Res> {
  factory _$$MessageReactionImplCopyWith(
    _$MessageReactionImpl value,
    $Res Function(_$MessageReactionImpl) then,
  ) = __$$MessageReactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String emoji, String userId});
}

/// @nodoc
class __$$MessageReactionImplCopyWithImpl<$Res>
    extends _$MessageReactionCopyWithImpl<$Res, _$MessageReactionImpl>
    implements _$$MessageReactionImplCopyWith<$Res> {
  __$$MessageReactionImplCopyWithImpl(
    _$MessageReactionImpl _value,
    $Res Function(_$MessageReactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? emoji = null, Object? userId = null}) {
    return _then(
      _$MessageReactionImpl(
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageReactionImpl implements _MessageReaction {
  const _$MessageReactionImpl({required this.emoji, required this.userId});

  factory _$MessageReactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReactionImplFromJson(json);

  @override
  final String emoji;
  @override
  final String userId;

  @override
  String toString() {
    return 'MessageReaction(emoji: $emoji, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReactionImpl &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, emoji, userId);

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      __$$MessageReactionImplCopyWithImpl<_$MessageReactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReactionImplToJson(this);
  }
}

abstract class _MessageReaction implements MessageReaction {
  const factory _MessageReaction({
    required final String emoji,
    required final String userId,
  }) = _$MessageReactionImpl;

  factory _MessageReaction.fromJson(Map<String, dynamic> json) =
      _$MessageReactionImpl.fromJson;

  @override
  String get emoji;
  @override
  String get userId;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get fileUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get fileName => throw _privateConstructorUsedError;
  int? get fileSizeBytes => throw _privateConstructorUsedError;
  int? get audioDurationMs => throw _privateConstructorUsedError;
  Message? get replyTo => throw _privateConstructorUsedError;
  MessageStatus get status => throw _privateConstructorUsedError;
  List<MessageReaction> get reactions => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call({
    String id,
    String conversationId,
    String senderId,
    MessageType type,
    String? content,
    String? fileUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSizeBytes,
    int? audioDurationMs,
    Message? replyTo,
    MessageStatus status,
    List<MessageReaction> reactions,
    DateTime createdAt,
  });

  $MessageCopyWith<$Res>? get replyTo;
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? type = null,
    Object? content = freezed,
    Object? fileUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? fileName = freezed,
    Object? fileSizeBytes = freezed,
    Object? audioDurationMs = freezed,
    Object? replyTo = freezed,
    Object? status = null,
    Object? reactions = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileUrl: freezed == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileName: freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSizeBytes: freezed == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            audioDurationMs: freezed == audioDurationMs
                ? _value.audioDurationMs
                : audioDurationMs // ignore: cast_nullable_to_non_nullable
                      as int?,
            replyTo: freezed == replyTo
                ? _value.replyTo
                : replyTo // ignore: cast_nullable_to_non_nullable
                      as Message?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MessageStatus,
            reactions: null == reactions
                ? _value.reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                      as List<MessageReaction>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get replyTo {
    if (_value.replyTo == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.replyTo!, (value) {
      return _then(_value.copyWith(replyTo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
    _$MessageImpl value,
    $Res Function(_$MessageImpl) then,
  ) = __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String conversationId,
    String senderId,
    MessageType type,
    String? content,
    String? fileUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSizeBytes,
    int? audioDurationMs,
    Message? replyTo,
    MessageStatus status,
    List<MessageReaction> reactions,
    DateTime createdAt,
  });

  @override
  $MessageCopyWith<$Res>? get replyTo;
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
    _$MessageImpl _value,
    $Res Function(_$MessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? type = null,
    Object? content = freezed,
    Object? fileUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? fileName = freezed,
    Object? fileSizeBytes = freezed,
    Object? audioDurationMs = freezed,
    Object? replyTo = freezed,
    Object? status = null,
    Object? reactions = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$MessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileUrl: freezed == fileUrl
            ? _value.fileUrl
            : fileUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: freezed == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSizeBytes: freezed == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        audioDurationMs: freezed == audioDurationMs
            ? _value.audioDurationMs
            : audioDurationMs // ignore: cast_nullable_to_non_nullable
                  as int?,
        replyTo: freezed == replyTo
            ? _value.replyTo
            : replyTo // ignore: cast_nullable_to_non_nullable
                  as Message?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MessageStatus,
        reactions: null == reactions
            ? _value._reactions
            : reactions // ignore: cast_nullable_to_non_nullable
                  as List<MessageReaction>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.content,
    this.fileUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSizeBytes,
    this.audioDurationMs,
    this.replyTo,
    required this.status,
    final List<MessageReaction> reactions = const [],
    required this.createdAt,
  }) : _reactions = reactions;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String senderId;
  @override
  final MessageType type;
  @override
  final String? content;
  @override
  final String? fileUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String? fileName;
  @override
  final int? fileSizeBytes;
  @override
  final int? audioDurationMs;
  @override
  final Message? replyTo;
  @override
  final MessageStatus status;
  final List<MessageReaction> _reactions;
  @override
  @JsonKey()
  List<MessageReaction> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, type: $type, content: $content, fileUrl: $fileUrl, thumbnailUrl: $thumbnailUrl, fileName: $fileName, fileSizeBytes: $fileSizeBytes, audioDurationMs: $audioDurationMs, replyTo: $replyTo, status: $status, reactions: $reactions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.audioDurationMs, audioDurationMs) ||
                other.audioDurationMs == audioDurationMs) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    conversationId,
    senderId,
    type,
    content,
    fileUrl,
    thumbnailUrl,
    fileName,
    fileSizeBytes,
    audioDurationMs,
    replyTo,
    status,
    const DeepCollectionEquality().hash(_reactions),
    createdAt,
  );

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(this);
  }
}

abstract class _Message implements Message {
  const factory _Message({
    required final String id,
    required final String conversationId,
    required final String senderId,
    required final MessageType type,
    final String? content,
    final String? fileUrl,
    final String? thumbnailUrl,
    final String? fileName,
    final int? fileSizeBytes,
    final int? audioDurationMs,
    final Message? replyTo,
    required final MessageStatus status,
    final List<MessageReaction> reactions,
    required final DateTime createdAt,
  }) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get senderId;
  @override
  MessageType get type;
  @override
  String? get content;
  @override
  String? get fileUrl;
  @override
  String? get thumbnailUrl;
  @override
  String? get fileName;
  @override
  int? get fileSizeBytes;
  @override
  int? get audioDurationMs;
  @override
  Message? get replyTo;
  @override
  MessageStatus get status;
  @override
  List<MessageReaction> get reactions;
  @override
  DateTime get createdAt;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
