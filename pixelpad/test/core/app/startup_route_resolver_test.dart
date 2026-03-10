import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelpad/core/app/routes.dart';
import 'package:pixelpad/core/app/startup_route_resolver.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';
import 'package:pixelpad/features/profile/domain/entities/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String accessTokenKey = 'auth_access_token_v1';
  const String tokenTypeKey = 'auth_token_type_v1';
  const String lastLoginAtKey = 'auth_last_login_at_epoch_ms_v1';

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'resolveInitialRoute returns splash on first launch without token',
    () async {
      const FlutterSecureStorage storage = FlutterSecureStorage();
      final UserRepository repository = UserRepository(
        dataSource: _NoopUserDataSource(),
        secureStorage: storage,
        nowProvider: () => DateTime.utc(2026, 3, 9, 10),
      );
      final StartupRouteResolver resolver = StartupRouteResolver(
        userRepository: repository,
      );

      final String route = await resolver.resolveInitialRoute();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      expect(route, AppRoutes.splash);
      expect(prefs.getBool(StartupRouteResolver.welcomeSeenKey), true);
    },
  );

  test('resolveInitialRoute returns login after welcome was seen', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      StartupRouteResolver.welcomeSeenKey: true,
    });
    const FlutterSecureStorage storage = FlutterSecureStorage();
    final UserRepository repository = UserRepository(
      dataSource: _NoopUserDataSource(),
      secureStorage: storage,
      nowProvider: () => DateTime.utc(2026, 3, 9, 10),
    );
    final StartupRouteResolver resolver = StartupRouteResolver(
      userRepository: repository,
    );

    final String route = await resolver.resolveInitialRoute();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    expect(route, AppRoutes.login);
    expect(prefs.getBool(StartupRouteResolver.welcomeSeenKey), true);
  });

  test(
    'resolveInitialRoute returns mainShell for valid token and marks welcome as seen',
    () async {
      final DateTime now = DateTime.utc(2026, 3, 9, 10);
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        accessTokenKey: 'token-valid',
        tokenTypeKey: 'Bearer',
        lastLoginAtKey: now
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch
            .toString(),
      });
      const FlutterSecureStorage storage = FlutterSecureStorage();
      final UserRepository repository = UserRepository(
        dataSource: _NoopUserDataSource(),
        secureStorage: storage,
        nowProvider: () => now,
      );
      final StartupRouteResolver resolver = StartupRouteResolver(
        userRepository: repository,
      );

      final String route = await resolver.resolveInitialRoute();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      expect(route, AppRoutes.mainShell);
      expect(prefs.getBool(StartupRouteResolver.welcomeSeenKey), true);
    },
  );

  test(
    'resolveInitialRoute returns splash for expired token on first launch',
    () async {
      final DateTime now = DateTime.utc(2026, 3, 9, 10);
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        accessTokenKey: 'token-expired',
        tokenTypeKey: 'Bearer',
        lastLoginAtKey: now
            .subtract(const Duration(days: 8))
            .millisecondsSinceEpoch
            .toString(),
      });
      const FlutterSecureStorage storage = FlutterSecureStorage();
      final UserRepository repository = UserRepository(
        dataSource: _NoopUserDataSource(),
        secureStorage: storage,
        nowProvider: () => now,
      );
      final StartupRouteResolver resolver = StartupRouteResolver(
        userRepository: repository,
      );

      final String route = await resolver.resolveInitialRoute();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      expect(route, AppRoutes.splash);
      expect(prefs.getBool(StartupRouteResolver.welcomeSeenKey), true);
    },
  );
}

class _NoopUserDataSource implements UserDataSource {
  @override
  Future<UserProfile> fetchCurrentUser({
    required String accessToken,
    required String tokenType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> loginUser({
    required String phone,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> registerUser({
    required String phone,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> saveUser({
    required UserProfile data,
    required String accessToken,
    required String tokenType,
  }) {
    throw UnimplementedError();
  }
}
