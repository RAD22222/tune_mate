// lib/features/auth/presentation/providers/auth_provider.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/user.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../chat/data/supabase_chat_repository.dart';
import '../../../../services/supabase/auth_service.dart';

part 'auth_provider.g.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return SupabaseChatRepository();
});

@riverpod
class AuthState extends _$AuthState {
  StreamSubscription<dynamic>? _authSubscription;

  @override
  FutureOr<User?> build() async {
    final authService = AuthService();

    _authSubscription?.cancel();
    _authSubscription = authService.authStateChanges.listen((event) async {
      final repository = ref.read(chatRepositoryProvider);
      final user = await repository.getCurrentUser();
      state = AsyncValue.data(user);
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final supabaseUser = authService.currentUser;
    if (supabaseUser == null) return null;

    final repository = ref.read(chatRepositoryProvider);
    return repository.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await AuthService().signIn(email: email, password: password);
      final repository = ref.read(chatRepositoryProvider);
      final user = await repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final username = '${displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().millisecond}';

      await AuthService().signUp(
        email: email,
        password: password,
        displayName: displayName,
        username: username,
      );

      final repository = ref.read(chatRepositoryProvider);
      final user = await repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await AuthService().signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
