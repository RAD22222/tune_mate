// FILE: lib/services/supabase/contact_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  SupabaseClient get _client => SupabaseService.client;

  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final userId = AuthService().currentUserId;
      final response = await _client
          .from('contacts')
          .select('contact_id, profiles:contact_id(id, display_name, email, avatar_url, status_message, is_online, last_seen)')
          .eq('owner_id', userId);

      final List<Map<String, dynamic>> list = [];
      for (final row in List<Map<String, dynamic>>.from(response)) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        if (profile != null) {
          list.add(profile);
        }
      }
      return list;
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getIncomingRequests() async {
    try {
      final userId = AuthService().currentUserId;
      final response = await _client
          .from('connection_requests')
          .select('id, sender_id, profiles:sender_id(id, display_name, email, avatar_url)')
          .eq('receiver_id', userId)
          .eq('status', 'pending');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get incoming requests: $e');
    }
  }

  Future<Map<String, dynamic>?> searchUserByEmail(String email) async {
    try {
      final userId = AuthService().currentUserId;
      final response = await _client
          .from('profiles')
          .select('id, display_name, email, avatar_url, status_message')
          .eq('email', email.trim())
          .maybeSingle();

      if (response == null) return null;
      if (response['id'] == userId) return null; // Cannot search yourself

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to search user by email: $e');
    }
  }

  Future<void> sendConnectionRequest(String targetUserId) async {
    try {
      final userId = AuthService().currentUserId;
      await _client.from('connection_requests').insert({
        'sender_id': userId,
        'receiver_id': targetUserId,
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to send connection request: $e');
    }
  }

  Future<void> acceptConnectionRequest(String requestId) async {
    try {
      await _client
          .from('connection_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Failed to accept connection request: $e');
    }
  }

  Future<void> declineConnectionRequest(String requestId) async {
    try {
      await _client
          .from('connection_requests')
          .delete()
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Failed to decline connection request: $e');
    }
  }
}
