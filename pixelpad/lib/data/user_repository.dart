import 'dart:convert';

import 'package:http/http.dart' as http;

import 'user_profile.dart';

abstract class UserDataSource {
  Future<UserProfile> fetchUser(int userId);
  Future<void> saveUser(UserProfile data);
  Future<UserProfile> registerUser({
    required String phone,
    required String password,
  });
}

class MockBackendDataSource implements UserDataSource {
  MockBackendDataSource({
    http.Client? client,
    this.baseUrl = 'http://10.0.2.2:8080',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  @override
  Future<UserProfile> fetchUser(int userId) async {
    final response = await _client.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load user ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }

  @override
  Future<void> saveUser(UserProfile data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/users/${data.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save user ${response.statusCode}');
    }
  }

  @override
  Future<UserProfile> registerUser({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to register user ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }
}

class UserRepository {
  UserRepository({
    UserDataSource? dataSource,
    this.currentUserId = 1,
  }) : _dataSource = dataSource ?? MockBackendDataSource();

  final UserDataSource _dataSource;
  final int currentUserId;

  Future<UserProfile> fetchCurrentUser() async {
    try {
      return await _dataSource.fetchUser(currentUserId);
    } catch (_) {
      return UserProfile.initial();
    }
  }

  Future<void> saveCurrentUser(UserProfile data) async {
    await _dataSource.saveUser(data);
  }

  Future<UserProfile> register({
    required String phone,
    required String password,
  }) {
    return _dataSource.registerUser(phone: phone, password: password);
  }
}
