// lib/features/chat/domain/message.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('file')
  file,
  @JsonValue('audio')
  audio,
  @JsonValue('gif')
  gif,
  @JsonValue('emoji')
  emoji,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

@freezed
class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String emoji,
    required String userId,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required MessageType type,
    String? content,
    String? fileUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSizeBytes,
    int? audioDurationMs,
    Message? replyTo,
    required MessageStatus status,
    @Default([]) List<MessageReaction> reactions,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
