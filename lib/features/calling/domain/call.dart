// lib/features/calling/domain/call.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'call.freezed.dart';
part 'call.g.dart';

enum CallType {
  @JsonValue('voice')
  voice,
  @JsonValue('video')
  video,
}

enum CallStatus {
  @JsonValue('ringing')
  ringing,
  @JsonValue('active')
  active,
  @JsonValue('ended')
  ended,
  @JsonValue('missed')
  missed,
  @JsonValue('declined')
  declined,
}

@freezed
class Call with _$Call {
  const factory Call({
    required String id,
    required String callerId,
    required String calleeId,
    required CallType type,
    required CallStatus status,
    DateTime? startedAt,
    int? durationSeconds,
  }) = _Call;

  factory Call.fromJson(Map<String, dynamic> json) => _$CallFromJson(json);
}
