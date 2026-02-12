import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/app_scope.dart';
import 'package:pixelpad/core/app/navigation.dart';
import 'package:pixelpad/core/app/routes.dart';
import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/profile/domain/entities/user_profile.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';
import 'package:pixelpad/features/profile/presentation/widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserRepository _repository;
  UserProfile? _profile;
  bool _loading = true;
  bool _didLoadDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDependencies) {
      return;
    }
    _repository = AppScope.of(context).userRepository;
    _didLoadDependencies = true;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    UserProfile? data;
    try {
      data = await _repository.fetchCurrentUser();
    } catch (_) {
      data = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }
    if (_profile == null) {
      return _LoggedOutState(
        onLogin: _handleLogin,
      );
    }
    final profile = _profile!;
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
                        final result = await AppNavigator.pushNamed(
                          context,
                          AppRoutes.profileEdit,
                        );
                        if (!mounted || result is! UserProfile) {
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
                    ProfileMenuItem(
                      iconAsset: 'assets/profile/icon-logout.svg',
                      label: '退出账号',
                      onTap: _handleLogout,
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

  Future<void> _handleLogin() async {
    final result = await AppNavigator.pushNamed(context, AppRoutes.login);
    if (!mounted || result is! UserProfile) {
      return;
    }
    setState(() {
      _profile = result;
      _loading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _repository.logout();
    if (!mounted) {
      return;
    }
    setState(() => _profile = null);
  }
}

class _LoggedOutState extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoggedOutState({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '个人中心',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.header,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 42,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '未登录',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '登录后可查看与编辑个人信息',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9F871),
                          foregroundColor: const Color(0xFF232323),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('去登录'),
                      ),
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
  final UserProfile profile;

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
              child: profile.avatarMode == UserAvatarMode.logo
                  ? Image.asset(
                      'assets/source/logo.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    )
                  : Text(
                      _initials(profile.username),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(profile.username, style: AppTextStyles.profileName),
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
      color: AppColors.white.withValues(alpha: 0.5),
    );
  }
}

