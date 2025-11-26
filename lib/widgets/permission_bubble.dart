import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限提示气泡组件
class PermissionBubble extends StatefulWidget {
  final VoidCallback? onDismiss;

  const PermissionBubble({super.key, this.onDismiss});

  @override
  State<PermissionBubble> createState() => _PermissionBubbleState();
}

class _PermissionBubbleState extends State<PermissionBubble> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    '开启相机权限',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  print('🔘 点击开启相机权限按钮');
                  
                  // 先关闭气泡
                  if (widget.onDismiss != null) {
                    widget.onDismiss!();
                  }
                  
                  // 延迟后请求权限
                  await Future.delayed(const Duration(milliseconds: 300));
                  print('📱 请求相机权限...');
                  final status = await Permission.camera.request();
                  print('✅ 权限请求结果: $status');
                  
                  // 如果权限仍然被拒绝，引导用户去设置
                  if (status.isPermanentlyDenied) {
                    print('⚠️ 权限被永久拒绝，打开设置页面');
                    await Future.delayed(const Duration(milliseconds: 500));
                    await AppSettings.openAppSettings(
                      type: AppSettingsType.settings,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '开启相机权限',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
