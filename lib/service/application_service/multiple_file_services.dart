import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picencrypt/common/local_storage.dart';

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

    List<String> imageFiles = [];

    for (String? str in result.paths) {
      if (str != null) {
        imageFiles.add(str);
      }
    }

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
