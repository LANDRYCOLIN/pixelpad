import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app/app.dart';
import 'core/app/dependencies.dart';
import 'core/app/startup_route_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies();
  await dependencies.logService.recordLaunch();
  final StartupRouteResolver startupRouteResolver = StartupRouteResolver(
    userRepository: dependencies.userRepository,
  );
  final String initialRoute = await startupRouteResolver.resolveInitialRoute();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(PixelPadApp(dependencies: dependencies, initialRoute: initialRoute));
}
