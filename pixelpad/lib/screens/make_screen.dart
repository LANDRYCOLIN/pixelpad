import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MakeScreen extends StatelessWidget {
  const MakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '图片制作',
          style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
