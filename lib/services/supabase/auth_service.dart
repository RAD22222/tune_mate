// FILE: lib/services/supabase/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _client => SupabaseService.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'username': username,
        },
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      final userId = currentUserId;
      await _client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update FCM token in database: $e');
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  String get currentUserId {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    return user.id;
  }
}
