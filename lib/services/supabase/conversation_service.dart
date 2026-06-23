// FILE: lib/services/supabase/conversation_service.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  SupabaseClient get _client => SupabaseService.client;

  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final userId = AuthService().currentUserId;
      final response = await _client
          .from('conversation_members')
          .select('''
            id,
            role,
            unread_count,
            last_read_at,
            joined_at,
            conversations!inner(
              id,
              type,
              name,
              description,
              avatar_url,
              created_by,
              last_message_id,
              last_message_at,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId);

      final list = List<Map<String, dynamic>>.from(response);
      
      // Sort in memory by last_message_at or updated_at DESC
      list.sort((a, b) {
        final convA = a['conversations'] as Map<String, dynamic>?;
        final convB = b['conversations'] as Map<String, dynamic>?;
        if (convA == null || convB == null) return 0;
        
        final timeAStr = convA['last_message_at'] ?? convA['updated_at'];
        final timeBStr = convB['last_message_at'] ?? convB['updated_at'];
        
        if (timeAStr == null || timeBStr == null) return 0;
        
        final timeA = DateTime.parse(timeAStr);
        final timeB = DateTime.parse(timeBStr);
        return timeB.compareTo(timeA);
      });
      
      return list;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> watchConversations() {
    final controller = StreamController<List<Map<String, dynamic>>>();
    final userId = AuthService().currentUserId;

    // Fetch initial list
    getConversations().then((data) {
      if (!controller.isClosed) controller.add(data);
    }).catchError((err) {
      if (!controller.isClosed) controller.addError(err);
    });

    // Subscribe to pg changes for members
    final channel = _client.channel('conversation_members_changes');
    final subscription = channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversation_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            try {
              final updatedData = await getConversations();
              if (!controller.isClosed) controller.add(updatedData);
            } catch (e) {
              if (!controller.isClosed) controller.addError(e);
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

  Future<Map<String, dynamic>> createConversation({
    required String type, // 'direct' or 'group'
    List<String> memberIds = const [],
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'create-conversation',
        body: {
          'type': type,
          'name': name,
          'memberIds': memberIds,
          'avatarUrl': avatarUrl,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to create conversation');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  Future<void> markAsRead({
    required String conversationId,
    required String lastReadMessageId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'update-read-status',
        body: {
          'conversationId': conversationId,
          'lastReadMessageId': lastReadMessageId,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to update read status');
      }
    } catch (e) {
      throw Exception('Failed to mark conversation as read: $e');
    }
  }

  Future<void> leaveConversation(String conversationId) async {
    try {
      final userId = AuthService().currentUserId;
      await _client
          .from('conversation_members')
          .delete()
          .eq('conversation_id', conversationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to leave conversation: $e');
    }
  }
}
