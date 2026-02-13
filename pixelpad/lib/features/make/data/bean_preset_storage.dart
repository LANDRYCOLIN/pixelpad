import 'package:shared_preferences/shared_preferences.dart';

class BeanPreset {
  final String brand;
  final int count;

  const BeanPreset({
    required this.brand,
    required this.count,
  });

  String get settingsFile => '$brand-$count.json';
}

class BeanPresetStorage {
  const BeanPresetStorage._();

  static const String _brandKey = 'bean_preset_brand';
  static const String _countKey = 'bean_preset_count';

  static const String defaultBrand = 'MARD';
  static const int defaultCount = 144;

  static Future<BeanPreset> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String brand = prefs.getString(_brandKey) ?? defaultBrand;
    final int count = prefs.getInt(_countKey) ?? defaultCount;
    return BeanPreset(brand: brand, count: count);
  }

  static Future<void> save(BeanPreset preset) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brandKey, preset.brand);
    await prefs.setInt(_countKey, preset.count);
  }
}
