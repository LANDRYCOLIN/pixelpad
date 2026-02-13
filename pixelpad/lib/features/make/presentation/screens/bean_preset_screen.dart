import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixelpad/core/app/navigation.dart';
import 'package:pixelpad/core/theme/app_theme.dart';

const String _presetBrandKey = 'bean_preset_brand';
const String _presetCountKey = 'bean_preset_count';

const List<String> _beanBrands = [
  'Coco',
  'DMC',
  'manifest',
  '卡卡家',
  '漫漫家',
  '盼盼拼豆',
  'MARD',
];

const List<int> _colorCounts = [
  24,
  48,
  72,
  96,
  120,
  144,
  221,
  295,
];

class BeanPresetScreen extends StatefulWidget {
  const BeanPresetScreen({super.key});

  @override
  State<BeanPresetScreen> createState() => _BeanPresetScreenState();
}

class _BeanPresetScreenState extends State<BeanPresetScreen> {
  late final PageController _brandController;
  late final PageController _countController;
  int _brandIndex = _beanBrands.indexOf('MARD');
  int _countIndex = _colorCounts.indexOf(144);

  @override
  void initState() {
    super.initState();
    if (_brandIndex < 0) {
      _brandIndex = 0;
    }
    if (_countIndex < 0) {
      _countIndex = 0;
    }
    _brandController = PageController(
      viewportFraction: 0.26,
      initialPage: _brandIndex,
    );
    _countController = PageController(
      viewportFraction: 0.22,
      initialPage: _countIndex,
    );
    _loadPreset();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _onBrandChanged(int index) {
    setState(() => _brandIndex = index);
  }

  void _onCountChanged(int index) {
    setState(() => _countIndex = index);
  }

  Future<void> _loadPreset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedBrand = prefs.getString(_presetBrandKey);
    final int? savedCount = prefs.getInt(_presetCountKey);

    int nextBrand = _brandIndex;
    int nextCount = _countIndex;

    if (savedBrand != null) {
      final int index = _beanBrands.indexOf(savedBrand);
      if (index >= 0) {
        nextBrand = index;
      }
    }

    if (savedCount != null) {
      final int index = _colorCounts.indexOf(savedCount);
      if (index >= 0) {
        nextCount = index;
      }
    }

    if (!mounted) return;
    setState(() {
      _brandIndex = nextBrand;
      _countIndex = nextCount;
    });
    _brandController.jumpToPage(nextBrand);
    _countController.jumpToPage(nextCount);
  }

  Future<void> _savePreset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_presetBrandKey, _beanBrands[_brandIndex]);
    await prefs.setInt(_presetCountKey, _colorCounts[_countIndex]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存预设')),
    );
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
            const SizedBox(height: 18),
            const Text(
              '选择你的豆子',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '这能帮助我们为你定制更适合的创作旅程。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFFBFBFBF),
              ),
            ),
            const SizedBox(height: 18),
            _PickerBar(
              controller: _brandController,
              itemCount: _beanBrands.length,
              onPageChanged: _onBrandChanged,
              itemBuilder: (context, index, scale, opacity) {
                final String label = _beanBrands[index];
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: opacity),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            const Text(
              '选择颜色数量',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '选色越多，后续作图可选颜色越丰富。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFFBFBFBF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_colorCounts[_countIndex]}',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Icon(
              Icons.arrow_drop_up,
              size: 36,
              color: Color(0xFFF9F871),
            ),
            const SizedBox(height: 12),
            _PickerBar(
              controller: _countController,
              itemCount: _colorCounts.length,
              onPageChanged: _onCountChanged,
              itemBuilder: (context, index, scale, opacity) {
                final int value = _colorCounts[index];
                return Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: opacity),
                  ),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _FrostedButton(
                label: '保存',
                onTap: _savePreset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerBar extends StatelessWidget {
  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageChanged;
  final Widget Function(
    BuildContext context,
    int index,
    double scale,
    double opacity,
  ) itemBuilder;

  const _PickerBar({
    required this.controller,
    required this.itemCount,
    required this.onPageChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      color: const Color(0xFFB8A6FF),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth * controller.viewportFraction;
          final double centerX = constraints.maxWidth / 2;
          final double lineOffset = itemWidth * 0.6;

          return Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: controller,
                  itemCount: itemCount,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        final double page = controller.hasClients
                            ? controller.page ?? controller.initialPage.toDouble()
                            : controller.initialPage.toDouble();
                        final double distance = (page - index).abs().clamp(0.0, 2.0);
                        final double scale = 1 - (distance * 0.15);
                        final double opacity = 1 - (distance * 0.3);

                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: itemBuilder(context, index, scale, opacity),
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
