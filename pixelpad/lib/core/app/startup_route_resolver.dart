import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixelpad/features/profile/data/user_repository.dart';

import 'routes.dart';

typedef SharedPreferencesProvider = Future<SharedPreferences> Function();

class StartupRouteResolver {
  StartupRouteResolver({
    required UserRepository userRepository,
    SharedPreferencesProvider? preferencesProvider,
  }) : _userRepository = userRepository,
       _preferencesProvider =
           preferencesProvider ?? SharedPreferences.getInstance;

  static const String welcomeSeenKey = 'app_welcome_seen_v1';

  final UserRepository _userRepository;
  final SharedPreferencesProvider _preferencesProvider;

  Future<String> resolveInitialRoute() async {
    final String? accessToken = await _userRepository.getAccessToken();
    final SharedPreferences prefs = await _preferencesProvider();

    if (accessToken != null) {
      await _markWelcomeSeen(prefs);
      return AppRoutes.mainShell;
    }

    final bool hasSeenWelcome = prefs.getBool(welcomeSeenKey) ?? false;
    if (!hasSeenWelcome) {
      await _markWelcomeSeen(prefs);
      return AppRoutes.splash;
    }
    return AppRoutes.login;
  }

  Future<String> resolvePostWelcomeRoute() async {
    final String? accessToken = await _userRepository.getAccessToken();
    if (accessToken != null) {
      final SharedPreferences prefs = await _preferencesProvider();
      await _markWelcomeSeen(prefs);
      return AppRoutes.mainShell;
    }
    return AppRoutes.login;
  }

  Future<void> _markWelcomeSeen(SharedPreferences prefs) async {
    if (prefs.getBool(welcomeSeenKey) ?? false) {
      return;
    }
    await prefs.setBool(welcomeSeenKey, true);
  }
}
