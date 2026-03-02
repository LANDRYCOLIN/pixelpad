import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pixelpad/core/theme/app_theme.dart';
import 'package:pixelpad/features/device/domain/services/bluetooth_service.dart';

/// 蓝牙设备扫描和连接对话框。
///
/// 从首页 HeroCard 触发，扫描附近设备列表供用户选择并建立连接。
class BluetoothConnectDialog extends StatefulWidget {
  const BluetoothConnectDialog({super.key});

  /// 弹出蓝牙连接对话框，返回是否成功连接。
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BluetoothConnectDialog(),
    );
  }

  @override
  State<BluetoothConnectDialog> createState() => _BluetoothConnectDialogState();
}

class _BluetoothConnectDialogState extends State<BluetoothConnectDialog> {
  final BluetoothTransferService _btService = BluetoothTransferService();

  bool _isScanning = false;
  bool _isConnecting = false;
  List<ScanResult> _devices = [];
  StreamSubscription? _scanSub;
  String _statusMessage = '扫描设备中...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (await FlutterBluePlus.isSupported == false) {
      if (mounted) {
        setState(() {
          _error = '此设备不支持蓝牙';
          _statusMessage = '扫描失败';
        });
      }
      return;
    }

    setState(() {
      _isScanning = true;
      _devices = [];
      _statusMessage = '扫描附近蓝牙设备...';
      _error = null;
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _devices = results
                .where((r) => r.device.platformName.isNotEmpty)
                .toList();
          });
        }
      });
      await Future.delayed(const Duration(seconds: 4));
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '扫描失败: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusMessage = _devices.isEmpty ? '未发现可用设备' : '请选择目标设备（需先开机）';
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _scanSub?.cancel();
    await FlutterBluePlus.stopScan();

    setState(() {
      _isConnecting = true;
      _statusMessage = '正在连接到 ${device.platformName}...';
      _error = null;
    });

    try {
      await _btService.connect(device);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _error = '连接失败: $e';
          _statusMessage = '请重试或选择其他设备';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '连接蓝牙设备',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9F871),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 14, color: AppColors.white),
            ),
            const SizedBox(height: 16),
            if (_isConnecting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: Color(0xFFF9F871)),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: _devices.isEmpty
                    ? Center(
                        child: _isScanning
                            ? const CircularProgressIndicator(
                                color: Color(0xFFF9F871),
                              )
                            : const Text(
                                '未发现设备',
                                style: TextStyle(color: Colors.grey),
                              ),
                      )
                    : ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final result = _devices[index];
                          return ListTile(
                            title: Text(
                              result.device.platformName,
                              style: const TextStyle(color: AppColors.white),
                            ),
                            subtitle: Text(
                              result.device.remoteId.str,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(
                              Icons.bluetooth,
                              color: Color(0xFFF9F871),
                            ),
                            onTap: () => _connectToDevice(result.device),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isConnecting)
                  TextButton(
                    onPressed: _isScanning ? null : _startScan,
                    child: const Text(
                      '重新扫描',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    _isConnecting ? '取消' : '关闭',
                    style: const TextStyle(color: Color(0xFFF9F871)),
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
