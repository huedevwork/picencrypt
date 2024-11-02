// import 'dart:html' as html;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picencrypt/utils/pic_encrypt_util.dart';

import 'bean/encrypt_type.dart';
import 'bean/input_format_bean.dart';

class HomeController extends GetxController {
  // 禁止输入空格
  final _disableSpaceFormat = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  // 允许数字和小数点
  final _floatFormat = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  // 最大长度限制 - 字符
  final _lengthAnyStrFormat = LengthLimitingTextInputFormatter(30);

  // 最大长度限制 - 浮点
  final _lengthFloatRangeFormat = LengthLimitingTextInputFormatter(8);

  RxString _anyStrKey = RxString('');
  RxDouble _floatRangeKey = RxDouble(0.666);

  late Rx<InputFormatBean> inputFormatBean = Rx<InputFormatBean>(
    InputFormatBean(
      formats: [_disableSpaceFormat, _lengthAnyStrFormat],
      keyboardType: TextInputType.text,
      labelText: '可为任意字符串(Any String)',
    ),
  );

  Rx<img.Image?> _image = Rx<img.Image?>(null);
  Rx<img.Image?> uiImage = Rx<img.Image?>(null);
  Rx<EncryptType> encryptType = Rx<EncryptType>(
    EncryptType.blockPixelConfusion,
  );
  Rx<TextEditingController> textController = Rx<TextEditingController>(
    TextEditingController(),
  );

  RxBool isPicking = false.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  // }
  //
  // @override
  // void onReady() {}
  //
  // @override
  // void onClose() {}

