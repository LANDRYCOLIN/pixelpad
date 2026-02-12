import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/app_scope.dart';
import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/core/utils/format_time.dart';

class LogsScreen extends StatelessWidget {
  static const String routeName = '/logs';

  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logService = AppScope.of(context).logService;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('查看启动日志'),
      ),
      body: FutureBuilder<List<DateTime>>(
        future: logService.getLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? const <DateTime>[];
          if (logs.isEmpty) {
            return const Center(
              child: Text(
                '暂无日志',
                style: TextStyle(color: AppColors.white),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  '${index + 1}. ${formatDateTime(logs[index])}',
                  style: const TextStyle(color: AppColors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
