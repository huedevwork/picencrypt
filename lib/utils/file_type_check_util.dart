import 'dart:io';

import 'package:get/get.dart';

enum FileSuffixType {
  /// jpg
  jpg(
    suffix: '.jpg',
    readLength: 3,
    identifiers: [
      [0xFF, 0xD8, 0xFF]
    ],
  ),

  /// jpeg
  jpeg(
    suffix: '.jpeg',
    readLength: 3,
    identifiers: [
      [0xFF, 0xD8, 0xFF]
    ],
  ),

  /// png
  png(
    suffix: '.png',
    readLength: 8,
    identifiers: [
      [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    ],
  ),

  /// webp
  webp(
    suffix: '.webp',
    readLength: 12,
    identifiers: [
      [0x52, 0x49, 0x46, 0x46, 0x34, 0x2E, 0x57, 0x45, 0x42]
    ],
  ),

  /// gif
  gif(
    suffix: '.gif',
    readLength: 6,
    identifiers: [
      [0x47, 0x49, 0x46, 0x38, 0x37, 0x61],
      [0x47, 0x49, 0x46, 0x38, 0x39, 0x61],
    ],
  );

  const FileSuffixType({
    required this.suffix,
    required this.readLength,
    required this.identifiers,
  });

  final String suffix;
  final int readLength;
  final List<List<int>> identifiers;

  static FileSuffixType? getBySuffix(String name) {
    return FileSuffixType.values.firstWhereOrNull((element) {
      return element.name == name || element.suffix == name;
    });
  }
}

class FileTypeCheckUtil {
  static Future<bool> checkFileIdentifier({
    required String filePath,
    required FileSuffixType fileSuffixType,
  }) async {
    bool areListsEqual(List<int> list1, List<int> list2) {
      if (list1.length != list2.length) return false;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) return false;
      }
      return true;
    }

    final file = File(filePath);
    final stream = await file.openRead(0, fileSuffixType.readLength).toList();
    final headerBytes = stream.expand((e) => e).toList();

    List<bool> resultList = [];

    for (final list in fileSuffixType.identifiers) {
      bool value = areListsEqual(headerBytes, list);
      resultList.add(value);
    }

    return resultList.any((element) => element == true);
  }
}
