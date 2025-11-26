import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static String? _cachedBrand;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> getDeviceBrand() async {
    if (_cachedBrand != null) return _cachedBrand!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedBrand = androidInfo.brand.toLowerCase();
        return _cachedBrand!;
      } else if (Platform.isIOS) {
        _cachedBrand = 'apple';
        return _cachedBrand!;
      }
    } catch (e) {
      print('获取设备信息失败: $e');
    }

    _cachedBrand = 'unknown';
    return _cachedBrand!;
  }

  static Future<String> getPermissionGuide() async {
    final brand = await getDeviceBrand();

    if (brand.contains('xiaomi') || brand.contains('redmi')) {
      return '设置 > 隐私保护 > 权限管理 > 相机 > Learnest';
    } else if (brand.contains('huawei') || brand.contains('honor')) {
      return '设置 > 应用和服务 > 应用管理 > Learnest > 权限 > 相机';
    } else if (brand.contains('oppo')) {
      return '设置 > 隐私 > 权限管理 > 相机 > Learnest';
    } else if (brand.contains('vivo')) {
      return '设置 > 隐私 > 权限管理 > 相机 > Learnest';
    } else if (brand.contains('samsung')) {
      return '设置 > 应用 > Learnest > 权限 > 相机';
    } else if (brand == 'apple') {
      return '设置 > 隐私与安全性 > 相机 > Learnest';
    }

    return '设置 > 应用权限 > 相机 > Learnest';
  }

  // 同步版本（用于UI显示，使用缓存值）
  static String getPermissionGuideSync() {
    final brand = _cachedBrand ?? 'unknown';

    if (brand.contains('xiaomi') || brand.contains('redmi')) {
      return '设置 > 隐私保护 > 权限管理 > 相机 > Learnest';
    } else if (brand.contains('huawei') || brand.contains('honor')) {
      return '设置 > 应用和服务 > 应用管理 > Learnest > 权限 > 相机';
    } else if (brand.contains('oppo')) {
      return '设置 > 隐私 > 权限管理 > 相机 > Learnest';
    } else if (brand.contains('vivo')) {
      return '设置 > 隐私 > 权限管理 > 相机 > Learnest';
    } else if (brand.contains('samsung')) {
      return '设置 > 应用 > Learnest > 权限 > 相机';
    } else if (brand == 'apple') {
      return '设置 > 隐私与安全性 > 相机 > Learnest';
    }

    return '设置 > 应用权限 > 相机 > Learnest';
  }
}
