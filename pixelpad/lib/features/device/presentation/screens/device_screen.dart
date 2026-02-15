import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/device/domain/entities/device_data.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: replace sample data with repository/provider-driven user data.
    final DeviceData data = DeviceData.sample();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DeviceHeader(),
            const SizedBox(height: 16),
            _DeviceFilterRow(status: data.status),
            const SizedBox(height: 14),
            _BatteryRow(
              percent: data.batteryPercent,
              idleState: data.idleState,
            ),
            const SizedBox(height: 10),
            _DeviceNameRow(name: data.name),
            const SizedBox(height: 14),
            _ParameterCard(metrics: data.metrics),
            const SizedBox(height: 18),
            const _SectionTitle(title: '使用记录'),
            const SizedBox(height: 10),
            Divider(color: AppColors.white.withValues(alpha: 0.7), height: 1),
            const SizedBox(height: 12),
            ...data.records.map((record) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UsageRecordCard(record: record),
                )),
          ],
        ),
      ),
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader();

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
          '设备管理',
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

class _DeviceFilterRow extends StatelessWidget {
  final String status;

  const _DeviceFilterRow({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            label: status,
            background: const Color(0xFFF9F871),
            textColor: const Color(0xFF232323),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _FilterChip(
            label: '更换设备',
            background: AppColors.white,
            textColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _FilterChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _BatteryRow extends StatelessWidget {
  final int percent;
  final String idleState;

  const _BatteryRow({required this.percent, required this.idleState});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BatteryIndicator(percent: percent),
        const SizedBox(width: 6),
        Text(
          '$percent%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF9F871),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F871),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          idleState,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF9F871),
          ),
        ),
      ],
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final int percent;

  const _BatteryIndicator({required this.percent});

  @override
  Widget build(BuildContext context) {
    final double ratio = (percent.clamp(0, 100)) / 100;

    return SizedBox(
      width: 33,
      height: 18,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 2,
            top: 3,
            bottom: 3,
            right: 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F871),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),
          SvgPicture.asset(
            'assets/source/device_battery_outline.svg',
            width: 33,
            height: 18,
          ),
        ],
      ),
    );
  }
}

class _DeviceNameRow extends StatelessWidget {
  final String name;

  const _DeviceNameRow({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '设备名称：$name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 25 / 24,
            color: Color(0xFFF9F871),
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.chevron_right,
          color: Color(0xFFF9F871),
          size: 20,
        ),
      ],
    );
  }
}

class _ParameterCard extends StatelessWidget {
  final List<DeviceMetric> metrics;

  const _ParameterCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    const double scale = 2 / 3;
    const double fontScale = 0.9;
    const double chartInset = 6 * scale;
    const double axisLabelWidth = 26 * scale;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16 * scale,
        14 * scale,
        16 * scale,
        16 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: const Color(0xFF6A6A6A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _YAxisLabels(
                  width: axisLabelWidth,
                  height: 140 * scale,
                  scale: fontScale,
                ),
                const SizedBox(width: 12 * scale),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: chartInset),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: metrics.map((metric) {
                        return Expanded(
                          child: _MetricBar(metric: metric, scale: scale),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10 * scale),
          Divider(color: AppColors.white.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: 10 * scale),
          Row(
            children: [
              const SizedBox(width: axisLabelWidth),
              const SizedBox(width: 12 * scale),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: chartInset),
                  child: Row(
                    children: metrics.map<Widget>(
                      (metric) => Expanded(
                        child: Text(
                          metric.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF9F871),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YAxisLabels extends StatelessWidget {
  final double width;
  final double height;
  final double scale;

  const _YAxisLabels({
    required this.width,
    required this.height,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '100',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF9F871),
            ),
          ),
          Text(
            '75',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF9F871),
            ),
          ),
          Text(
            '50',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF9F871),
            ),
          ),
          Text(
            '25',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF9F871),
            ),
          ),
          Text(
            '0',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF9F871),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final DeviceMetric metric;
  final double scale;

  const _MetricBar({required this.metric, required this.scale});

  @override
  Widget build(BuildContext context) {
    final double ratio = (metric.value.clamp(0, 100)) / 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E3E3),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F871),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF9F871),
      ),
    );
  }
}

class _UsageRecordCard extends StatelessWidget {
  final DeviceRecord record;

  const _UsageRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6CFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  record.weekday,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.day.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.white.withValues(alpha: 0.25),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Beans',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatBeans(record.beans),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.white.withValues(alpha: 0.25),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/source/device_time.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.duration,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBeans(int value) {
    final String raw = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final int indexFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

