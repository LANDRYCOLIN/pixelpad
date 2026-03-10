import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/app_scope.dart';
import 'package:pixelpad/core/app/dependencies.dart';
import 'package:pixelpad/core/app/routes.dart';
import 'package:pixelpad/core/theme/app_theme.dart';

class PixelPadApp extends StatelessWidget {
  final AppDependencies dependencies;
  final String initialRoute;

  const PixelPadApp({
    required this.dependencies,
    this.initialRoute = AppRoutes.splash,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: dependencies,
      child: MaterialApp(
        title: 'PixelPad',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: initialRoute,
        routes: AppRoutes.routes,
      ),
    );
  }
}
