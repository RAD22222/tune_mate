// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      memberIds: (json['memberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'memberIds': instance.memberIds,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ConversationTypeEnumMap = {
  ConversationType.direct: 'direct',
  ConversationType.group: 'group',
};
