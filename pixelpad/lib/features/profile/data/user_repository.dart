import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/user_profile.dart';

abstract class UserDataSource {
  Future<UserProfile> fetchUser(int userId);
  Future<void> saveUser(UserProfile data);
  Future<UserProfile> loginUser({
    required String phone,
    required String password,
  });
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
  Future<UserProfile> loginUser({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login user ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromMap(data);
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
  }) : _dataSource = dataSource ?? MockBackendDataSource();

  final UserDataSource _dataSource;
  static const String _sessionUserIdKey = 'current_user_id_v1';

  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionUserIdKey);
  }

  Future<void> _setLoggedInUserId(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_sessionUserIdKey);
      return;
    }
    await prefs.setInt(_sessionUserIdKey, userId);
  }

  Future<UserProfile?> fetchCurrentUser() async {
    final userId = await getLoggedInUserId();
    if (userId == null) {
      return null;
    }
    return _dataSource.fetchUser(userId);
  }

  Future<void> saveCurrentUser(UserProfile data) async {
    await _dataSource.saveUser(data);
  }

  Future<UserProfile> register({
    required String phone,
    required String password,
  }) async {
    final user = await _dataSource.registerUser(phone: phone, password: password);
    await _setLoggedInUserId(user.id);
    return user;
  }

  Future<UserProfile> login({
    required String phone,
    required String password,
  }) async {
    final user = await _dataSource.loginUser(phone: phone, password: password);
    await _setLoggedInUserId(user.id);
    return user;
  }

  Future<void> logout() async {
    await _setLoggedInUserId(null);
  }
}
