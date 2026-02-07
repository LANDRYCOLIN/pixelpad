import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/logs_screen.dart';
import 'screens/splash_screen.dart';
import 'services/log_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogService.recordLaunch();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PixelPadApp());
}

class PixelPadApp extends StatelessWidget {
  const PixelPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelPad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
      routes: {
        LogsScreen.routeName: (_) => const LogsScreen(),
      },
    );
  }
}
