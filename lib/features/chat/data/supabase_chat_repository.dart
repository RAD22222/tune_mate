// FILE: lib/features/chat/data/supabase_chat_repository.dart

import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'chat_repository.dart';
import '../../auth/domain/user.dart';
import '../../conversations/domain/conversation.dart';
import '../domain/message.dart';
import '../../../services/supabase/auth_service.dart';
import '../../../services/supabase/conversation_service.dart';
import '../../../services/supabase/message_service.dart';
import '../../../services/local_db/database_service.dart';

class SupabaseChatRepository implements ChatRepository {
  String _getCurrentUserIdSafe() {
    try {
      return AuthService().currentUserId;
    } catch (_) {
      return 'user_offline';
    }
  }

  MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'gif':
        return MessageType.gif;
      case 'emoji':
        return MessageType.emoji;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  MessageStatus _parseMessageStatus(String? status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }

  Message _mapToMessage(Map<String, dynamic> m) {
    return Message(
      id: m['id'] as String,
      conversationId: m['conversation_id'] as String,
      senderId: m['sender_id'] as String? ?? '',
      type: _parseMessageType(m['type'] as String?),
      content: m['content'] as String?,
      fileUrl: m['file_url'] as String?,
      thumbnailUrl: m['thumbnail_url'] as String?,
      fileName: m['file_name'] as String?,
      fileSizeBytes: m['file_size_bytes'] as int?,
      audioDurationMs: m['audio_duration_ms'] as int?,
      status: _parseMessageStatus(m['status'] as String?),
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
      reactions: const [],
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    final supabaseUser = AuthService().currentUser;
    if (supabaseUser == null) return null;

    try {
      final data = await sb.Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .single();

      return User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        displayName: data['display_name'] ?? 'No Name',
        avatarUrl: data['avatar_url'] as String?,
        statusMessage: data['status_message'] as String?,
        isOnline: data['is_online'] as bool? ?? false,
        lastSeen: data['last_seen'] != null ? DateTime.parse(data['last_seen']) : null,
      );
    } catch (_) {
      final metadata = supabaseUser.userMetadata ?? {};
      return User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        displayName: metadata['display_name'] ?? 'No Name',
        avatarUrl: metadata['avatar_url'] as String?,
      );
    }
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      final rawList = await ConversationService().getConversations();
      final List<Conversation> conversations = [];

      final convIds = rawList
          .map((item) => (item['conversations'] as Map<String, dynamic>?)?['id'] as String?)
          .whereType<String>()
          .toList();

      final Map<String, List<String>> memberIdsByConv = {};
      if (convIds.isNotEmpty) {
        final membersRes = await sb.Supabase.instance.client
            .from('conversation_members')
            .select('conversation_id, user_id')
            .inFilter('conversation_id', convIds);

        for (final row in List<Map<String, dynamic>>.from(membersRes)) {
          final cid = row['conversation_id'] as String;
          final uid = row['user_id'] as String;
          memberIdsByConv.putIfAbsent(cid, () => []).add(uid);
        }
      }

