import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:picencrypt/utils/file_type_check_util.dart';

Future<List<String>?> folderServices() async {
  try {
    String? directoryPath = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );
    if (directoryPath == null) {
      return null;
    }

    Directory directory = Directory(directoryPath);
    List<FileSystemEntity> files = directory.listSync(recursive: true);

    final fileSuffixTypes = [
      FileMimeType.jpeg,
      FileMimeType.png,
      FileMimeType.webp,
    ];

    List<String> imageFiles = [];

    for (final file in files) {
      final extension = path.extension(file.path).toLowerCase();
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

    if (imageFiles.isEmpty) {
      return null;
    }

    return imageFiles;
  } catch (e) {
    rethrow;
  }
}
