import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'profile_data.dart';

abstract class ProfileDataSource {
  Future<ProfileData> fetchProfile();
  Future<void> saveProfile(ProfileData data);
}

class LocalProfileDataSource implements ProfileDataSource {
  static const String _storageKey = 'profile_data_v1';

  @override
  Future<ProfileData> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return ProfileData.initial();
    }
    try {
      return ProfileData.fromJson(raw);
    } catch (_) {
      return ProfileData.initial();
    }
  }

  @override
  Future<void> saveProfile(ProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }
}

class ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepository({ProfileDataSource? dataSource})
      : _dataSource = dataSource ?? LocalProfileDataSource();

  Future<ProfileData> fetchProfile() => _dataSource.fetchProfile();

  Future<void> saveProfile(ProfileData data) => _dataSource.saveProfile(data);
}
