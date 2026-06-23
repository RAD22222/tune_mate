// lib/features/chat/data/chat_repository.dart

import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../auth/domain/user.dart';
import '../../conversations/domain/conversation.dart';
import '../domain/message.dart';

abstract class ChatRepository {
  Future<User?> getCurrentUser();
  Future<List<Conversation>> getConversations();
  Future<List<Message>> getMessages(String convId);
  Future<Message> sendMessage(String convId, Message message);
  Stream<Message> getRealtimeMessageStream(String convId);
  Future<void> deleteConversation(String convId);
}

class FakeChatRepository implements ChatRepository {
  final _uuid = const Uuid();
  
  // Simulated data store
  final List<Conversation> _conversations = [];
  final Map<String, List<Message>> _messages = {};
  
  final User _currentUser = const User(
    id: 'user_current',
    email: 'user@tunemate.com',
    displayName: 'You (Alex)',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150',
    isOnline: true,
  );

  final List<User> _mockMates = [
    const User(
      id: 'user_sarah',
      email: 'sarah@tunemate.com',
      displayName: 'Sarah Jenkins',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
      statusMessage: 'Listening to Lo-Fi Beats 🎧',
      isOnline: true,
    ),
    const User(
      id: 'user_marcus',
      email: 'marcus@tunemate.com',
      displayName: 'Marcus Aurelius',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150',
      statusMessage: 'Gym time 🏋️‍♂️',
      isOnline: false,
    ),
    const User(
      id: 'user_clara',
      email: 'clara@tunemate.com',
      displayName: 'Clara Oswald',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150',
      statusMessage: 'Traveling the cosmos 🌌',
      isOnline: true,
    ),
  ];

  FakeChatRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Set up mock conversations
    final now = DateTime.now();

    for (var i = 0; i < _mockMates.length; i++) {
      final mate = _mockMates[i];
      final convId = 'conv_mock_$i';
      
      // Setup messages for this chat
      final List<Message> msgs = [];
      for (var j = 0; j < 12; j++) {
        final isOwn = j % 2 == 0;
        final senderId = isOwn ? _currentUser.id : mate.id;
        
        MessageType msgType = MessageType.text;
        String? content;
        String? fileUrl;
        String? fileName;
        int? fileSizeBytes;
        int? audioDurationMs;

        if (j == 3) {
          msgType = MessageType.image;
          fileUrl = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=300';
          content = 'Check out this awesome studio!';
        } else if (j == 7) {
          msgType = MessageType.audio;
          fileUrl = 'https://codesandbox.io/mock_audio.mp3';
          audioDurationMs = 12400; // 12.4s
        } else if (j == 9) {
          msgType = MessageType.gif;
          fileUrl = 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3B5MmtmNGRjNWc3dzd0aWthbzVxZHRoMXd1dmJjZWp0bWZ1MHprciZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3oKIPnAiaMCws8nru0/giphy.gif';
        } else {
          content = 'Hey! This is message $j in our chat sequence.';
        }

        msgs.add(Message(
          id: 'msg_mock_${convId}_$j',
          conversationId: convId,
          senderId: senderId,
          type: msgType,
          content: content,
          fileUrl: fileUrl,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes,
          audioDurationMs: audioDurationMs,
          status: MessageStatus.read,
          createdAt: now.subtract(Duration(hours: 12 - j)),
        ));
      }
      
      _messages[convId] = msgs;

      _conversations.add(Conversation(
        id: convId,
        type: ConversationType.direct,
        name: mate.displayName,
        avatarUrl: mate.avatarUrl,
        lastMessage: msgs.last,
        unreadCount: i == 0 ? 2 : 0,
        memberIds: [_currentUser.id, mate.id],
        updatedAt: now.subtract(Duration(hours: 12 - msgs.length)),
      ));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _currentUser;
  }

  @override
  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _conversations;
  }

  @override
  Future<List<Message>> getMessages(String convId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _messages[convId] ?? [];
  }

  @override
  Future<Message> sendMessage(String convId, Message message) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sentMessage = message.copyWith(
      id: _uuid.v4(),
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );
    
    if (!_messages.containsKey(convId)) {
      _messages[convId] = [];
    }
    _messages[convId]!.add(sentMessage);

    // Update conversation last message
    final index = _conversations.indexWhere((c) => c.id == convId);
    if (index != -1) {
      final updatedConv = _conversations[index].copyWith(
        lastMessage: sentMessage,
        updatedAt: DateTime.now(),
      );
      _conversations[index] = updatedConv;
    }

    return sentMessage;
  }

  @override
  Stream<Message> getRealtimeMessageStream(String convId) {
    // Generate a new mock message from the chat partner every 15 seconds
    final controller = StreamController<Message>();
    
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }
      
      final index = _conversations.indexWhere((c) => c.id == convId);
      if (index == -1) return;
      
      final conv = _conversations[index];
      final partnerId = conv.memberIds.firstWhere((id) => id != _currentUser.id);
      
      final incomingMsg = Message(
        id: _uuid.v4(),
        conversationId: convId,
        senderId: partnerId,
        type: MessageType.text,
        content: 'Hey, checking in! Have you seen this new track? 🎵',
        status: MessageStatus.read,
        createdAt: DateTime.now(),
      );

      if (_messages[convId] != null) {
        _messages[convId]!.add(incomingMsg);
      }
      
      // Update last message in conversation
      _conversations[index] = conv.copyWith(
        lastMessage: incomingMsg,
        updatedAt: DateTime.now(),
      );

      controller.add(incomingMsg);
    });

    return controller.stream;
  }

  @override
  Future<void> deleteConversation(String convId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _conversations.removeWhere((c) => c.id == convId);
    _messages.remove(convId);
  }
}
