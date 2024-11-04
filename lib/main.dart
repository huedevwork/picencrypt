import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

Future<void> main() async {
  await GetStorage.init();

  if (Platform.isAndroid || Platform.isIOS) {
    // 限制竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(400, 800),
      minimumSize: Size(400, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'PicEncrypt',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // 显示窗口
      await windowManager.show();
      // 聚焦窗口
      await windowManager.focus();
      // // 设置窗口缩放
      // await windowManager.setResizable(false);
      // // 设置窗口缩放宽高比
      // await windowManager.setAspectRatio(1.3);
      // // 设置窗口是否支持阴影
      // await windowManager.setHasShadow(true);
    });
  }

  EasyLoading.instance
    ..dismissOnTap = false
    ..maskType = EasyLoadingMaskType.black;

  runApp(const App());
}
