import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picencrypt/service/application_service/permission_service.dart';

class LoggerUtils {
  static final LoggerUtils _instance = LoggerUtils._internal();

  factory LoggerUtils() {
    return _instance;
  }

  LoggerUtils._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  late Logger _logger;

  final _logPathName = 'PicEncrypt Log';

  // 记录详细级别的日志
  void t(dynamic message) {
    _logger.t(message);
  }

  // 记录调试级别的日志
  void d(dynamic message) {
    _logger.d(message);
  }

  // 记录信息级别的日志
  void i(dynamic message) {
    _logger.i(message);
  }

  // 记录警告级别的日志
  void w(dynamic message) {
    _logger.w(message);
  }

  // 记录错误级别的日志并存储到本地
  void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _saveErrorLogToFile(message, error, stackTrace);
  }

  // 记录严重错误级别的日志并存储到本地
  void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _saveErrorLogToFile(message, error, stackTrace);
  }

  String? _getParentPath(String fullPath) {
    int index = fullPath.indexOf('Android');
    if (index == -1) {
      return null;
    }
    return fullPath.substring(0, index - 1);
  }

  Future<Directory> _getLogDirectory() async {
    if (Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isIOS) {
      return await getApplicationSupportDirectory();
    } else if (Platform.isAndroid) {
      return await getApplicationDocumentsDirectory();
    }
    throw UnsupportedError('不支持的操作系统');
  }

  Future<void> _saveErrorLogToFile(
    dynamic message,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      final directory = await _getLogDirectory();
      Directory logDir = Directory(p.join(directory.path, _logPathName));

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      debugPrint('path: ${logDir.path}');

      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final logFile = File(p.join(logDir.path, '$date.txt'));

      if (!await logFile.exists()) {
        await logFile.create(recursive: true);
      }

      final logContent = '${DateTime.now()}: '
          '$message\n'
          'Error: $error\n'
          'StackTrace: $stackTrace'
          '\n\n';
      await logFile.writeAsString(logContent, mode: FileMode.append);
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('保存日志文件时出错: $e');
        debugPrintStack(stackTrace: s);
      }
    }
  }

  Future<Directory?> _getSaveLogDirectory() async {
    if (!Platform.isAndroid) {
      return null;
    }

    Permission permission = Permission.manageExternalStorage;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      permission = Permission.storage;
    }

    bool results = await PermissionService.requestPermission(
      context: Get.context!,
      permission: permission,
    );
    if (!results) {
      return null;
    }

    String? storagePrefix;

    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      storagePrefix = _getParentPath(directory.path);
    }

    if (storagePrefix == null) {
      return null;
    }

    String logPath = p.join(storagePrefix, 'Download', _logPathName);
    Directory logDir = Directory(logPath);
    bool exists = await logDir.exists();
    if (!exists) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

  Future<String?> exportLogs() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      Directory logDir = Directory(p.join(directory.path, _logPathName));

      /// 未找到log存放目录
      if (!await logDir.exists()) {
        return null;
      }

      Directory? dLogDir = await _getSaveLogDirectory();
      if (dLogDir == null) {
        return null;
      }

      final logFiles = logDir.listSync();
      for (var file in logFiles) {
        if (file is File) {
          String exportPath = p.join(dLogDir.path, p.basename(file.path));
          await file.copy(exportPath);
          debugPrint('文件 ${file.path} 已导出到 $exportPath');
        }
      }

      return dLogDir.path;
    } catch (e) {
      w('导出日志失败');
      return null;
    }
  }
}
