import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pixelpad/features/device/domain/services/bluetooth_service.dart';

/// 蓝牙上传对话框（已废弃）。
///
/// 保留此文件作为向后兼容，实际上传逻辑已移至
/// `MakeResultScreen` 内置的 `_BluetoothUploadProgressDialog`。
class BluetoothUploadDialog extends StatefulWidget {
  final Uint8List imageBytes;

  const BluetoothUploadDialog({super.key, required this.imageBytes});

  static Future<bool?> show(BuildContext context, Uint8List imageBytes) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BluetoothUploadDialog(imageBytes: imageBytes),
    );
  }

  @override
  State<BluetoothUploadDialog> createState() => _BluetoothUploadDialogState();
}

class _BluetoothUploadDialogState extends State<BluetoothUploadDialog> {
  final BluetoothTransferService _btService = BluetoothTransferService();

  double _progress = 0.0;
  String _status = '准备传输...';
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    if (!_btService.isConnected) {
      if (mounted) {
        setState(() {
          _error = '设备未连接，请先在首页连接蓝牙设备';
          _status = '传输失败';
        });
      }
      return;
    }
    try {
      setState(() {
        _status = '正在传输数据到 ${_btService.deviceName}...';
      });
      await _btService.uploadImage(widget.imageBytes, (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
            if (progress >= 1.0) {
              _status = '传输完成！';
              _done = true;
            }
          });
        }
      });
      if (mounted && !_done) {
        setState(() {
          _status = '传输完成！';
          _done = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '传输失败: $e';
          _status = '传输失败';
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
              '传输到设备',
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
              _status,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: const Color(0xFF2E2E2E),
              color: const Color(0xFFF9F871),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_done);
                  if (_done && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('已成功发送到设备！')));
                  }
                },
                child: Text(
                  _done || _error != null ? '关闭' : '取消',
                  style: const TextStyle(color: Color(0xFFF9F871)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
