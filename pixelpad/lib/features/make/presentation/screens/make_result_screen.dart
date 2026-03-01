import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/make/data/make_api.dart';

class DetectedColor {
  final String id;
  final int count;
  final String hex;
  final List<int> rgba;

  const DetectedColor({
    required this.id,
    required this.count,
    required this.hex,
    required this.rgba,
  });
}

class MakeResultScreen extends StatefulWidget {
  final String sessionId;
  final List<DetectedColor> detectedColors;
  final int width;
  final int height;

  const MakeResultScreen({
    super.key,
    required this.sessionId,
    required this.detectedColors,
    required this.width,
    required this.height,
  });

  @override
  State<MakeResultScreen> createState() => _MakeResultScreenState();
}

class _MakeResultScreenState extends State<MakeResultScreen> {
  Uint8List? _imageBytes;
  bool _loading = false;
  String? _error;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _fetchRenderImage();
  }

  Future<void> _fetchRenderImage({String? colorId}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Uri url = Uri.parse('$makeApiBaseUrl/render');
      final Map<String, String> body = {
        'session_id': widget.sessionId,
      };
      if (colorId != null && colorId.isNotEmpty) {
        body['color_id'] = colorId;
      }
      final http.Response response = await http.post(url, body: body);
      if (response.statusCode != 200) {
        throw Exception('Render failed: ${response.statusCode}');
      }
      if (!mounted) return;
      setState(() {
        _imageBytes = response.bodyBytes;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _toggleColor(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
    if (_selected.isEmpty) {
      _fetchRenderImage();
      return;
    }
    final List<String> selectedIds = _selected.toList()..sort();
    _fetchRenderImage(colorId: selectedIds.join(','));
  }

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
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ResultPreviewCard(
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : _imageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: SizedBox.expand(
                                    child: Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      isAntiAlias: false,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _error ?? '暂无预览',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF9A9A9A),
                                    ),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 4),
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _ColorsSection(
                          tokens: widget.detectedColors
                              .map(
                                (color) => _ColorToken(
                                  color.id,
                                  _colorFromHex(color.hex),
                                ),
                              )
                              .toList(),
                          selected: _selected,
                          onToggle: _toggleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
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
    final double width = MediaQuery.of(context).size.width;
    final double horizontalPadding = 32;
    final double height = width - horizontalPadding * 2;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.header,
      ),
      child: SizedBox(
        height: height,
        child: child,
      ),
    );
  }
}

class _ColorsSection extends StatelessWidget {
  final List<_ColorToken> tokens;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ColorsSection({
    required this.tokens,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionPill(label: 'Colors'),
        const SizedBox(height: 12),
        if (tokens.isEmpty)
          const Text(
            '暂无颜色数据',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9A9A9A),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tokens
                .map((token) => _ColorTokenChip(
                      label: token.label,
                      color: token.color,
                      selected: selected.contains(token.label),
                      onTap: () => onToggle(token.label),
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
        border: Border.all(color: AppColors.header, width: 1),
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
  final bool selected;
  final VoidCallback onTap;

  const _ColorTokenChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: AppColors.white,
                  width: selected ? 3 : 1,
                ),
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
                border: Border.all(color: AppColors.white, width: 1),
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
            if (selected)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F26B),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Color(0xFF1A1A1A),
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

Color _colorFromHex(String hex) {
  final String normalized = hex.replaceAll('#', '');
  if (normalized.length != 6) {
    return const Color(0xFF000000);
  }
  final int value = int.parse(normalized, radix: 16);
  return Color(0xFF000000 | value);
}
