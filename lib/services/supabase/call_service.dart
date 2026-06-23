// FILE: lib/services/supabase/call_service.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';
import '../../features/calling/domain/call.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  SupabaseClient get _client => SupabaseService.client;

  Future<String> initiateCall({
    required String calleeId,
    required CallType type,
    String? conversationId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'call-signal',
        body: {
          'action': 'initiate',
          'calleeId': calleeId,
          'type': type.name,
          'conversationId': conversationId,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to initiate call');
      }

      return response.data['callId'] as String;
    } catch (e) {
      throw Exception('Failed to initiate call: $e');
    }
  }

  Future<void> answerCall({
    required String callId,
    required String sdpAnswer,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'call-signal',
        body: {
          'action': 'answer',
          'callId': callId,
          'sdpAnswer': sdpAnswer,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to answer call');
      }
    } catch (e) {
      throw Exception('Failed to answer call: $e');
    }
  }

  Future<void> sendIceCandidate({
    required String callId,
    required Map<String, dynamic> candidate,
    required String targetUserId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'call-signal',
        body: {
          'action': 'ice_candidate',
          'callId': callId,
          'iceCandidate': candidate,
          'targetUserId': targetUserId,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to send ICE candidate');
      }
    } catch (e) {
      throw Exception('Failed to send ICE candidate: $e');
    }
  }

  Future<void> endCall(String callId) async {
    try {
      final response = await _client.functions.invoke(
        'call-signal',
        body: {
          'action': 'end',
          'callId': callId,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to end call');
      }
    } catch (e) {
      throw Exception('Failed to end call: $e');
    }
  }

  Future<void> declineCall(String callId) async {
    try {
      final response = await _client.functions.invoke(
        'call-signal',
        body: {
          'action': 'decline',
          'callId': callId,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to decline call');
      }
    } catch (e) {
      throw Exception('Failed to decline call: $e');
    }
  }

  Stream<Map<String, dynamic>> watchIncomingCalls() {
    final controller = StreamController<Map<String, dynamic>>();
    final userId = AuthService().currentUserId;

    final channel = _client.channel('call:$userId');
    final subscription = channel
        .onBroadcast(
          event: 'incoming_call',
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

  Stream<Map<String, dynamic>> watchCallEvents(String callId) {
    final controller = StreamController<Map<String, dynamic>>();

    final channel = _client.channel('call_events_$callId');
    final events = ['call_answered', 'call_declined', 'call_ended', 'ice_candidate'];
    
    var subChannel = channel;
    for (final event in events) {
      subChannel = subChannel.onBroadcast(
        event: event,
        callback: (payload) {
          if (!controller.isClosed && payload['callId'] == callId) {
            controller.add({
              'event': event,
              ...payload,
            });
          }
        },
      );
    }

    final subscription = subChannel.subscribe();

    controller.onCancel = () {
      _client.removeChannel(subscription);
      controller.close();
    };

    return controller.stream;
  }
}
