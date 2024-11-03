import 'dart:io';

class FileTypeUtil {
  static Future<bool> checkFileIsGif(String filePath) async {
    bool areListsEqual(List<int> list1, List<int> list2) {
      if (list1.length != list2.length) return false;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) return false;
      }
      return true;
    }

    final stream = await File(filePath).openRead(0, 6).toList();
    final headerBytes = stream.expand((e) => e).toList();

    const headGIF87a = [0x47, 0x49, 0x46, 0x38, 0x37, 0x61];
    const headGIF89a = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61];
    const headList = [headGIF87a, headGIF89a];

    List<bool> resultList = [];

    for (final heads in headList) {
      bool value = areListsEqual(headerBytes, heads);
      resultList.add(value);
    }

    return resultList.any((element) => element == true);
  }
}
