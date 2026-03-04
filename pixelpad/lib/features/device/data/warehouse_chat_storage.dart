import 'dart:convert';

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
  static const String _storageKey = 'warehouse_chat_records';

  const LocalWarehouseChatRepository();

  @override
  Future<List<WarehouseChatRecord>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    return data
        .whereType<Map>()
        .map((item) =>
            WarehouseChatRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> save(List<WarehouseChatRecord> records) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = jsonEncode(records.map((r) => r.toMap()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
