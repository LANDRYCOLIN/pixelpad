import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/profile_menu_item.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: const [
                  _HeaderSection(),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -36,
                    child: _StatsCard(),
                  ),
                ],
              ),
              const SizedBox(height: 56),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-user.svg',
                      label: '个人信息',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileEditScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-favorite.svg',
                      label: '收藏',
                    ),
                    const SizedBox(height: 8),
                    const ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-privacy.svg',
                      label: '隐私保护',
                    ),
                    const SizedBox(height: 8),
                    const ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-settings.svg',
                      label: '设置',
                    ),
                    const SizedBox(height: 8),
                    const ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-service.svg',
                      label: '客服',
                    ),
                    const SizedBox(height: 8),
                    const ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-logout.svg',
                      label: '退出账号',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 72),
      color: AppColors.header,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '个人中心',
              style: AppTextStyles.pageTitle.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/source/logo.png',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Pixel Pad', style: AppTextStyles.profileName),
          const SizedBox(height: 4),
          const Text('pixelpad@example.com', style: AppTextStyles.profileEmail),
          const SizedBox(height: 4),
          const Text('生日：11月15日', style: AppTextStyles.profileMeta),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          _StatItem(value: 'INFP', label: '人格'),
          _StatDivider(),
          _StatItem(value: '18', label: '年龄'),
          _StatDivider(),
          _StatItem(value: '重庆', label: '地区'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTextStyles.statsValue),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.statsLabel),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.white.withOpacity(0.5),
    );
  }
}
