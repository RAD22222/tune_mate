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

  Future<void> sendOtpForLogin(String email) async {
    state = const AsyncValue.loading();
    try {
      await AuthService().signInWithOtp(email: email);
      state = const AsyncValue.data(null); // Keep state as unauthenticated until OTP is verified
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sendOtpForRegister({
    required String email,
    required String displayName,
    required int age,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AuthService().signInWithOtp(
        email: email,
        displayName: displayName,
        age: age,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> verifyOtpCode({
    required String email,
    required String token,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AuthService().verifyOtp(email: email, token: token);
      final repository = ref.read(chatRepositoryProvider);
      final user = await repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
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
