import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pixelpad/core/app/app_scope.dart';
import 'package:pixelpad/core/app/navigation.dart';
import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/profile/domain/entities/user_profile.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final UserRepository _repository;
  late final TextEditingController _nameController;
  late final TextEditingController _mbtiController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthdayController;

  UserAvatarMode _avatarMode = UserAvatarMode.logo;
  DateTime _birthday = UserProfile.initial().birthday;
  UserProfile? _currentProfile;
  bool _loading = true;
  bool _saving = false;
  bool _didLoadDependencies = false;

  @override
  void initState() {
    super.initState();
    final initial = UserProfile.initial();
    _nameController = TextEditingController(text: initial.username);
    _mbtiController = TextEditingController(text: initial.mbti);
    _emailController = TextEditingController(text: initial.email);
    _birthdayController = TextEditingController(text: _formatBirthday(initial.birthday));
    _avatarMode = initial.avatarMode;
    _birthday = initial.birthday;
    _nameController.addListener(() {
      if (!mounted || _avatarMode != UserAvatarMode.initials) {
        return;
      }
      setState(() {});
    });
  }

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
    final data = await _repository.fetchCurrentUser();
    if (!mounted) {
      return;
    }
    if (data == null) {
      setState(() {
        _loading = false;
        _currentProfile = null;
      });
      return;
    }
    setState(() {
      _loading = false;
      _currentProfile = data;
      _avatarMode = data.avatarMode;
      _birthday = data.birthday;
      _nameController.text = data.username;
      _mbtiController.text = data.mbti;
      _emailController.text = data.email;
      _birthdayController.text = _formatBirthday(data.birthday);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mbtiController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BackButton(
                onTap: () => AppNavigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Text(
                '欢迎入驻',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '在这里，你将拥有一个独一无二的创作身份。未来所有的灵感、作品与成长记录都将在此安家。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Color(0xFFBFBFBF),
                ),
              ),
              const SizedBox(height: 24),
              _AvatarCard(
                avatarMode: _avatarMode,
                name: _nameController.text,
                onTapEdit: _showAvatarPicker,
              ),
              const SizedBox(height: 24),
              _FieldSection(
                label: '用户名',
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              _FieldSection(
                label: 'MBTI人格',
                controller: _mbtiController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              _FieldSection(
                label: '邮箱',
                controller: _emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _FieldSection(
                label: '生日',
                controller: _birthdayController,
                textInputAction: TextInputAction.done,
                readOnly: true,
                onTap: _pickBirthday,
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 173,
                  height: 47,
                  child: ElevatedButton(
                    onPressed: _saving || _currentProfile == null ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9F871),
                      foregroundColor: const Color(0xFF232323),
                      shape: const StadiumBorder(),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    child: Text(_saving ? '保存中...' : '保存'),
                  ),
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              if (!_loading && _currentProfile == null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      '未登录，无法编辑资料',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFBFBFBF),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.background,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _birthday = picked;
      _birthdayController.text = _formatBirthday(picked);
    });
  }

  Future<void> _showAvatarPicker() async {
    final result = await showModalBottomSheet<UserAvatarMode>(
      context: context,
      backgroundColor: const Color(0xFF2B2B2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '选择头像样式',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              _AvatarOption(
                title: '使用Logo头像',
                onTap: () => AppNavigator.pop(context, UserAvatarMode.logo),
              ),
              const SizedBox(height: 8),
              _AvatarOption(
                title: '使用首字母头像',
                onTap: () => AppNavigator.pop(context, UserAvatarMode.initials),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) {
      return;
    }
    setState(() => _avatarMode = result);
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final base = _currentProfile ?? UserProfile.initial();
    final data = base.copyWith(
      username: _nameController.text.trim(),
      mbti: _mbtiController.text.trim(),
      email: _emailController.text.trim(),
      birthday: _birthday,
      avatarMode: _avatarMode,
    );
    await _repository.saveCurrentUser(data);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    AppNavigator.pop(context, data);
  }

  String _formatBirthday(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Color(0xFFF9F871),
              ),
              SizedBox(width: 4),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: Color(0xFFF9F871),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final UserAvatarMode avatarMode;
  final String name;
  final VoidCallback onTapEdit;

  const _AvatarCard({
    required this.avatarMode,
    required this.name,
    required this.onTapEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 143,
      decoration: BoxDecoration(
        color: const Color(0xFFB3A0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: avatarMode == UserAvatarMode.logo
                    ? Image.asset(
                        'assets/source/logo.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        _initials(name),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: -6,
              bottom: -6,
              child: InkWell(
                onTap: onTapEdit,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F871),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/profile/icon-edit.svg',
                      width: 14,
                      height: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'P';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _AvatarOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AvatarOption({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _FieldSection extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const _FieldSection({
    required this.label,
    required this.controller,
    required this.textInputAction,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF232323),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
