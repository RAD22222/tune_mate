// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CallImpl _$$CallImplFromJson(Map<String, dynamic> json) => _$CallImpl(
  id: json['id'] as String,
  callerId: json['callerId'] as String,
  calleeId: json['calleeId'] as String,
  type: $enumDecode(_$CallTypeEnumMap, json['type']),
  status: $enumDecode(_$CallStatusEnumMap, json['status']),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CallImplToJson(_$CallImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callerId': instance.callerId,
      'calleeId': instance.calleeId,
      'type': _$CallTypeEnumMap[instance.type]!,
      'status': _$CallStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
    };

const _$CallTypeEnumMap = {CallType.voice: 'voice', CallType.video: 'video'};

const _$CallStatusEnumMap = {
  CallStatus.ringing: 'ringing',
  CallStatus.active: 'active',
  CallStatus.ended: 'ended',
  CallStatus.missed: 'missed',
  CallStatus.declined: 'declined',
};
