import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 请求权限的方法
  static Future<bool> requestPermission({
    required BuildContext context,
    required Permission permission,
  }) async {
    PermissionStatus status = await permission.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      await _showPermissionDialog(context, permission);
      return false;
    } else if (status.isPermanentlyDenied) {
      await _showSettingsDialog(context);
      return false; // 权限被永久拒绝
    }

    // 请求权限
    final result = await permission.status;
    return result.isGranted;
  }

  static Future<void> _showPermissionDialog(
    BuildContext context,
    Permission permission,
  ) async {
    String message = '请授予应用相应权限';
    if (permission == Permission.photos) {
      message = '请授予媒体权限来保存文件。';
    } else if (permission == Permission.storage ||
        permission == Permission.manageExternalStorage) {
      message = '请授予存储权限来保存文件。';
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
