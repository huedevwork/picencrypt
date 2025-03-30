import 'dart:io';

import 'package:get/get.dart';
import 'package:mime/mime.dart';

typedef FileTypeCheckTuple = ({int length, List<int> identifiers});

enum FileMimeType {
  jpeg,
  png,
  webp,
  gif;

  static FileMimeType? getByName(String name) {
    if (name.contains('.')) {
      name = name.substring(1);
    }

    if (name == 'jpg') {
      name = FileMimeType.jpeg.name;
    }

    return FileMimeType.values.firstWhereOrNull((element) {
      return element.name == name;
    });
  }
}

class FileMimeTypeCheckUtil {
  static Future<FileMimeType?> checkMimeType({required String filePath}) async {
    final file = File(filePath);
    final opList = await file.openRead(0, 16).expand((x) => x).toList();
    final mimeType = lookupMimeType(file.path, headerBytes: opList);
    if (mimeType == null) {
      return null;
    }
    final extension = extensionFromMime(mimeType);
    if (extension == null) {
      return null;
    }
    final fileMimeType = FileMimeType.getByName(extension);
    return fileMimeType;
  }
}
