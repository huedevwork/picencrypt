import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picencrypt/utils/compute_util.dart';
import 'package:picencrypt/utils/create_file_name_util.dart';
import 'package:picencrypt/utils/logger_utils.dart';

Future<void> openPlatformImageService(img.Image image) async {
  final LoggerUtils logger = LoggerUtils();

  await EasyLoading.show(status: 'Loading...');

  try {
    final imageData = await ComputeUtil.handle(
      param: image,
      processingFunction: (path) => img.encodeJpg(image),
    );

    String timeName = CreateFileNameUtil.timeName();

    final directory = await getTemporaryDirectory();
    final filePath = p.join(directory.path, 'temp_image_$timeName.jpg');

    final file = File(filePath);
    await file.writeAsBytes(imageData);

    EasyLoading.dismiss();

    if (Platform.isWindows) {
      await Process.start('explorer', [filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [filePath]);
    } else {
      EasyLoading.dismiss();

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

      logger.w('Unsupported platform');
    }
  } catch (e, s) {
    EasyLoading.dismiss();

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

    logger.e('打开图片出错', error: e, stackTrace: s);
  }
}
