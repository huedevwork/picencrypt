import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 请求权限的方法
  static Future<bool> requestPermission({
    required BuildContext context,
    required Permission permission,
  }) async {
    // 检查当前权限状态
    var status = await permission.status;

    if (status.isGranted) {
      return true; // 权限已授予
    } else if (status.isDenied) {
      // 用户拒绝权限，提示用户
      await _showPermissionDialog(context, permission);
      return false; // 权限被拒绝
    } else if (status.isPermanentlyDenied) {
      // 权限被永久拒绝，提示用户去设置中修改
      await _showSettingsDialog(context);
      return false; // 权限被永久拒绝
    }

    // 请求权限
    final result = await permission.request();
    return result.isGranted;
  }

  // 显示权限说明对话框
  static Future<void> _showPermissionDialog(
    BuildContext context,
    Permission permission,
  ) async {
    // 在这里根据权限类型自定义提示信息
    String message = '';
    if (permission == Permission.storage) {
      message = '我们需要存储权限来保存文件。请授予权限。';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('权限请求'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        );
      },
    );
  }

  // 显示设置提示对话框
  static Future<void> _showSettingsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('权限被永久拒绝'),
          content: const Text('请前往设置中手动授予权限。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        );
      },
    );
  }
}
