import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'onboarding/onboarding_page_two.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _advanceStep() {
    if (_step < 2) {
      setState(() {
        _step += 1;
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingPageTwo(),
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showWordmark = _step >= 1;
    final bool showWelcome = _step >= 2;
    final bool showTapHint = _step == 0;

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: GestureDetector(
        onTap: _advanceStep,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.splashBackground),
            AnimatedOpacity(
              opacity: showWelcome ? 1 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: Image.asset(
                'assets/source/login_anime/background1.png',
                fit: BoxFit.cover,
              ),
            ),
            AnimatedOpacity(
              opacity: showWelcome ? 1 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            AnimatedAlign(
              alignment: const Alignment(0, 0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: showWelcome ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      'Welcome to',
                      style: AppTextStyles.wordmark.copyWith(
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    height: showWelcome ? 14 : 0,
                  ),
                  Image.asset(
                    'assets/source/logo.png',
                    width: 108,
                    height: 108,
                    fit: BoxFit.contain,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    height: showWelcome ? 20 : 12,
                  ),
                  AnimatedOpacity(
                    opacity: showWordmark ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      'PixelPad',
                      style: AppTextStyles.wordmark.copyWith(
                        fontSize: 30,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: showTapHint ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: FadeTransition(
                    opacity: _pulse,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 20,
                          color: AppColors.wordmark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '轻触以开始',
                          style: AppTextStyles.wordmark.copyWith(
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
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
}
