import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseChatRecord {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const WarehouseChatRecord({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory WarehouseChatRecord.fromMap(Map<String, dynamic> map) {
    return WarehouseChatRecord(
      text: map['text'] as String? ?? '',
      isUser: map['isUser'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

abstract class WarehouseChatRepository {
  Future<List<WarehouseChatRecord>> load();
  Future<void> save(List<WarehouseChatRecord> records);
}

class LocalWarehouseChatRepository implements WarehouseChatRepository {
  static const String _legacyStorageKey = 'warehouse_chat_records';
  static const String _storageKeyPrefix = 'warehouse_chat_records_v2';
  static const String _sessionUserIdKey = 'current_user_id_v1';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  const LocalWarehouseChatRepository();

  @override
  Future<List<WarehouseChatRecord>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = await _secureStorage.read(key: _sessionUserIdKey);
    final String storageKey = _storageKeyForUser(userId);
    String? raw = prefs.getString(storageKey);
    if ((raw == null || raw.isEmpty) &&
        userId != null &&
        userId.isNotEmpty &&
        prefs.containsKey(_legacyStorageKey)) {
      final String? legacyRaw = prefs.getString(_legacyStorageKey);
      if (legacyRaw != null && legacyRaw.isNotEmpty) {
        await prefs.setString(storageKey, legacyRaw);
        await prefs.remove(_legacyStorageKey);
        raw = legacyRaw;
      }
    }
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    return data
        .whereType<Map>()
        .map(
          (item) =>
              WarehouseChatRecord.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<void> save(List<WarehouseChatRecord> records) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = await _secureStorage.read(key: _sessionUserIdKey);
    final String storageKey = _storageKeyForUser(userId);
    final String raw = jsonEncode(records.map((r) => r.toMap()).toList());
    await prefs.setString(storageKey, raw);
  }

  String _storageKeyForUser(String? userId) {
    final String trimmed = (userId ?? '').trim();
    if (trimmed.isEmpty) {
      return '${_storageKeyPrefix}_guest';
    }
    return '${_storageKeyPrefix}_user_$trimmed';
  }
}
