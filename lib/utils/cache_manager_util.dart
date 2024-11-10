import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheManagerUtil {
  static Future<void> clearCache() async {
    try {
      Directory cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await _delete(cacheDir);
      }
    } catch (e, s) {
      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
    }
  }

  static Future<void> _delete(Directory directory) async {
    try {
      if (await directory.exists()) {
        final List<FileSystemEntity> children = directory.listSync();

        for (final FileSystemEntity child in children) {
          if (child is File) {
            await child.delete();
          } else if (child is Directory) {
            await _delete(child);

            await child.delete();
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
