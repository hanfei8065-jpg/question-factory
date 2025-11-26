import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import '../utils/device_utils.dart';

class CameraPermissionGuide extends StatelessWidget {
  final VoidCallback onPermissionGranted;

  const CameraPermissionGuide({super.key, required this.onPermissionGranted});

  Future<void> _requestCameraPermission(BuildContext context) async {
    // 首次尝试请求权限
    final result = await Permission.camera.request();

    if (result.isGranted) {
      onPermissionGranted();
      return;
    }

    // 如果用户拒绝了，显示品牌特定的引导对话框
    if (context.mounted) {
      final guide = DeviceUtils.getPermissionGuide();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('开启相机权限'),
          content: Text('请按以下步骤开启相机权限：\n\n$guide'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('稍后再说'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                AppSettings.openAppSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Stack 作为背景，显示相机预览的UI
    return Stack(
      children: [
        // 模拟相机预览的背景
        Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.camera_alt, size: 120, color: Colors.black45),
          ),
        ),

        // 半透明遮罩
        Container(color: Colors.black.withOpacity(0.3)),

        // 居中的权限引导
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  '开启相机权限，体验智能拍题功能',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '在${DeviceUtils.getPermissionGuide()}中开启',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _requestCameraPermission(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('立即开启'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
