// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/local_db/database_service.dart';
import 'services/supabase/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend service
  await SupabaseService.initialize();

  // Initialize SQLite local database
  final dbService = DatabaseService();
  await dbService.initDatabase();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
