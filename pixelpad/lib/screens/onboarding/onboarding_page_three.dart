import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../main_shell.dart';
import 'onboarding_page_four.dart';

class OnboardingPageThree extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const OnboardingPageThree({
    super.key,
    this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double panelWidth = constraints.maxWidth;
          final double panelHeight = min(169, constraints.maxHeight * 0.28);
          final double buttonWidth = min(211, constraints.maxWidth * 0.6);

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/source/login_anime/background3.png',
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.35),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 16),
                    child: GestureDetector(
                      onTap: onSkip ??
                          () => Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const MainShell(),
                                ),
                                (route) => false,
                              ),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '跳过',
                            style: TextStyle(
                              color: AppColors.arrow,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.arrow,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: panelWidth,
                      height: panelHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8A6FF),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/source/login_anime/onboarding_icon2.svg',
                            width: 44,
                            height: 44,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '创造，属于你的拼豆作品',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _IndicatorDot(isActive: false),
                              const SizedBox(width: 6),
                              _IndicatorDot(isActive: true),
                              const SizedBox(width: 6),
                              _IndicatorDot(isActive: false),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: onNext ??
                          () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const OnboardingPageFour(),
                                ),
                              ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: buttonWidth,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              '下一步',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  final bool isActive;

  const _IndicatorDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: isActive ? 18 : 12,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 1 : 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
