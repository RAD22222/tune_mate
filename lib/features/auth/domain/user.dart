// lib/features/auth/domain/user.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
    String? statusMessage,
    DateTime? lastSeen,
    @Default(false) bool isOnline,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
