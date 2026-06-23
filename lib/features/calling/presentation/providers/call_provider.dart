// lib/features/calling/presentation/providers/call_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/call.dart';

part 'call_provider.g.dart';

@riverpod
class CallState extends _$CallState {
  @override
  Call? build() => null;

  void triggerIncomingCall(String callerId, String calleeId, CallType type) {
    state = Call(
      id: 'call_mock_${DateTime.now().millisecondsSinceEpoch}',
      callerId: callerId,
      calleeId: calleeId,
      type: type,
      status: CallStatus.ringing,
    );
  }

  void acceptCall() {
    if (state != null) {
      state = state!.copyWith(
        status: CallStatus.active,
        startedAt: DateTime.now(),
      );
    }
  }

  void declineCall() {
    if (state != null) {
      state = state!.copyWith(status: CallStatus.declined);
      Future.delayed(const Duration(milliseconds: 500), () {
        state = null;
      });
    }
  }

  void endCall() {
    if (state != null) {
      state = state!.copyWith(
        status: CallStatus.ended,
        durationSeconds: state!.startedAt != null
            ? DateTime.now().difference(state!.startedAt!).inSeconds
            : 0,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        state = null;
      });
    }
  }
}
