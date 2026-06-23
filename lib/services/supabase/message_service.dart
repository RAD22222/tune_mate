// FILE: lib/services/supabase/message_service.dart

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  SupabaseClient get _client => SupabaseService.client;
  RealtimeChannel? _typingChannel;
  String? _activeTypingConversationId;

  Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int limit = 30,
    String? beforeMessageId,
  }) async {
    try {
      var query = _client.from('messages').select('''
        id,
        conversation_id,
        sender_id,
        type,
        content,
        file_url,
        file_name,
        file_size_bytes,
        mime_type,
        thumbnail_url,
        audio_duration_ms,
        reply_to_id,
        is_edited,
        is_deleted,
        status,
        created_at,
        updated_at,
        profiles(display_name, avatar_url)
      ''').eq('conversation_id', conversationId);

      if (beforeMessageId != null) {
        final refMsg = await _client
            .from('messages')
            .select('created_at')
            .eq('id', beforeMessageId)
            .single();
        final beforeCreatedAt = refMsg['created_at'];
        query = query.lt('created_at', beforeCreatedAt);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  Stream<Map<String, dynamic>> watchNewMessages(String conversationId) {
    final controller = StreamController<Map<String, dynamic>>();

    final channel = _client.channel('messages_insert_$conversationId');
    final subscription = channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(payload.newRecord);
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(subscription);
      controller.close();
    };

    return controller.stream;
  }

  Stream<Map<String, dynamic>> watchMessageStatusUpdates(String conversationId) {
    final controller = StreamController<Map<String, dynamic>>();

    final channel = _client.channel('messages_update_$conversationId');
    final subscription = channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(payload.newRecord);
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(subscription);
      controller.close();
    };

    return controller.stream;
  }

  Future<Map<String, dynamic>> sendTextMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final userId = AuthService().currentUserId;
      final response = await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': 'text',
        'content': content,
        'reply_to_id': replyToId,
        'status': 'sent',
      }).select().single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to send text message: $e');
    }
  }

  Future<Map<String, dynamic>> sendFileMessage({
    required String conversationId,
    required File file,
    required String messageType,
    String? replyToId,
  }) async {
    try {
      final userId = AuthService().currentUserId;
      final fileName = file.path.split(RegExp(r'[/\\]')).last;

      final fileBytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );

      final response = await _client.functions.invoke(
        'upload-media',
        body: {
          'conversationId': conversationId,
          'messageType': messageType,
        },
        files: [multipartFile],
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Upload failed');
      }

      final mediaInfo = Map<String, dynamic>.from(response.data);

      // Insert message referencing file metadata
      final messageResponse = await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': messageType,
        'content': '[Attachment]',
        'file_url': mediaInfo['fileUrl'],
        'file_name': fileName,
        'file_size_bytes': mediaInfo['sizeBytes'],
        'mime_type': mediaInfo['mimeType'],
        'thumbnail_url': mediaInfo['thumbnailUrl'],
        'reply_to_id': replyToId,
        'status': 'sent',
      }).select().single();

      return Map<String, dynamic>.from(messageResponse);
    } catch (e) {
      throw Exception('Failed to send file message: $e');
    }
  }

  Future<void> sendGifMessage({
    required String conversationId,
    required String gifUrl,
    String? replyToId,
  }) async {
    try {
      final userId = AuthService().currentUserId;
      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': 'gif',
        'content': gifUrl,
        'reply_to_id': replyToId,
        'status': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to send GIF message: $e');
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      final userId = AuthService().currentUserId;
      await _client
          .from('messages')
          .update({
            'content': newContent,
            'is_edited': true,
          })
          .eq('id', messageId)
          .eq('sender_id', userId);
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final userId = AuthService().currentUserId;
      await _client
          .from('messages')
          .update({'is_deleted': true})
          .eq('id', messageId)
          .eq('sender_id', userId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<void> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final userId = AuthService().currentUserId;
      await _client.from('message_reactions').upsert({
        'message_id': messageId,
        'user_id': userId,
        'emoji': emoji,
      });
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  Future<void> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final userId = AuthService().currentUserId;
      await _client
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .eq('emoji', emoji);
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchMessages({
    required String query,
    String? conversationId,
  }) async {
    try {
      final params = {
        'q': query,
        if (conversationId != null) 'conversationId': conversationId,
      };

      final response = await _client.functions.invoke(
        'search-messages',
        queryParameters: params,
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Search failed');
      }

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  Future<void> sendTypingIndicator(String conversationId) async {
    try {
      final userId = AuthService().currentUserId;
      final displayName = _client.auth.currentUser?.userMetadata?['display_name'] ?? 'Someone';

      if (_typingChannel == null || _activeTypingConversationId != conversationId) {
        await stopTypingIndicator();
        _typingChannel = _client.channel('typing:$conversationId');
        _typingChannel!.subscribe();
        _activeTypingConversationId = conversationId;
      }

      await _typingChannel!.sendBroadcastMessage(
        event: 'typing_start',
        payload: {
          'userId': userId,
          'displayName': displayName,
        },
      );
    } catch (e) {
      // Fail silently to avoid breaking typing UI
    }
  }

  Future<void> stopTypingIndicator() async {
    try {
      if (_typingChannel != null) {
        final userId = AuthService().currentUserId;
        await _typingChannel!.sendBroadcastMessage(
          event: 'typing_stop',
          payload: {
            'userId': userId,
          },
        );
        await _client.removeChannel(_typingChannel!);
        _typingChannel = null;
        _activeTypingConversationId = null;
      }
    } catch (e) {
      // Fail silently
    }
  }
}
