import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'profile_guide_age_screen.dart';

class ProfileGuideGenderScreen extends StatefulWidget {
  final VoidCallback? onNext;

  const ProfileGuideGenderScreen({super.key, this.onNext});

  @override
  State<ProfileGuideGenderScreen> createState() => _ProfileGuideGenderScreenState();
}

class _ProfileGuideGenderScreenState extends State<ProfileGuideGenderScreen> {
  bool _selectedMale = false;
  bool _selectedFemale = false;

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
                    onTap: () => Navigator.of(context).pop(),
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
              '定制你的创作体验',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFB8A6FF),
              child: const Text(
                '此信息仅用于为你提供更相关的个性化服务。\n你也可以选择暂时跳过，直接进入下一步。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF232323),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double size = (constraints.maxHeight * 0.32).clamp(120.0, 160.0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GenderOption(
                          label: '男',
                          icon: Icons.male_rounded,
                          selected: _selectedMale,
                          selectedColor: const Color(0xFFF9F871),
                          onTap: () => setState(() => _selectedMale = !_selectedMale),
                          size: size,
                        ),
                        const SizedBox(height: 18),
                        _GenderOption(
                          label: '女',
                          icon: Icons.female_rounded,
                          selected: _selectedFemale,
                          selectedColor: const Color(0xFFF9F871),
                          onTap: () => setState(() => _selectedFemale = !_selectedFemale),
                          size: size,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _FrostedButton(
                label: '下一步',
                onTap: widget.onNext ??
                    () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileGuideAgeScreen(),
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

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final double size;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = selected ? selectedColor : const Color(0xFF2F2F2F);
    final Color stroke = selected ? selectedColor : Colors.white.withOpacity(0.7);
    final Color iconColor = selected ? const Color(0xFF232323) : Colors.white;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(color: stroke, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: size * 0.4, color: iconColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
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
