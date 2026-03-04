import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/device/data/warehouse_chat_storage.dart';
import 'package:pixelpad/features/device/domain/services/bluetooth_service.dart';
import 'package:pixelpad/features/device/presentation/screens/warehouse_chat_screen.dart';

const List<_MissingColor> _sampleMissingColors = [
  _MissingColor(label: 'H2', borderColor: Color(0xFFBDBDBD)),
  _MissingColor(label: 'F7', borderColor: Color(0xFF1E1E1E)),
  _MissingColor(label: 'F13', borderColor: Color(0xFFE35A5A)),
];

class DeviceScreen extends StatefulWidget {
  final WarehouseChatRepository repository;

  const DeviceScreen({
    super.key,
    WarehouseChatRepository? repository,
  }) : repository = repository ?? const LocalWarehouseChatRepository();

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  static const String _defaultDuration = '1小时20分';
  static const String _deviceNameKey = 'device_custom_name';
  static const List<Color> _defaultSupplementColors = [
    Color(0xFFBDBDBD),
    Color(0xFF1E1E1E),
    Color(0xFFE35A5A),
  ];

  final List<_UsageRecordEntry> _usageRecords = [];
  _RecordFilter _filter = _RecordFilter.all;
  String? _customDeviceName;

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
    _loadUsageRecords();
  }

  Future<void> _loadDeviceName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _customDeviceName = prefs.getString(_deviceNameKey);
    });
  }

  Future<void> _saveDeviceName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceNameKey, name);
  }

  Future<void> _editDeviceName(String current) async {
    final TextEditingController controller =
        TextEditingController(text: current);
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            '修改设备名称',
            style: TextStyle(color: AppColors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: '输入名称',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定', style: TextStyle(color: AppColors.arrow)),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }
    final String trimmed = result.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _customDeviceName = trimmed;
    });
    await _saveDeviceName(trimmed);
  }

  Future<void> _loadUsageRecords() async {
    final List<WarehouseChatRecord> records =
        await widget.repository.load();
    if (!mounted) {
      return;
    }
    final List<_UsageRecordEntry> entries = records
        .where((record) => record.isUser)
        .map(_recordToUsageEntry)
        .whereType<_UsageRecordEntry>()
        .toList();
    setState(() {
      _usageRecords
        ..clear()
        ..addAll(entries.reversed);
    });
  }

  _UsageRecordEntry? _recordToUsageEntry(WarehouseChatRecord record) {
    final RegExp deposit =
        RegExp(r'^我买了(.+?)的豆子(\d+)粒');
    final RegExp withdraw =
        RegExp(r'^取出(.+?)的豆子(\d+)粒');
    final String text = record.text.trim();
    final DateTime timestamp = record.timestamp;

    String? sign;
    int? amount;
    if (deposit.hasMatch(text)) {
      final Match match = deposit.firstMatch(text)!;
      sign = '+';
      amount = int.tryParse(match.group(2) ?? '');
    } else if (withdraw.hasMatch(text)) {
      final Match match = withdraw.firstMatch(text)!;
      sign = '-';
      amount = int.tryParse(match.group(2) ?? '');
    }

    if (sign == null || amount == null) {
      return null;
    }

    final String monthLabel = '${timestamp.month}月';
    final String dayLabel = timestamp.day.toString().padLeft(2, '0');
    final String amountLabel = '$sign${_formatAmount(amount)}';

    return _UsageRecordEntry(
      monthLabel: monthLabel,
      dayLabel: dayLabel,
      amountLabel: amountLabel,
      duration: _defaultDuration,
      isDeposit: sign == '+',
      supplementColors: _defaultSupplementColors,
    );
  }

  String _formatAmount(int value) {
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

  List<_UsageRecordEntry> _filteredRecords() {
    switch (_filter) {
      case _RecordFilter.deposit:
        return _usageRecords.where((record) => record.isDeposit).toList();
      case _RecordFilter.withdraw:
        return _usageRecords.where((record) => !record.isDeposit).toList();
      case _RecordFilter.all:
      default:
        return _usageRecords;
    }
  }

  @override
  Widget build(BuildContext context) {
    final BluetoothTransferService btService = BluetoothTransferService();
    // TODO: replace sample data with repository/provider-driven user data.
    final List<_MissingColor> missingColors = _sampleMissingColors;
    final List<String> missingColorLabels =
        missingColors.map((color) => color.label).toList();

    return SafeArea(
      child: ValueListenableBuilder<bool>(
        valueListenable: btService.connectionNotifier,
        builder: (context, connected, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DeviceHeader(),
                const SizedBox(height: 16),
                _DeviceNameRow(
                  name: _customDeviceName ??
                      (connected ? btService.deviceName : 'MyPixel'),
                  onTap: () => _editDeviceName(
                    _customDeviceName ??
                        (connected ? btService.deviceName : 'MyPixel'),
                  ),
                ),
                const SizedBox(height: 12),
                _DeviceSummaryCard(
                  missingColors: missingColors,
                  onWarehouseTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => WarehouseChatScreen(
                          missingColors: missingColorLabels,
                          repository: widget.repository,
                        ),
                      ),
                    )
                        .then((_) => _loadUsageRecords());
                  },
                ),
                const SizedBox(height: 14),
                const _UsageHeatmap(),
                const SizedBox(height: 12),
                _RecordFilterBar(
                  filter: _filter,
                  onChanged: (value) {
                    setState(() {
                      _filter = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Divider(
                    color: AppColors.white.withValues(alpha: 0.7), height: 1),
                const SizedBox(height: 12),
                ..._filteredRecords().map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UsageRecordCard(record: record),
                    )),
              ],
            ),
          );
        },
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
          '像素管理',
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

