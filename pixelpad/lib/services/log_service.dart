import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  static const String _key = 'launch_logs';

  static Future<void> recordLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_key) ?? <String>[];
    logs.insert(0, DateTime.now().millisecondsSinceEpoch.toString());
    await prefs.setStringList(_key, logs);
  }

  static Future<List<DateTime>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_key) ?? <String>[];
    return logs.map((log) {
      final millis = int.tryParse(log);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
      return DateTime.tryParse(log) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }).toList();
  }
}
