import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/device/data/warehouse_chat_storage.dart';

class WarehouseChatScreen extends StatefulWidget {
  final List<String> missingColors;
  final WarehouseChatRepository repository;

  const WarehouseChatScreen({
    super.key,
    required this.missingColors,
    WarehouseChatRepository? repository,
  }) : repository = repository ?? const LocalWarehouseChatRepository();

  @override
  State<WarehouseChatScreen> createState() => _WarehouseChatScreenState();
}

class _WarehouseChatScreenState extends State<WarehouseChatScreen> {
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  _ComposerMode _mode = _ComposerMode.none;
  String _selectedLetter = 'A';
  int _selectedNumber = 1;
  int _selectedAmount = 10200;
  String? _manualCode;
  // TODO: replace fixed stats with repository-driven data.
  final _WarehouseStats _stats = const _WarehouseStats(
    favoriteBeans: [
      _BeanRing(label: 'H2', ringColor: Color(0xFFF5F871)),
      _BeanRing(label: 'F7', ringColor: Color(0xFF1E1E1E)),
      _BeanRing(label: 'E5', ringColor: Color(0xFFE35A9B)),
      _BeanRing(label: 'F1', ringColor: Color(0xFFEF8B6B)),
      _BeanRing(label: 'F13', ringColor: Color(0xFFB86142)),
    ],
    minBeans: 24,
    maxBeans: 1220464,
  );

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _appendMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
    _saveMessages();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _loadMessages() async {
    final List<WarehouseChatRecord> stored =
        await widget.repository.load();
    if (!mounted) {
      return;
    }
    if (stored.isNotEmpty) {
      setState(() {
        _messages
          ..clear()
          ..addAll(stored.map(_ChatMessage.fromRecord));
      });
      _scrollToBottom();
      return;
    }

    final List<_ChatMessage> initial = _buildInitialMessages();
    setState(() {
      _messages
        ..clear()
        ..addAll(initial);
    });
    await _saveMessages();
  }

  List<_ChatMessage> _buildInitialMessages() {
    final String colorText = widget.missingColors.isNotEmpty
        ? widget.missingColors.join('、')
        : '部分色号';
    final DateTime now = DateTime.now();
    return [
      _ChatMessage(
        text: '今天有完成拼豆小目标吗？',
        isUser: false,
        timestamp: now,
      ),
      _ChatMessage(
        text: '这几天我看你$colorText的豆子数量要少了，记得及时补货哦！',
        isUser: false,
        timestamp: now,
      ),
    ];
  }

  Future<void> _saveMessages() async {
    final List<WarehouseChatRecord> records =
        _messages.map((msg) => msg.toRecord()).toList();
    await widget.repository.save(records);
  }

  String _currentCode() {
    if (_manualCode != null && _manualCode!.trim().isNotEmpty) {
      return _manualCode!.trim();
    }
    return '$_selectedLetter$_selectedNumber';
  }

  Future<void> _sendActionMessage() async {
    final String code = _currentCode();
    final int amount = _selectedAmount;
    if (amount <= 0) {
      return;
    }
    if (_mode == _ComposerMode.deposit) {
      _appendMessage('我买了$code的豆子$amount粒。', isUser: true);
      await Future.delayed(const Duration(milliseconds: 350));
      _appendMessage('好的，已经记录$code+$amount', isUser: false);
    } else if (_mode == _ComposerMode.withdraw) {
      _appendMessage('取出$code的豆子$amount粒', isUser: true);
      await Future.delayed(const Duration(milliseconds: 350));
      _appendMessage('好的，已经记录$code-$amount', isUser: false);
    }
  }

