import 'package:flutter/widgets.dart';

import 'package:pixelpad/features/device/presentation/screens/device_screen.dart';
import 'package:pixelpad/features/home/presentation/screens/home_screen.dart';
import 'package:pixelpad/features/make/presentation/screens/make_screen.dart';
import 'package:pixelpad/features/profile/presentation/screens/profile_screen.dart';

class MainShellTab {
  final String label;
  final String iconAsset;
  final WidgetBuilder builder;

  const MainShellTab({
    required this.label,
    required this.iconAsset,
    required this.builder,
  });
}

final List<MainShellTab> mainShellTabs = [
  MainShellTab(
    label: '主页',
    iconAsset: 'assets/tabbar/home.png',
    builder: (_) => const HomeScreen(),
  ),
  MainShellTab(
    label: '图片制作',
    iconAsset: 'assets/tabbar/make.png',
    builder: (_) => const MakeScreen(),
  ),
  MainShellTab(
    label: '设备管理',
    iconAsset: 'assets/tabbar/device.png',
    builder: (_) => const DeviceScreen(),
  ),
  MainShellTab(
    label: '个人中心',
    iconAsset: 'assets/tabbar/profile.png',
    builder: (_) => const ProfileScreen(),
  ),
];
