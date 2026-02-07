import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '设备管理',
          style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