class _DeviceNameRow extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _DeviceNameRow({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
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
      ),
    );
  }
}

class _DeviceSummaryCard extends StatelessWidget {
  final List<_MissingColor> missingColors;
  final VoidCallback onWarehouseTap;

  const _DeviceSummaryCard({
    required this.missingColors,
    required this.onWarehouseTap,
  });

  static const String _totalIconSvg =
      '<svg width="30" height="30" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="14.5588" cy="14.5588" r="14.5588" fill="#F9F871"/></svg>';
  static const String _colorIconSvg =
      '<svg width="30" height="30" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="14.5588" cy="14.5588" r="14.5588" fill="#B3A0FF"/></svg>';
  static const List<Color> _missingRingColors = [
    Color(0xFFBDBDBD),
    Color(0xFF1E1E1E),
    Color(0xFFE35A5A),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6CFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _SummaryPillRow(
                          iconSvg: _totalIconSvg,
                          label: '总量：',
                          value: '42,293,299',
                          suffix: 'Bd',
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 230,
                          child: _SummaryPillRow(
                            iconSvg: _colorIconSvg,
                            label: '色号数：',
                            value: '221',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const _SummaryBars(
                colors: _missingRingColors,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: _MissingColorsPanel(missingColors: missingColors),
              ),
              const Spacer(),
              _WarehousePanel(onTap: onWarehouseTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPillRow extends StatelessWidget {
  final String iconSvg;
  final String label;
  final String value;
  final String? suffix;

  const _SummaryPillRow({
    required this.iconSvg,
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          SvgPicture.string(iconSvg, width: 22, height: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8D6CFC),
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8D6CFC),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBars extends StatelessWidget {
  final List<Color> colors;

  const _SummaryBars({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      width: 88,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _SummaryBar(
              height: 46,
              width: 12,
              color: colors.isNotEmpty ? colors[0] : const Color(0xFF1C1C1C),
            ),
            const SizedBox(width: 8),
            _SummaryBar(
              height: 66,
              width: 12,
              color: colors.length > 1 ? colors[1] : const Color(0xFF8D6CFC),
            ),
            const SizedBox(width: 8),
            _SummaryBar(
              height: 86,
              width: 12,
              color: colors.length > 2 ? colors[2] : const Color(0xFFE0705C),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final double height;
  final Color color;
  final double width;

  const _SummaryBar({
    required this.height,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white, width: 1),
      ),
    );
  }
}

class _MissingColorsPanel extends StatelessWidget {
  final List<_MissingColor> missingColors;

  const _MissingColorsPanel({required this.missingColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F871),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '严重缺色：',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < missingColors.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                _MissingColorChip(
                  label: missingColors[i].label,
                  borderColor: missingColors[i].borderColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MissingColor {
  final String label;
  final Color borderColor;

  const _MissingColor({required this.label, required this.borderColor});
}

class _MissingColorChip extends StatelessWidget {
  final String label;
  final Color borderColor;

  const _MissingColorChip({
    required this.label,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }
}

class _WarehousePanel extends StatelessWidget {
  final VoidCallback onTap;

  const _WarehousePanel({required this.onTap});

  static const String _warehouseIcon = 'assets/source/warehouse_icon.png';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 104,
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Image(
                      image: AssetImage(_warehouseIcon),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  right: 10,
                  top: 8,
                  bottom: 8,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '仓',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8D6CFC),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '库',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8D6CFC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

class _UsageRecordEntry {
  final String monthLabel;
  final String dayLabel;
  final String amountLabel;
  final String duration;
  final bool isDeposit;
  final List<Color> supplementColors;

  const _UsageRecordEntry({
    required this.monthLabel,
    required this.dayLabel,
    required this.amountLabel,
    required this.duration,
    required this.isDeposit,
    required this.supplementColors,
  });
}

class _UsageRecordCard extends StatelessWidget {
  final _UsageRecordEntry record;

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
                  record.monthLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.dayLabel,
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
                  '数量',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.amountLabel,
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
                Text(
                  record.isDeposit ? '补充颜色' : '用时',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                if (record.isDeposit)
                  _SupplementColorRings(colors: record.supplementColors)
                else
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
}

class _SupplementColorRings extends StatelessWidget {
  final List<Color> colors;

  const _SupplementColorRings({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: colors[i], width: 3),
            ),
          ),
        ],
      ],
    );
  }
}

class _UsageHeatmap extends StatelessWidget {
  const _UsageHeatmap();

  static const List<double> _opacity = [
    1,
    0.25,
    0.35,
    0.45,
    0.6,
    1,
    0.85,
    0.4,
    0.55,
    0.3,
    0.2,
    0.35,
    0.5,
    0.75,
    1,
    0.9,
    0.6,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF212020),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < _opacity.length; i++)
            Container(
              width: 12,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.arrow.withValues(alpha: _opacity[i]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
        ],
      ),
    );
  }
}

enum _RecordFilter { all, deposit, withdraw }

class _RecordFilterBar extends StatelessWidget {
  final _RecordFilter filter;
  final ValueChanged<_RecordFilter> onChanged;

  const _RecordFilterBar({
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: '所有',
          selected: filter == _RecordFilter.all,
          onTap: () => onChanged(_RecordFilter.all),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: '入库',
          selected: filter == _RecordFilter.deposit,
          onTap: () => onChanged(_RecordFilter.deposit),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: '出库',
          selected: filter == _RecordFilter.withdraw,
          onTap: () => onChanged(_RecordFilter.withdraw),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = selected ? AppColors.arrow : AppColors.white;
    final Color textColor =
        selected ? const Color(0xFF1E1E1E) : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
