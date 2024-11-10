import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:picencrypt/utils/file_type_check_util.dart';

Future<List<String>?> folderServices() async {
  try {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) {
      return null;
    }

    Directory directory = Directory(directoryPath);
    List<FileSystemEntity> files = directory.listSync();

    final suffixNames = [
      FileSuffixType.jpg,
      FileSuffixType.jpeg,
      FileSuffixType.png,
      FileSuffixType.webp,
    ].map((e) => e.suffix).toList();

    List<FileSystemEntity> temps = files.where((file) {
      final extension = path.extension(file.path).toLowerCase();
      return suffixNames.contains(extension);
    }).toList();

    List<String> imageFiles = [];

    for (final fileEntity in temps) {
      if (fileEntity is File) {
        final extension = path.extension(fileEntity.path).toLowerCase();
        final fileSuffixType = FileSuffixType.getBySuffix(extension);
        if (fileSuffixType != null) {
          bool value = await FileTypeCheckUtil.checkFileIdentifier(
            filePath: fileEntity.path,
            fileSuffixType: fileSuffixType,
          );
          if (value) {
            imageFiles.add(fileEntity.path);
          }
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
