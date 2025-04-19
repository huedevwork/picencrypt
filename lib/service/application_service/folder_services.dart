import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picencrypt/utils/file_type_check_util.dart';

Future<List<String>?> folderServices() async {
  try {
    final downloadsDir = await getDownloadsDirectory();
    String? directoryPath = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
      initialDirectory: downloadsDir?.path,
    );
    if (directoryPath == null) {
      return null;
    }

    await EasyLoading.show(status: 'Loading...');

    Directory directory = Directory(directoryPath);
    List<FileSystemEntity> files = directory.listSync(recursive: true);

    final fileSuffixTypes = [FileMimeType.jpeg, FileMimeType.png];

    List<String> imageFiles = [];

    for (final file in files) {
      final extension = p.extension(file.path).toLowerCase();
      final type = fileSuffixTypes.firstWhereOrNull((element) {
        return FileMimeType.getByName(extension) != null;
      });
      if (type != null) {
        FileMimeType? fileMimeType = await FileMimeTypeCheckUtil.checkMimeType(
          filePath: file.path,
        );
        if (fileMimeType != null) {
          imageFiles.add(file.path);
        }
      }
    }

    EasyLoading.dismiss();

    if (imageFiles.isEmpty) {
      return null;
    }

    return imageFiles;
  } catch (e) {
    EasyLoading.dismiss();
    rethrow;
  }
}
