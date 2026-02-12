import 'package:flutter/material.dart';

import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/core/app/main_shell_tabs.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = mainShellTabs
      .map((tab) => Builder(builder: tab.builder))
      .toList(growable: false);

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.header,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.tabUnselected,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          for (final tab in mainShellTabs)
            BottomNavigationBarItem(
              icon: _TabIcon(asset: tab.iconAsset),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  final String asset;

  const _TabIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}
