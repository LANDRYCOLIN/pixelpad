import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pixelpad/core/theme/app_theme.dart';

class MakeScreen extends StatelessWidget {
  const MakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _MakeHeader(),
            SizedBox(height: 18),
            _MakeBody(),
          ],
        ),
      ),
    );
  }
}

class _MakeHeader extends StatelessWidget {
  const _MakeHeader();

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
          '显示',
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

class _MakeBody extends StatelessWidget {
  const _MakeBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择图纸',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9F871),
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.white.withValues(alpha: 0.7), height: 1),
        const SizedBox(height: 16),
        const _MakeOptionCard(
          title: '上传图片',
          subtitle: '上传图片以创建图纸',
          image: 'assets/source/upload.png',
          imageCover: false,
        ),
        const SizedBox(height: 16),
        Divider(color: AppColors.white.withValues(alpha: 0.7), height: 1),
        const SizedBox(height: 16),
        const _MakeOptionCard(
          title: '编辑文本',
          subtitle: '编辑文本以创建图纸',
          image: 'assets/source/editword.png',
          imageCover: true,
        ),
        const SizedBox(height: 16),
        Divider(color: AppColors.white.withValues(alpha: 0.7), height: 1),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.header,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const _GalleryCard(),
        ),
      ],
    );
  }
}

class _MakeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool imageCover;

  const _MakeOptionCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.imageCover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 120,
            height: 86,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(18)),
              child: Container(
                color: imageCover ? Colors.transparent : const Color(0xFFEADFD3),
                child: imageCover
                    ? Image.asset(
                        image,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Image.asset(
                          image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '我的图库',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF9F871),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '收藏或设计你的图纸',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 110,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFBFC3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/source/mygallery.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

