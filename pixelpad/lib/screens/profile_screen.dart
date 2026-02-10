import 'package:flutter/material.dart';

import '../data/profile_data.dart';
import '../data/profile_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_menu_item.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  ProfileData? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _repository.fetchProfile();
    if (!mounted) {
      return;
    }
    setState(() => _profile = data);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile ?? ProfileData.initial();
    final age = _calculateAge(profile.birthday);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _HeaderSection(profile: profile),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -36,
                    child: _StatsCard(
                      mbti: profile.mbti,
                      age: age,
                      location: '重庆',
                    ),
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
                      onTap: () async {
                        final result = await Navigator.of(context).push<ProfileData>(
                          MaterialPageRoute(
                            builder: (_) => const ProfileEditScreen(),
                          ),
                        );
                        if (!mounted || result == null) {
                          return;
                        }
                        setState(() => _profile = result);
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

  int _calculateAge(DateTime birthday) {
    final today = DateTime.now();
    var age = today.year - birthday.year;
    final beforeBirthday = today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day);
    if (beforeBirthday) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }
}

class _HeaderSection extends StatelessWidget {
  final ProfileData profile;

  const _HeaderSection({required this.profile});

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
              child: profile.avatarMode == ProfileAvatarMode.logo
                  ? Image.asset(
                      'assets/source/logo.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    )
                  : Text(
                      _initials(profile.name),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(profile.name, style: AppTextStyles.profileName),
          const SizedBox(height: 4),
          Text(profile.email, style: AppTextStyles.profileEmail),
          const SizedBox(height: 4),
          Text(
            '生日：${_formatBirthday(profile.birthday)}',
            style: AppTextStyles.profileMeta,
          ),
        ],
      ),
    );
  }

  String _formatBirthday(DateTime birthday) {
    return '${birthday.month}月${birthday.day}日';
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'P';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _StatsCard extends StatelessWidget {
  final String mbti;
  final int age;
  final String location;

  const _StatsCard({
    required this.mbti,
    required this.age,
    required this.location,
  });

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
        children: [
          _StatItem(value: mbti, label: '人格'),
          const _StatDivider(),
          _StatItem(value: age.toString(), label: '年龄'),
          const _StatDivider(),
          _StatItem(value: location, label: '地区'),
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
