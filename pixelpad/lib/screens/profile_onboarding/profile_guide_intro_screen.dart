import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../main_shell.dart';
import 'profile_guide_gender_screen.dart';

class ProfileGuideIntroScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const ProfileGuideIntroScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double totalHeight = constraints.maxHeight;
                final double imageHeight = totalHeight * 0.45;
                return SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/source/login_anime/registration-guide-page.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                );
              },
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => MainShell()),
                          (route) => false,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Transform.rotate(
                            angle: 3.1415926,
                            child: const Icon(
                              Icons.play_arrow,
                              size: 18,
                              color: Color(0xFFF9F871),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double totalHeight = constraints.maxHeight;
                    final double imageHeight = totalHeight * 0.45;
                    final double titleHeight = totalHeight * 0.18;
                    final double purpleHeight = totalHeight * 0.16;

                    return Column(
                      children: [
                        SizedBox(
                          height: imageHeight,
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: titleHeight,
                          child: Center(
                            child: SizedBox(
                              width: 328,
                              child: const Text(
                                '像素世界\n从此由你定义',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFF9F871),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: purpleHeight,
                          width: double.infinity,
                          color: const Color(0xFFB8A6FF),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 323,
                            child: const Text(
                              '嗨，欢迎使用 PixelPad！\n请跟随指引，开启你的创作之旅。',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.14,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF232323),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                          child: _FrostedButton(
                            label: '下一步',
                            onTap: onNext ??
                                () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProfileGuideGenderScreen(),
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrostedButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FrostedButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_FrostedButton> createState() => _FrostedButtonState();
}

class _FrostedButtonState extends State<_FrostedButton> {
  bool _pressed = false;

  void _handleHighlightChanged(bool isPressed) {
    if (_pressed == isPressed) return;
    setState(() => _pressed = isPressed);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: _handleHighlightChanged,
              borderRadius: BorderRadius.circular(999),
              splashColor: Colors.white.withOpacity(0.18),
              highlightColor: Colors.white.withOpacity(0.12),
              child: Ink(
                width: 211,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_pressed ? 0.28 : 0.18),
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
                child: Center(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
