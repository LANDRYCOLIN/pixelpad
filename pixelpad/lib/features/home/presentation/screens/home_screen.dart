import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pixelpad/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HomeHeader(),
            SizedBox(height: 16),
            _HomeBody(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.arrow,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '主页',
          style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
        ),
        const Spacer(),
        const _HeaderIcon(asset: 'assets/source/icon_search.svg', size: 20),
        const SizedBox(width: 16),
        const _HeaderIcon(asset: 'assets/source/icon_bell.svg', size: 20),
        const SizedBox(width: 16),
        const _HeaderIcon(asset: 'assets/source/icon_settings.svg', size: 20),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final String asset;
  final double size;

  const _HeaderIcon({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  static const List<String> _communityImages = [
    'assets/source/community-example1.png',
    'assets/source/community-example2.png',
    'assets/source/community-example3.png',
    'assets/source/community-example4.png',
    'assets/source/community-example5.png',
    'assets/source/community-example6.png',
    'assets/source/community-example7.png',
    'assets/source/community-example8.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.header,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const _HeroCard(),
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.white.withValues(alpha: 0.7), height: 1),
        const SizedBox(height: 12),
        const Text(
          'PixelShare 社区',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: Color(0xFFF9F871),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12;
            final double itemWidth = (constraints.maxWidth - spacing) / 2;
            final List<Widget> leftColumn = [];
            final List<Widget> rightColumn = [];

            for (int index = 0; index < _communityImages.length; index += 1) {
              final Widget card = _CommunityCard(
                image: _communityImages[index],
                featured: index.isEven,
                width: itemWidth,
              );
              if (index.isEven) {
                leftColumn.add(card);
                if (index + 2 < _communityImages.length) {
                  leftColumn.add(const SizedBox(height: spacing));
                }
              } else {
                rightColumn.add(card);
                if (index + 2 < _communityImages.length) {
                  rightColumn.add(const SizedBox(height: spacing));
                }
              }
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: leftColumn,
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: rightColumn,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(
                'assets/source/home-example.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              color: const Color(0xFF3A3A3A),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '待机中',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/source/icon_battery.svg',
                    width: 18,
                    height: 10,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '93%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'MyPixel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final String image;
  final bool featured;
  final double width;

  const _CommunityCard({
    required this.image,
    required this.featured,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Image.asset(
                image,
                width: width,
                fit: BoxFit.fitWidth,
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xCC1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/source/icon_like.svg',
                        width: 9,
                        height: 9,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '120',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/source/icon_time.svg',
                        width: 10,
                        height: 9,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '12min',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (featured)
                const Positioned(
                  right: 10,
                  top: 10,
                  child: Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF9F871),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

