import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '主页',
          style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
