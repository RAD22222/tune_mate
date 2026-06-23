// FILE: lib/services/supabase/file_service.dart

import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  SupabaseClient get _client => SupabaseService.client;

  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .createSignedUrl(path, expiresInSeconds);
      return response;
    } catch (e) {
      throw Exception('Failed to generate signed URL: $e');
    }
  }

  Future<void> downloadFile({
    required String url,
    required String localPath,
    Function(int, int)? onProgress,
  }) async {
    try {
      final dioClient = dio.Dio();
      await dioClient.download(
        url,
        localPath,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<String> uploadAvatar(File file) async {
    try {
      final userId = AuthService().currentUserId;
      final ext = file.path.split('.').last;
      final path = '$userId/avatar.$ext';

      // Upload into avatars bucket with overwrite options enabled
      await _client.storage.from('avatars').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);

      // Save public url into database profiles
      await _client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
