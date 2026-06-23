// lib/features/conversations/presentation/providers/conversations_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/conversation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'conversations_provider.g.dart';

@riverpod
class Conversations extends _$Conversations {
  @override
  FutureOr<List<Conversation>> build() async {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getConversations();
  }

  Future<void> deleteConversation(String convId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(chatRepositoryProvider);
    await repository.deleteConversation(convId);
    final list = await repository.getConversations();
    state = AsyncValue.data(list);
  }

  void addMessageToConversation(String convId, dynamic message) {
    // Update local state last message representation
    state.whenData((list) {
      final index = list.indexWhere((c) => c.id == convId);
      if (index != -1) {
        final updatedList = List<Conversation>.from(list);
        updatedList[index] = updatedList[index].copyWith(
          lastMessage: message,
          updatedAt: DateTime.now(),
        );
        state = AsyncValue.data(updatedList);
      }
    });
  }
}
