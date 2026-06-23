// FILE: lib/services/supabase/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    const supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://gllisgeyldkwxowfezld.supabase.co',
    );
    const supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdsbGlzZ2V5bGRrd3hvd2ZlemxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxOTEzMzMsImV4cCI6MjA5Nzc2NzMzM30.7xWdhAYHAfSw9RITovInP-wCv-DhUhhDU7Wicoasxfc',
    );

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;
}
