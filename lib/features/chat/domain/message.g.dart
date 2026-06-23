// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageReactionImpl _$$MessageReactionImplFromJson(
  Map<String, dynamic> json,
) => _$MessageReactionImpl(
  emoji: json['emoji'] as String,
  userId: json['userId'] as String,
);

Map<String, dynamic> _$$MessageReactionImplToJson(
  _$MessageReactionImpl instance,
) => <String, dynamic>{'emoji': instance.emoji, 'userId': instance.userId};

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String?,
      fileUrl: json['fileUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      audioDurationMs: (json['audioDurationMs'] as num?)?.toInt(),
      replyTo: json['replyTo'] == null
          ? null
          : Message.fromJson(json['replyTo'] as Map<String, dynamic>),
      status: $enumDecode(_$MessageStatusEnumMap, json['status']),
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'fileUrl': instance.fileUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'fileName': instance.fileName,
      'fileSizeBytes': instance.fileSizeBytes,
      'audioDurationMs': instance.audioDurationMs,
      'replyTo': instance.replyTo,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'reactions': instance.reactions,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.file: 'file',
  MessageType.audio: 'audio',
  MessageType.gif: 'gif',
  MessageType.emoji: 'emoji',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};
