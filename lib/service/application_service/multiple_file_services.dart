import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picencrypt/common/local_storage.dart';
import 'package:picencrypt/utils/file_type_check_util.dart';

Future<List<String>?> multipleFileServices() async {
  try {
    final downloadsDir = await getDownloadsDirectory();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: downloadsDir?.path,
      type: FileType.image,
      allowCompression: false,
      compressionQuality: 100,
      allowMultiple: true,
      readSequential: true,
      lockParentWindow: true,
    );
    if (result == null) {
      return null;
    }

    await EasyLoading.show(status: 'Loading...');

    final fileSuffixTypes = [FileMimeType.jpeg, FileMimeType.png];

    List<String> imageFiles = [];

    for (String? path in result.paths) {
      if (path != null) {
        final extension = p.extension(path).toLowerCase();
        final type = fileSuffixTypes.firstWhereOrNull((element) {
          return FileMimeType.getByName(extension) != null;
        });
        if (type != null) {
          final fileMimeType = await FileMimeTypeCheckUtil.checkMimeType(
            filePath: path,
          );
          if (fileMimeType != null) {
            imageFiles.add(path);
          }
        }
      }
    }

    EasyLoading.dismiss();

    if (imageFiles.isEmpty) {
      return null;
    }

    final picturesPath = await _getPicturesPath();
    if (picturesPath != null) {
      for (String? path in result.paths) {
        if (path != null) {
          String basename = p.basename(path);
          String fPath = p.join(picturesPath, basename);
          File file = File(fPath);
          bool exists = await file.exists();
          if (exists) {
            await file.delete();
          }
        }
      }
    }

    return imageFiles;
  } catch (e) {
    EasyLoading.dismiss();
    rethrow;
  }
}

Future<String?> _getPicturesPath() async {
  String? path;

  final LocalStorage localStorage = LocalStorage();

  if (Platform.isAndroid) {
    String? getParentPath(String fullPath) {
      int index = fullPath.indexOf('Android');
      if (index == -1) {
        return null;
      }
      return fullPath.substring(0, index - 1);
    }

    String? storagePrefix;

    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      storagePrefix = getParentPath(directory.path);
    }

    if (storagePrefix != null) {
      String picturesPath = p.join(storagePrefix, 'Pictures');
      bool exists = await Directory(picturesPath).exists();
      if (exists) {
        path = picturesPath;
      }
    } else {
      String? safPath = localStorage.getSafDirectory();

      if (safPath != null) {
        bool exists = await Directory(safPath).exists();
        if (exists) {
          path = safPath;
        }
      }
    }
  }

  return path;
}
