import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/app_scope.dart';
import 'package:pixelpad/core/app/navigation.dart';
import 'package:pixelpad/core/app/routes.dart';
import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  late final UserRepository _repository;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => AppNavigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: 3.1415926,
                          child: Icon(
                            Icons.play_arrow,
                            size: 16,
                            color: Color(0xFFF9F871),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
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
              ),
              const SizedBox(height: 16),
              const Text(
                '欢迎回来',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '请输入手机号与密码登录',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFBFBFBF),
                ),
              ),
              const SizedBox(height: 24),
              _InputField(
                label: '手机号',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _InputField(
                label: '密码',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 18),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFFFB4B4),
                      fontSize: 13,
                    ),
                  ),
                ),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
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
                  child: Text(_loading ? '登录中...' : '登录'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _handleRegister,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF9F871),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('没有账号？去注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (phone.isEmpty || password.isEmpty) {
      setState(() => _error = '请输入手机号和密码');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repository.login(phone: phone, password: password);
      if (!mounted) {
        return;
      }
      AppNavigator.pushNamedAndRemoveUntil(context, AppRoutes.mainShell);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = '登录失败，请检查手机号或密码');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    await AppNavigator.pushNamed(context, AppRoutes.register);
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
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
