import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pixelpad/core/theme/app_theme.dart';

class MakeResultScreen extends StatelessWidget {
  const MakeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _ResultHeader(onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF404040), height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ResultPreviewCard(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '图片预览区域',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFF404040), height: 1),
                    const SizedBox(height: 12),
                    const _ColorsSection(),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF404040), height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: '存储到图库',
                            background: const Color(0xFF2E2E2E),
                            borderColor: const Color(0xFF6C6C6C),
                            textColor: AppColors.white,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: '确认',
                            background: const Color(0xFF2E2E2E),
                            borderColor: const Color(0xFF6C6C6C),
                            textColor: AppColors.white,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ResultHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: const [
                  Icon(Icons.chevron_left, color: AppColors.primary),
                  SizedBox(width: 2),
                  Text(
                    '返回',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const _HeaderIcon(asset: 'assets/source/icon_search.svg'),
          const SizedBox(width: 14),
          const _HeaderIcon(asset: 'assets/source/icon_bell.svg'),
          const SizedBox(width: 14),
          const Icon(Icons.person, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final String asset;

  const _HeaderIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 18,
      height: 18,
      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
    );
  }
}

class _ResultPreviewCard extends StatelessWidget {
  final Widget child;

  const _ResultPreviewCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.header,
        borderRadius: BorderRadius.circular(22),
      ),
      child: SizedBox(
        height: 260,
        child: child,
      ),
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  static const List<_ColorToken> _tokens = [
    _ColorToken('E2', Color(0xFFF7C7D3)),
    _ColorToken('F13', Color(0xFFF27E5C)),
    _ColorToken('F1', Color(0xFFFAD4C3)),
    _ColorToken('F7', Color(0xFF121212)),
    _ColorToken('B14', Color(0xFFBDE36F)),
    _ColorToken('H2', Color(0xFFEFEFEF)),
    _ColorToken('A19', Color(0xFFF5B0B0)),
    _ColorToken('C24', Color(0xFF8CBDF0)),
    _ColorToken('F24', Color(0xFFF2BFD1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionPill(label: 'Colors'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _tokens
              .map((token) => _ColorTokenChip(
                    label: token.label,
                    color: token.color,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SectionPill extends StatelessWidget {
  final String label;

  const _SectionPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF9F871),
        ),
      ),
    );
  }
}

class _ColorToken {
  final String label;
  final Color color;

  const _ColorToken(this.label, this.color);
}

class _ColorTokenChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorTokenChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2B2B2B), width: 1),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
