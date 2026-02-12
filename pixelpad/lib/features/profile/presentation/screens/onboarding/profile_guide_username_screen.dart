import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/app_scope.dart';
import 'package:pixelpad/core/app/navigation.dart';
import 'package:pixelpad/core/app/routes.dart';
import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';

class ProfileGuideUsernameScreen extends StatefulWidget {
  const ProfileGuideUsernameScreen({super.key});

  @override
  State<ProfileGuideUsernameScreen> createState() => _ProfileGuideUsernameScreenState();
}

class _ProfileGuideUsernameScreenState extends State<ProfileGuideUsernameScreen> {
  late final UserRepository _repository;
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _didLoadDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDependencies) {
      return;
    }
    _repository = AppScope.of(context).userRepository;
    _didLoadDependencies = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请输入用户名');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _repository.fetchCurrentUser();
      if (profile == null) {
        if (!mounted) return;
        setState(() => _error = '未找到用户信息');
        return;
      }
      final updated = profile.copyWith(username: name);
      await _repository.saveCurrentUser(updated);
      if (!mounted) return;
      AppNavigator.pushNamedAndRemoveUntil(context, AppRoutes.mainShell);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '保存失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => AppNavigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.play_arrow,
                            size: 16,
                            color: Color(0xFFF9F871),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '返回',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF9F871),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '欢迎入住',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                '在这里，你将拥有一个独一无二的创作身份。未来所有的灵感、作品与成长记录都将在此安家。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFFBFBFBF),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFB8A6FF),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/source/logo.png',
                          width: 46,
                          height: 46,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9F871),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Color(0xFF232323),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '用户名称',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF232323),
                    ),
                    decoration: InputDecoration(
                      hintText: 'PixelPad',
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFFFB4B4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: 160,
                height: 44,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9F871),
                    foregroundColor: const Color(0xFF232323),
                    shape: const StadiumBorder(),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(_loading ? '保存中...' : '开始'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
