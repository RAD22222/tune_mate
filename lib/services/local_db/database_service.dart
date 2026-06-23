// lib/services/local_db/database_service.dart

import 'dart:io' show Directory;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/conversations/domain/conversation.dart';
import '../../features/chat/domain/message.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  // In-memory cache for web fallback support
  static final Map<String, Map<String, dynamic>> _webConversations = {};
  static final Map<String, List<Map<String, dynamic>>> _webMessages = {};
  static final Map<String, String> _webSettings = {};

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database;
  }

  Future<Database?> initDatabase() async {
    if (kIsWeb) return null;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tunemate.db");
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT,
        sender_id TEXT,
        type TEXT,
        content TEXT,
        file_url TEXT,
        thumbnail_url TEXT,
        file_name TEXT,
        file_size_bytes INTEGER,
        audio_duration_ms INTEGER,
        reply_to_id TEXT,
        status TEXT,
        created_at INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        name TEXT,
        type TEXT,
        last_message_id TEXT,
        unread_count INTEGER DEFAULT 0,
        updated_at INTEGER
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Create cached_media table
    await db.execute('''
      CREATE TABLE cached_media (
        url TEXT PRIMARY KEY,
        local_path TEXT,
        cached_at INTEGER,
        size_bytes INTEGER
      )
    ''');
  }

  // Conversation Helpers
  Future<void> insertConversation(Conversation conversation) async {
    if (kIsWeb) {
      _webConversations[conversation.id] = {
        'id': conversation.id,
        'name': conversation.name,
        'type': conversation.type.name,
        'last_message_id': conversation.lastMessage?.id,
        'unread_count': conversation.unreadCount,
        'updated_at': conversation.updatedAt.millisecondsSinceEpoch,
      };
      return;
    }
    final db = await database;
    if (db == null) return;
    await db.insert(
      'conversations',
      {
        'id': conversation.id,
        'name': conversation.name,
        'type': conversation.type.name,
        'last_message_id': conversation.lastMessage?.id,
        'unread_count': conversation.unreadCount,
        'updated_at': conversation.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    if (kIsWeb) {
      final list = _webConversations.values.toList();
      list.sort((a, b) => (b['updated_at'] as int).compareTo(a['updated_at'] as int));
      return list;
    }
    final db = await database;
    if (db == null) return [];
    return await db.query('conversations', orderBy: 'updated_at DESC');
  }

  Future<void> deleteConversation(String id) async {
    if (kIsWeb) {
      _webConversations.remove(id);
      _webMessages.remove(id);
      return;
    }
    final db = await database;
    if (db == null) return;
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
    await db.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
  }

  // Message Helpers
  Future<void> insertMessage(Message message) async {
    if (kIsWeb) {
      final msgMap = {
        'id': message.id,
        'conversation_id': message.conversationId,
        'sender_id': message.senderId,
        'type': message.type.name,
        'content': message.content,
        'file_url': message.fileUrl,
        'thumbnail_url': message.thumbnailUrl,
        'file_name': message.fileName,
        'file_size_bytes': message.fileSizeBytes,
        'audio_duration_ms': message.audioDurationMs,
        'reply_to_id': message.replyTo?.id,
        'status': message.status.name,
        'created_at': message.createdAt.millisecondsSinceEpoch,
        'synced': message.status == MessageStatus.sending ? 0 : 1,
      };
      final list = _webMessages[message.conversationId] ?? [];
      list.removeWhere((m) => m['id'] == message.id);
      list.add(msgMap);
      _webMessages[message.conversationId] = list;
      return;
    }
    final db = await database;
    if (db == null) return;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'conversation_id': message.conversationId,
        'sender_id': message.senderId,
        'type': message.type.name,
        'content': message.content,
        'file_url': message.fileUrl,
        'thumbnail_url': message.thumbnailUrl,
        'file_name': message.fileName,
        'file_size_bytes': message.fileSizeBytes,
        'audio_duration_ms': message.audioDurationMs,
        'reply_to_id': message.replyTo?.id,
        'status': message.status.name,
        'created_at': message.createdAt.millisecondsSinceEpoch,
        'synced': message.status == MessageStatus.sending ? 0 : 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    if (kIsWeb) {
      final list = List<Map<String, dynamic>>.from(_webMessages[conversationId] ?? []);
      list.sort((a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int));
      return list;
    }
    final db = await database;
    if (db == null) return [];
    return await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at DESC',
    );
  }

  // Settings Helpers
  Future<void> setSetting(String key, String value) async {
    if (kIsWeb) {
      _webSettings[key] = value;
      return;
    }
    final db = await database;
    if (db == null) return;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    if (kIsWeb) {
      return _webSettings[key];
    }
    final db = await database;
    if (db == null) return null;
    final maps = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }
}
