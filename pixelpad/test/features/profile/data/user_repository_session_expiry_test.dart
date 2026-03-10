import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';
import 'package:pixelpad/features/profile/domain/entities/user_profile.dart';

void main() {
  const String accessTokenKey = 'auth_access_token_v1';
  const String tokenTypeKey = 'auth_token_type_v1';
  const String expiresInKey = 'auth_expires_in_v1';
  const String lastLoginAtKey = 'auth_last_login_at_epoch_ms_v1';

  final UserProfile user = UserProfile.initial();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('getAccessToken returns token when session is within 7 days', () async {
    final DateTime now = DateTime.utc(2026, 3, 9, 10, 0, 0);
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      accessTokenKey: 'token-valid',
      tokenTypeKey: 'Bearer',
      lastLoginAtKey: now
          .subtract(const Duration(days: 6, hours: 23))
          .millisecondsSinceEpoch
          .toString(),
    });
    const FlutterSecureStorage storage = FlutterSecureStorage();
    final UserRepository repository = UserRepository(
      dataSource: _FakeUserDataSource(user: user),
      secureStorage: storage,
      nowProvider: () => now,
    );

    final String? token = await repository.getAccessToken();

    expect(token, 'token-valid');
  });

  test('getAccessToken clears session when it is older than 7 days', () async {
    final DateTime now = DateTime.utc(2026, 3, 9, 10, 0, 0);
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      accessTokenKey: 'token-expired',
      tokenTypeKey: 'Bearer',
      expiresInKey: '7200',
      lastLoginAtKey: now
          .subtract(const Duration(days: 8))
          .millisecondsSinceEpoch
          .toString(),
    });
    const FlutterSecureStorage storage = FlutterSecureStorage();
    final UserRepository repository = UserRepository(
      dataSource: _FakeUserDataSource(user: user),
      secureStorage: storage,
      nowProvider: () => now,
    );

    final String? token = await repository.getAccessToken();

    expect(token, isNull);
    expect(await storage.read(key: accessTokenKey), isNull);
    expect(await storage.read(key: tokenTypeKey), isNull);
    expect(await storage.read(key: expiresInKey), isNull);
    expect(await storage.read(key: lastLoginAtKey), isNull);
  });

  test(
    'login renews local session window and expires again after 7 days',
    () async {
      DateTime now = DateTime.utc(2026, 3, 9, 10, 0, 0);
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        accessTokenKey: 'old-token',
        tokenTypeKey: 'Bearer',
        lastLoginAtKey: now
            .subtract(const Duration(days: 8))
            .millisecondsSinceEpoch
            .toString(),
      });
      const FlutterSecureStorage storage = FlutterSecureStorage();
      final UserRepository repository = UserRepository(
        dataSource: _FakeUserDataSource(
          user: user,
          loginToken: 'renewed-token',
          loginExpiresIn: 604800,
        ),
        secureStorage: storage,
        nowProvider: () => now,
      );

      await repository.login(phone: user.phone, password: user.password);

      now = now.add(const Duration(days: 6, hours: 23));
      expect(await repository.getAccessToken(), 'renewed-token');

      now = now.add(const Duration(hours: 2));
      expect(await repository.getAccessToken(), isNull);
    },
  );
}

class _FakeUserDataSource implements UserDataSource {
  _FakeUserDataSource({
    required this.user,
    this.loginToken = 'token',
    this.loginExpiresIn = 7200,
  });

  final UserProfile user;
  final String loginToken;
  final int? loginExpiresIn;

  @override
  Future<UserProfile> fetchCurrentUser({
    required String accessToken,
    required String tokenType,
  }) async {
    return user;
  }

  @override
  Future<AuthSession> loginUser({
    required String phone,
    required String password,
  }) async {
    return AuthSession(
      accessToken: loginToken,
      tokenType: 'Bearer',
      expiresIn: loginExpiresIn,
      user: user,
    );
  }

  @override
  Future<AuthSession> registerUser({
    required String phone,
    required String password,
  }) async {
    return AuthSession(
      accessToken: loginToken,
      tokenType: 'Bearer',
      expiresIn: loginExpiresIn,
      user: user,
    );
  }

  @override
  Future<UserProfile> saveUser({
    required UserProfile data,
    required String accessToken,
    required String tokenType,
  }) async {
    return data;
  }
}
