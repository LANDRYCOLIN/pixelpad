import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app/app.dart';
import 'core/app/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies();
  await dependencies.logService.recordLaunch();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(PixelPadApp(dependencies: dependencies));
}
