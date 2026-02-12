import 'package:flutter/material.dart';

import 'dependencies.dart';

class AppScope extends InheritedWidget {
  final AppDependencies dependencies;

  const AppScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => dependencies != oldWidget.dependencies;
}
