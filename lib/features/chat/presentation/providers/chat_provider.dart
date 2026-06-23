// lib/features/chat/presentation/providers/chat_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'chat_provider.g.dart';

@riverpod
class Chat extends _$Chat {
  StreamSubscription<Message>? _realtimeSubscription;

  @override
  FutureOr<List<Message>> build(String convId) async {
    final repository = ref.watch(chatRepositoryProvider);
    
    // Subscribe to realtime incoming messages
    _realtimeSubscription?.cancel();
    _realtimeSubscription = repository.getRealtimeMessageStream(convId).listen((incomingMessage) {
      _onIncomingMessage(incomingMessage);
    });

    ref.onDispose(() {
      _realtimeSubscription?.cancel();
    });

    return repository.getMessages(convId);
  }

  void _onIncomingMessage(Message msg) {
    state.whenData((currentList) {
      final updatedList = List<Message>.from(currentList)..add(msg);
      state = AsyncValue.data(updatedList);
    });
  }

  Future<void> sendTextMessage(String content, {Message? replyTo}) async {
    final repository = ref.read(chatRepositoryProvider);
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final message = Message(
      id: const Uuid().v4(),
      conversationId: convId,
      senderId: user.id,
      type: MessageType.text,
      content: content,
      replyTo: replyTo,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    // Add message locally as sending
    state.whenData((currentList) {
      state = AsyncValue.data([...currentList, message]);
    });

    try {
      final sentMessage = await repository.sendMessage(convId, message);
      // Update message state with sent message
      state.whenData((currentList) {
        final index = currentList.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          final updatedList = List<Message>.from(currentList);
          updatedList[index] = sentMessage;
          state = AsyncValue.data(updatedList);
        }
      });
    } catch (e) {
      // Mark as failed
      state.whenData((currentList) {
        final index = currentList.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          final updatedList = List<Message>.from(currentList);
          updatedList[index] = message.copyWith(status: MessageStatus.failed);
          state = AsyncValue.data(updatedList);
        }
      });
    }
  }

  Future<void> sendMediaMessage(MessageType type, String fileUrl, {String? fileName, int? fileSizeBytes}) async {
    final repository = ref.read(chatRepositoryProvider);
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final message = Message(
      id: const Uuid().v4(),
      conversationId: convId,
      senderId: user.id,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    state.whenData((currentList) {
      state = AsyncValue.data([...currentList, message]);
    });

    final sentMessage = await repository.sendMessage(convId, message);
    state.whenData((currentList) {
      final index = currentList.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        final updatedList = List<Message>.from(currentList);
        updatedList[index] = sentMessage;
        state = AsyncValue.data(updatedList);
      }
    });
  }
}

// Typing Indicator Provider
@riverpod
Stream<List<String>> typingIndicator(Ref ref, String convId) {
  // Simulates typing animations: every 20 seconds, show the chat partner is typing
  final controller = StreamController<List<String>>();
  
  Timer? timer;
  timer = Timer.periodic(const Duration(seconds: 20), (t) {
    if (controller.isClosed) {
      timer?.cancel();
      return;
    }
    
    // Add "typing" status for 4 seconds
    controller.add(['user_sarah']);
    
    Future.delayed(const Duration(seconds: 4), () {
      if (!controller.isClosed) {
        controller.add([]);
      }
    });
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
}

// Online Status Provider
@riverpod
Stream<bool> onlineStatus(Ref ref, String userId) {
  // Simulates partner going online/offline periodically
  final controller = StreamController<bool>();
  
  Timer? timer;
  bool isOnline = true;
  controller.add(isOnline);

  timer = Timer.periodic(const Duration(seconds: 30), (t) {
    if (controller.isClosed) {
      timer?.cancel();
      return;
    }
    isOnline = !isOnline;
    controller.add(isOnline);
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
}

// Reply Target Provider
@riverpod
class ReplyTarget extends _$ReplyTarget {
  @override
  Message? build() => null;

  void set(Message? msg) => state = msg;
  void clear() => state = null;
}

// Voice Recording State Provider
enum AudioRecordingState { idle, recording, paused }

@riverpod
class RecordingState extends _$RecordingState {
  @override
  AudioRecordingState build() => AudioRecordingState.idle;

  void startRecording() => state = AudioRecordingState.recording;
  void pauseRecording() => state = AudioRecordingState.paused;
  void stopRecording() => state = AudioRecordingState.idle;
}
