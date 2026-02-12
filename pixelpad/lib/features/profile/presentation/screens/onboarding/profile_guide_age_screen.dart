import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/navigation.dart';
import 'package:pixelpad/core/app/routes.dart';
import 'package:pixelpad/core/theme/app_theme.dart';

class ProfileGuideAgeScreen extends StatefulWidget {
  final VoidCallback? onNext;

  const ProfileGuideAgeScreen({super.key, this.onNext});

  @override
  State<ProfileGuideAgeScreen> createState() => _ProfileGuideAgeScreenState();
}

class _ProfileGuideAgeScreenState extends State<ProfileGuideAgeScreen> {
  static const int _minAge = 0;
  static const int _maxAge = 100;
  late final PageController _controller;
  int _currentAge = 28;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.2, initialPage: _currentAge);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentAge = index);
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
              '请输入你的年龄',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '这能帮助我们为你定制更合适的创作旅程。\n你也可以选择暂时跳过，直接进入下一步。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFFBFBFBF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$_currentAge',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Icon(
              Icons.arrow_drop_up,
              size: 36,
              color: Color(0xFFF9F871),
            ),
            const SizedBox(height: 16),
            Container(
              height: 96,
              width: double.infinity,
              color: const Color(0xFFB8A6FF),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth = constraints.maxWidth * 0.2;
                  final double centerX = constraints.maxWidth / 2;
                  final double lineOffset = itemWidth * 0.6;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: _maxAge - _minAge + 1,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                final double page = _controller.hasClients
                                    ? _controller.page ??
                                        _controller.initialPage.toDouble()
                                    : _controller.initialPage.toDouble();
                                final double distance =
                                    (page - index).abs().clamp(0.0, 2.0);
                                final double scale = 1 - (distance * 0.15);
                                final double opacity = 1 - (distance * 0.3);

                                return Center(
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Text(
                                        '${index + _minAge}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: centerX - lineOffset,
                        top: (96 - 62) / 2,
                        child: Container(
                          width: 2,
                          height: 62,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Positioned(
                        left: centerX + lineOffset - 2,
                        top: (96 - 62) / 2,
                        child: Container(
                          width: 2,
                          height: 62,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _FrostedButton(
                label: '下一步',
                onTap: widget.onNext ??
                    () => AppNavigator.pushNamed(
                          context,
                          AppRoutes.profileGuideUsername,
                        ),
              ),
            ),
          ],
        ),
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
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.12),
              child: Ink(
                width: 211,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _pressed ? 0.28 : 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
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

