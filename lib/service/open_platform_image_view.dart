import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picencrypt/utils/create_file_name_util.dart';

Future<void> openPlatformImageService(img.Image image) async {
  try {
    String timeName = CreateFileNameUtil.timeName();

    final directory = await getTemporaryDirectory();
    final filePath = p.join(directory.path, 'temp_image_$timeName.png');

    final file = File(filePath);
    await file.writeAsBytes(img.encodeJpg(image));

    if (Platform.isWindows) {
      await Process.start('explorer', [filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [filePath]);
    } else {
      showDialog(
        context: Get.context!,
        builder: (_) {
          return AlertDialog(
            content: const Text('暂不支持此平台查看图片'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(Get.context!).pop(true),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );

      throw UnsupportedError('Unsupported platform');
    }
  } catch (e, s) {
    debugPrint('Error opening image: $e');
    debugPrintStack(stackTrace: s);

    showDialog(
      context: Get.context!,
      builder: (_) {
        return AlertDialog(
          title: const Text('打开图片出错'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(Get.context!).pop(true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
