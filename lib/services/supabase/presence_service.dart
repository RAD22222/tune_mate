// FILE: lib/services/supabase/presence_service.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  SupabaseClient get _client => SupabaseService.client;
  Timer? _heartbeatTimer;

  Future<void> setOnline() async {
    try {
      final response = await _client.functions.invoke(
        'presence',
        body: {'status': 'online'},
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to update presence');
      }
    } catch (e) {
      // Fail silently to avoid interrupting UX
    }
  }

  Future<void> setOffline() async {
    try {
      final response = await _client.functions.invoke(
        'presence',
        body: {'status': 'offline'},
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to update presence');
      }
    } catch (e) {
      // Fail silently
    }
  }

  Stream<Map<String, dynamic>> watchUserPresence(String userId) {
    final controller = StreamController<Map<String, dynamic>>();

    final channel = _client.channel('presence:$userId');
    final subscription = channel
        .onBroadcast(
          event: 'presence_update',
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(payload);
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

  Future<Map<String, dynamic>> getUserPresence(String userId) async {
    try {
      final response = await _client.functions.invoke(
        'presence',
        method: HttpMethod.get,
        queryParameters: {'userId': userId},
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to get presence');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get user presence: $e');
    }
  }

  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    setOnline();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setOnline();
    });
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    setOffline();
  }
}