  void _onCustomSnackBar({
    required Widget content,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      content: content,
      duration: duration,
    ));
  }

  Future<Directory> _checkDirectoryExists(String dirPath) async {
    String tempPath = p.join(dirPath, 'Pictures', 'PicEncrypt');
    final directoryPath = Directory(tempPath);
    // 检查目录是否存在
    bool exists = await directoryPath.exists();
    if (exists) {
      return directoryPath;
    } else {
      // 创建目录
      return await directoryPath.create(recursive: true);
    }
  }

  /// 检查输入密钥条件
  void onValidateInput(String value) {
    bool value1 = encryptType.value == EncryptType.picEncryptRowConfusion;
    bool value2 = encryptType.value == EncryptType.picEncryptRowColConfusion;
    if (value1 || value2) {
      if (value.isEmpty) {
        _floatRangeKey.value = 0.666;

        textController.value.text = '0.666';
      } else {
        double? temp = double.tryParse(value);
        if (temp == null) {
          _floatRangeKey.value = 0.666;

          textController.value.text = '0.666';
        } else {
          _floatRangeKey.value = temp;
        }
      }
    } else {
      _anyStrKey.value = value;
    }
  }

  Future<void> onSaveImage() async {
    DateFormat dateFormat = DateFormat('yyyyMMdd_HHmmss_SSS');
    String formattedDate = dateFormat.format(DateTime.now());
    String fileName = 'PicEncrypt_$formattedDate.jpg';

    // if (kIsWeb || kIsWasm) {
    //   try {
    //     // 处理 Web 文件保存
    //     Uint8List imageData = img.encodeJpg(uiImage.value!);
    //     final blob = html.Blob([imageData]);
    //     final url = html.Url.createObjectUrlFromBlob(blob);
    //
    //     html.AnchorElement(href: url)
    //       ..setAttribute('download', fileName)
    //       ..click();
    //
    //     html.Url.revokeObjectUrl(url);
    //   } catch (e, s) {
    //     html.window.alert('保存文件失败');
    //     debugPrint('error: ${e.toString()}');
    //     debugPrintStack(stackTrace: s);
    //   }
    //   return;
    // }

    String? imagePath;

    if (Platform.isAndroid) {
      Directory? directory = await getExternalStorageDirectory();
      Directory dirPicEncrypt = await _checkDirectoryExists(directory!.path);
      imagePath = p.join(dirPicEncrypt.path, fileName);
    } else if (Platform.isIOS) {
      Directory directory = await getApplicationDocumentsDirectory();
      Directory dirPicEncrypt = await _checkDirectoryExists(directory.path);
      imagePath = p.join(dirPicEncrypt.path, fileName);
    } else {
      String? savePath = await FilePicker.platform.getDirectoryPath();
      if (savePath != null) {
        imagePath = p.join(savePath, fileName);
      }
    }

    if (imagePath == null) {
      _onCustomSnackBar(content: const Text('取消保存'));
      return;
    }

    await EasyLoading.show(status: 'Loading...');

    try {
      await File(imagePath).writeAsBytes(img.encodeJpg(uiImage.value!));

      await EasyLoading.dismiss();

      Widget dialog = AlertDialog(
        title: const Text('保存路径'),
        content: Text(imagePath),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(true),
            child: const Text('复制到剪贴板'),
          ),
        ],
      );
      if (Platform.isIOS) {
        dialog = CupertinoAlertDialog(
          title: const Text('保存路径'),
          content: Text(imagePath),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(Get.context!).pop(true),
              child: const Text('复制到剪贴板'),
            ),
          ],
        );
      }

      bool? results = await showDialog<bool>(
        context: Get.context!,
        builder: (_) => dialog,
      );

      if (results == true) {
        // 复制文件路径到剪贴板
        await Clipboard.setData(ClipboardData(text: imagePath));

        _onCustomSnackBar(content: const Text('已复制到剪贴板'));
      }
    } catch (e, s) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('保存文件失败'));

      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> onSelectImage() async {
    isPicking.value = true;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    isPicking.value = false;

    if (result == null) {
      _onCustomSnackBar(content: const Text('已取消文件选择'));
      return;
    }

    await EasyLoading.show(status: 'Loading...');

    String? path = result.files.single.path;
    if (path == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('读取数据失败'));
      return;
    }

    Uint8List bytes = await File(path).readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('数据解码失败'));
      return;
    }

    const int SIZE = 4294967296;
    if (decodedImage.width * decodedImage.height > SIZE) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('图片尺寸过大'));

      return;
    }

    _image.value = img.Image.from(decodedImage);
    uiImage.value = img.Image.from(decodedImage);

    await EasyLoading.dismiss();
  }

  void onUpdateEncryptType(EncryptType value) {
    bool value1 = EncryptType.picEncryptRowConfusion == value;
    bool value2 = EncryptType.picEncryptRowColConfusion == value;
    if (value1 || value2) {
      inputFormatBean.value = InputFormatBean(
        formats: [_disableSpaceFormat, _floatFormat, _lengthFloatRangeFormat],
        keyboardType: TextInputType.number,
        labelText: '范围 0.1 - 0.9 (Range 0.1 - 0.9)',
      );

      textController.value.text = _floatRangeKey.toString();
    } else {
      inputFormatBean.value = InputFormatBean(
        formats: [_disableSpaceFormat, _lengthAnyStrFormat],
        keyboardType: TextInputType.text,
        labelText: '可为任意字符串(Any String)',
      );

      textController.value.text = _anyStrKey.value;
    }

    encryptType.value = value;
  }

  /// 还原
  Future<void> onReset() async {
    await EasyLoading.show(status: 'Loading...');

    uiImage.value = img.Image.from(_image.value!);

    await EasyLoading.dismiss();
  }

  /// 混淆
  void onObfuscate() {
    switch (encryptType.value) {
      case EncryptType.blockPixelConfusion:
        _blockPixelConfusionEncode(_anyStrKey.value);
        break;
      case EncryptType.rowPixelConfusion:
        _rowPixelConfusionEncode(_anyStrKey.value);
        break;
      case EncryptType.pixelConfusion:
        _pixelConfusionEncode(_anyStrKey.value);
        break;
      case EncryptType.picEncryptRowConfusion:
        _picEncryptRowConfusionEncode(_floatRangeKey.value);
        break;
      case EncryptType.picEncryptRowColConfusion:
        _picEncryptRowColConfusionEncode(_floatRangeKey.value);
        break;
    }
  }

  /// 解混淆
  void onDecrypt() {
    String key = textController.value.text;

    switch (encryptType.value) {
      case EncryptType.blockPixelConfusion:
        _blockPixelConfusionDecode(key);
        break;
      case EncryptType.rowPixelConfusion:
        _rowPixelConfusionDecode(key);
        break;
      case EncryptType.pixelConfusion:
        _pixelConfusionDecode(key);
        break;
      case EncryptType.picEncryptRowConfusion:
        _picEncryptRowConfusionDecode(_floatRangeKey.value);
        break;
      case EncryptType.picEncryptRowColConfusion:
        _picEncryptRowColConfusionDecode(_floatRangeKey.value);
        break;
    }
  }

  /// 方块混淆 加密
  Future<void> _blockPixelConfusionEncode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodeBlockPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 方块混淆 解密
  Future<void> _blockPixelConfusionDecode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodeBlockPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 行像素混淆 加密
  Future<void> _rowPixelConfusionEncode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodeRowPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 方行像素混淆 解密
  Future<void> _rowPixelConfusionDecode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodeRowPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 像素混淆 加密
  Future<void> _pixelConfusionEncode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodePixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 像素混淆 解密
  Future<void> _pixelConfusionDecode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodePixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行模式 加密
  Future<void> _picEncryptRowConfusionEncode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodePicEncryptRowConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行模式 解密
  Future<void> _picEncryptRowConfusionDecode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodePicEncryptRowConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行+列模式 加密
  Future<void> _picEncryptRowColConfusionEncode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodePicEncryptRowColConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行+列模式 解密
  Future<void> _picEncryptRowColConfusionDecode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodePicEncryptRowColConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      await EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    await EasyLoading.dismiss();
  }
}