  Future<void> _pickManualCode() async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            '手动输入色号',
            style: TextStyle(color: AppColors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: '如 H2',
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

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _manualCode = result.trim().toUpperCase();
      });
    }
  }

  Future<void> _pickAmount() async {
    final TextEditingController controller =
        TextEditingController(text: _selectedAmount.toString());
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            '输入数量',
            style: TextStyle(color: AppColors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: '豆子数量',
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
    final int? parsed = int.tryParse(result.trim().replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      return;
    }
    setState(() {
      _selectedAmount = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _WarehouseHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_mode != _ComposerMode.none) {
                    setState(() {
                      _mode = _ComposerMode.none;
                    });
                  }
                },
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: _messages[index]);
                  },
                ),
              ),
            ),
            _ChatComposer(
              mode: _mode,
              selectedLetter: _selectedLetter,
              selectedNumber: _selectedNumber,
              selectedAmount: _selectedAmount,
              stats: _stats,
              onToggleMenu: () {
                setState(() {
                  _mode = _mode == _ComposerMode.menu
                      ? _ComposerMode.none
                      : _ComposerMode.menu;
                });
              },
              onSelectDeposit: () {
                setState(() {
                  _mode = _ComposerMode.deposit;
                });
              },
              onSelectWithdraw: () {
                setState(() {
                  _mode = _ComposerMode.withdraw;
                });
              },
              onSelectStats: () {
                setState(() {
                  _mode = _ComposerMode.stats;
                });
              },
              onSelectLetter: (value) {
                setState(() {
                  _selectedLetter = value;
                  _manualCode = null;
                });
              },
              onSelectNumber: (value) {
                setState(() {
                  _selectedNumber = value;
                  _manualCode = null;
                });
              },
              onManualCode: _pickManualCode,
              onPickAmount: _pickAmount,
              onSend: _sendActionMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _WarehouseHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _WarehouseHeader({required this.onBack});

  static const String _warehouseIcon = 'assets/source/warehouse_icon.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, color: AppColors.arrow),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Image(
              image: AssetImage(_warehouseIcon),
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '仓库',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '哇——哇——',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  String get timeLabel => _formatTime(timestamp);

  WarehouseChatRecord toRecord() {
    return WarehouseChatRecord(
      text: text,
      isUser: isUser,
      timestamp: timestamp,
    );
  }

  factory _ChatMessage.fromRecord(WarehouseChatRecord record) {
    return _ChatMessage(
      text: record.text,
      isUser: record.isUser,
      timestamp: record.timestamp,
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor =
        message.isUser ? const Color(0xFFB3A0FF) : AppColors.white;
    final Color textColor =
        message.isUser ? AppColors.white : const Color(0xFF1E1E1E);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.timeLabel,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ComposerMode { none, menu, deposit, withdraw, stats }

class _ChatComposer extends StatelessWidget {
  final _ComposerMode mode;
  final String selectedLetter;
  final int selectedNumber;
  final int selectedAmount;
  final _WarehouseStats stats;
  final VoidCallback onToggleMenu;
  final VoidCallback onSelectDeposit;
  final VoidCallback onSelectWithdraw;
  final VoidCallback onSelectStats;
  final ValueChanged<String> onSelectLetter;
  final ValueChanged<int> onSelectNumber;
  final VoidCallback onManualCode;
  final VoidCallback onPickAmount;
  final VoidCallback onSend;

  const _ChatComposer({
    required this.mode,
    required this.selectedLetter,
    required this.selectedNumber,
    required this.selectedAmount,
    required this.stats,
    required this.onToggleMenu,
    required this.onSelectDeposit,
    required this.onSelectWithdraw,
    required this.onSelectStats,
    required this.onSelectLetter,
    required this.onSelectNumber,
    required this.onManualCode,
    required this.onPickAmount,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bool showMenu = mode == _ComposerMode.menu;
    final bool showSelector =
        mode == _ComposerMode.deposit || mode == _ComposerMode.withdraw;
    final bool showStats = mode == _ComposerMode.stats;
    final String actionText =
        mode == _ComposerMode.withdraw ? '从仓库取豆 - click here' : '向仓库存豆 - click here';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F871),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showStats)
                _StatsPanel(
                  stats: stats,
                ),
              if (showSelector)
                _SelectorPanel(
                  selectedLetter: selectedLetter,
                  selectedNumber: selectedNumber,
                  selectedAmount: selectedAmount,
                  onSelectLetter: onSelectLetter,
                  onSelectNumber: onSelectNumber,
                  onManualCode: onManualCode,
                  onPickAmount: onPickAmount,
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: showMenu
                    ? Column(
                        key: const ValueKey('menu'),
                        children: [
                          _OptionButton(
                            label: '向仓库存豆 - click here',
                            onTap: onSelectDeposit,
                          ),
                          const SizedBox(height: 10),
                          _OptionButton(
                            label: '从仓库取豆 - click here',
                            onTap: onSelectWithdraw,
                          ),
                          const SizedBox(height: 10),
                          _OptionButton(
                            label: '豆仓统计功能 - click here',
                            onTap: onSelectStats,
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('bar'),
                        children: [
                          _CircleIconButton(
                            icon: Icons.attach_file,
                            onTap: onToggleMenu,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: onToggleMenu,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  showSelector ? actionText : '豆仓功能 - 点击这里',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _CircleIconButton(
                            icon: Icons.send,
                            onTap: onSend,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1E1E1E)),
      ),
    );
  }
}

class _SelectorPanel extends StatelessWidget {
  final String selectedLetter;
  final int selectedNumber;
  final int selectedAmount;
  final ValueChanged<String> onSelectLetter;
  final ValueChanged<int> onSelectNumber;
  final VoidCallback onManualCode;
  final VoidCallback onPickAmount;

  const _SelectorPanel({
    required this.selectedLetter,
    required this.selectedNumber,
    required this.selectedAmount,
    required this.onSelectLetter,
    required this.onSelectNumber,
    required this.onManualCode,
    required this.onPickAmount,
  });

  @override
  Widget build(BuildContext context) {
    final String displayCode = selectedLetter;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              _CircleWheelSelector(
                items: List<String>.generate(
                    26, (index) => String.fromCharCode(65 + index)),
                selected: displayCode,
                onSelect: onSelectLetter,
              ),
              const SizedBox(width: 12),
              _CircleWheelSelector(
                items: [
                  ...List<String>.generate(30, (index) => '${index + 1}'),
                  '输入',
                ],
                selected: selectedNumber.toString(),
                onSelect: (value) {
                  if (value == '输入') {
                    onManualCode();
                    return;
                  }
                  onSelectNumber(int.parse(value));
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: onPickAmount,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: _formatAmount(selectedAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(
                            text: ' bd',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _CircleWheelSelector extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CircleWheelSelector({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = items.indexOf(selected);
    final int initialIndex = selectedIndex >= 0 ? selectedIndex : 0;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(26),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: ListWheelScrollView.useDelegate(
          itemExtent: 26,
          physics: const FixedExtentScrollPhysics(),
          controller: FixedExtentScrollController(initialItem: initialIndex),
          onSelectedItemChanged: (index) {
            HapticFeedback.selectionClick();
            onSelect(items[index]);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (context, index) {
              if (index < 0 || index >= items.length) {
                return const SizedBox.shrink();
              }
              final String value = items[index];
              final bool isSelected = value == selected;
              return Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSelected ? 18 : 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WarehouseStats {
  final List<_BeanRing> favoriteBeans;
  final int minBeans;
  final int maxBeans;

  const _WarehouseStats({
    required this.favoriteBeans,
    required this.minBeans,
    required this.maxBeans,
  });
}

class _BeanRing {
  final String label;
  final Color ringColor;

  const _BeanRing({
    required this.label,
    required this.ringColor,
  });
}

class _StatsPanel extends StatelessWidget {
  final _WarehouseStats stats;

  const _StatsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F871),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最受您亲睐的豆子：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: stats.favoriteBeans
                  .map(
                    (bean) => _RingChip(bean: bean),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatValue(
                    title: '拼过最小的图消耗豆子：',
                    value: stats.minBeans,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatValue(
                    title: '拼过最大的图消耗豆子：',
                    value: stats.maxBeans,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingChip extends StatelessWidget {
  final _BeanRing bean;

  const _RingChip({required this.bean});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: bean.ringColor, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        bean.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  final String title;
  final int value;

  const _StatValue({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: _formatAmount(value),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              children: const [
                TextSpan(
                  text: ' Bd',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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

String _formatTime(DateTime value) {
  final TimeOfDay time = TimeOfDay.fromDateTime(value);
  final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final String minute = time.minute.toString().padLeft(2, '0');
  final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}