      for (final item in rawList) {
        final convMap = item['conversations'] as Map<String, dynamic>?;
        if (convMap == null) continue;

        final convId = convMap['id'] as String;
        final unreadCount = item['unread_count'] as int? ?? 0;

        Message? lastMessage;
        final lastMsgMap = convMap['last_message'] as Map<String, dynamic>?;
        if (lastMsgMap != null) {
          lastMessage = _mapToMessage(lastMsgMap);
        }

        final members = memberIdsByConv[convId] ?? [];

        final conv = Conversation(
          id: convId,
          type: convMap['type'] == 'group' ? ConversationType.group : ConversationType.direct,
          name: convMap['name'] as String? ?? 'Chat',
          avatarUrl: convMap['avatar_url'] as String?,
          unreadCount: unreadCount,
          memberIds: members,
          lastMessage: lastMessage,
          updatedAt: convMap['updated_at'] != null
              ? DateTime.parse(convMap['updated_at'])
              : DateTime.now(),
        );

        conversations.add(conv);
        unawaited(DatabaseService().insertConversation(conv));
        if (lastMessage != null) {
          unawaited(DatabaseService().insertMessage(lastMessage));
        }
      }
      return conversations;
    } catch (e) {
      final localMaps = await DatabaseService().getConversations();
      final List<Conversation> localConvs = [];
      for (final c in localMaps) {
        final convId = c['id'] as String;
        final currentUserId = _getCurrentUserIdSafe();
        final List<String> memberIds = [currentUserId];

        localConvs.add(Conversation(
          id: convId,
          type: c['type'] == 'group' ? ConversationType.group : ConversationType.direct,
          name: c['name'] as String? ?? 'Chat',
          avatarUrl: c['avatar_url'] as String?,
          unreadCount: c['unread_count'] as int? ?? 0,
          memberIds: memberIds,
          lastMessage: null,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            c['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ),
        ));
      }
      return localConvs;
    }
  }

  @override
  Future<List<Message>> getMessages(String convId) async {
    try {
      final rawList = await MessageService().getMessages(conversationId: convId);
      final List<Message> messages = [];
      for (final m in rawList) {
        final msg = _mapToMessage(m);
        messages.add(msg);
        unawaited(DatabaseService().insertMessage(msg));
      }
      return messages;
    } catch (e) {
      final localMaps = await DatabaseService().getMessages(convId);
      return localMaps.map((m) {
        return Message(
          id: m['id'] as String,
          conversationId: m['conversation_id'] as String,
          senderId: m['sender_id'] as String? ?? '',
          type: _parseMessageType(m['type'] as String?),
          content: m['content'] as String?,
          fileUrl: m['file_url'] as String?,
          thumbnailUrl: m['thumbnail_url'] as String?,
          fileName: m['file_name'] as String?,
          fileSizeBytes: m['file_size_bytes'] as int?,
          audioDurationMs: m['audio_duration_ms'] as int?,
          status: _parseMessageStatus(m['status'] as String?),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            m['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ),
          reactions: const [],
        );
      }).toList();
    }
  }

  @override
  Future<Message> sendMessage(String convId, Message message) async {
    try {
      Map<String, dynamic> raw;
      if (message.type == MessageType.text) {
        raw = await MessageService().sendTextMessage(
          conversationId: convId,
          content: message.content ?? '',
          replyToId: message.replyTo?.id,
        );
      } else {
        if (message.fileUrl != null && !message.fileUrl!.startsWith('http')) {
          final file = File(message.fileUrl!);
          raw = await MessageService().sendFileMessage(
            conversationId: convId,
            file: file,
            messageType: message.type.name,
            replyToId: message.replyTo?.id,
          );
        } else if (message.type == MessageType.gif) {
          await MessageService().sendGifMessage(
            conversationId: convId,
            gifUrl: message.fileUrl ?? '',
            replyToId: message.replyTo?.id,
          );
          final sentMsg = message.copyWith(status: MessageStatus.sent, createdAt: DateTime.now());
          unawaited(DatabaseService().insertMessage(sentMsg));
          return sentMsg;
        } else {
          final response = await sb.Supabase.instance.client.from('messages').insert({
            'conversation_id': convId,
            'sender_id': message.senderId,
            'type': message.type.name,
            'content': message.content,
            'file_url': message.fileUrl,
            'thumbnail_url': message.thumbnailUrl,
            'file_name': message.fileName,
            'file_size_bytes': message.fileSizeBytes,
            'audio_duration_ms': message.audioDurationMs,
            'reply_to_id': message.replyTo?.id,
            'status': 'sent',
          }).select().single();
          raw = Map<String, dynamic>.from(response);
        }
      }

      final sentMsg = _mapToMessage(raw);
      unawaited(DatabaseService().insertMessage(sentMsg));
      return sentMsg;
    } catch (e) {
      final offlineMsg = message.copyWith(
        status: MessageStatus.failed,
      );
      unawaited(DatabaseService().insertMessage(offlineMsg));
      rethrow;
    }
  }

  @override
  Stream<Message> getRealtimeMessageStream(String convId) {
    return MessageService().watchNewMessages(convId).map((m) => _mapToMessage(m));
  }

  @override
  Future<void> deleteConversation(String convId) async {
    await ConversationService().leaveConversation(convId);
    unawaited(DatabaseService().deleteConversation(convId));
  }
}
