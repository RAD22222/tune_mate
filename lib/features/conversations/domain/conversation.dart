// lib/features/conversations/domain/conversation.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../chat/domain/message.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

enum ConversationType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
}

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required ConversationType type,
    required String name,
    String? avatarUrl,
    Message? lastMessage,
    @Default(0) int unreadCount,
    required List<String> memberIds,
    required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
}
