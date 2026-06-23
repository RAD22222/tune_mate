// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  statusMessage: json['statusMessage'] as String?,
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
  isOnline: json['isOnline'] as bool? ?? false,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'statusMessage': instance.statusMessage,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'isOnline': instance.isOnline,
    };
