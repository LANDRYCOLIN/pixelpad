import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'device_screen.dart';
import 'home_screen.dart';
import 'make_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MakeScreen(),
    DeviceScreen(),
    ProfileScreen(),
  ];

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
        items: const [
          BottomNavigationBarItem(
            icon: _TabIcon(asset: 'assets/tabbar/home.png'),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(asset: 'assets/tabbar/make.png'),
            label: '图片制作',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(asset: 'assets/tabbar/device.png'),
            label: '设备管理',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(asset: 'assets/tabbar/profile.png'),
            label: '个人中心',
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
