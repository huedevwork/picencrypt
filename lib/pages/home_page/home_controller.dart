// import 'dart:html' as html;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picencrypt/common/local_storage.dart';
import 'package:picencrypt/router/app_pages.dart';
import 'package:picencrypt/service/permission_service.dart';
import 'package:picencrypt/service/single_file_services.dart';
import 'package:picencrypt/utils/cache_manager_util.dart';
import 'package:picencrypt/utils/file_type_check_util.dart';
import 'package:picencrypt/utils/pic_encrypt_util.dart';
import 'package:picencrypt/widgets/process_selection_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service/folder_services.dart';
import '../../service/multiple_file_services.dart';
import 'bean/encrypt_type.dart';
import 'bean/input_format_bean.dart';

class HomeController extends GetxController {
  final LocalStorage _localStorage = LocalStorage();

  // 禁止输入空格
  final _disableSpaceFormat = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  // 允许数字和小数点
  final _floatFormat = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  // 最大长度限制 - 字符
  final _lengthAnyStrFormat = LengthLimitingTextInputFormatter(30);

  // 最大长度限制 - 浮点
  final _lengthFloatRangeFormat = LengthLimitingTextInputFormatter(8);

  RxString _anyStrKey = RxString('0.666');
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
  Rx<FocusNode> focusNode = Rx<FocusNode>(FocusNode());
  Rx<TextEditingController> textController = Rx<TextEditingController>(
    TextEditingController(text: '0.666'),
  );

  RxBool isPicking = false.obs;

  Rx<PackageInfo?> packageInfo = Rx<PackageInfo?>(null);

  @override
  void onInit() {
    super.onInit();
    _getVersionInfo();
  }

  Future<void> _getVersionInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    packageInfo.value = info;
  }

  @override
  void onReady() {}

  @override
  void onClose() {
    _image.close();
    uiImage.close();
    focusNode.close();
    textController.close();
  }

  void _onCustomSnackBar({
    required Widget content,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      content: content,
      duration: duration,
    ));
  }

  Future<String?> _getSAFPath() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  Future<Directory> _checkDirectoryExists(String dirPath) async {
    String tempPath = p.join(dirPath, 'PicEncrypt');
    final tempDirectory = Directory(tempPath);
    // 检查目录是否存在
    bool exists = await tempDirectory.exists();
    if (exists) {
      return tempDirectory;
    } else {
      // 创建目录
      Directory directory = await tempDirectory.create(recursive: true);
      return directory;
    }
  }

  void onJumpGithub() {
    Uri uri = Uri.parse('https://github.com/huedevwork/picencrypt');
    launchUrl(uri);
  }

  Future<void> onSetSAFDirectory() async {
    if (Platform.isAndroid) {
      bool? result = await showDialog<bool>(
        context: Get.context!,
        builder: (_) {
          return AlertDialog(
            title: Text('设置SAF目录'),
            content: Text('请选一个目录来保存您的文件。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(_).pop(false);
                },
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(_).pop(true);
                },
                child: Text('继续'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        String? result = await _getSAFPath();
        if (result == null) {
          return;
        }

        await _localStorage.setSafDirectory(result);
      }
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
    if (Platform.isAndroid || Platform.isIOS) {
      Permission permission;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          permission = Permission.storage;
        } else {
          permission = Permission.manageExternalStorage;
        }
      } else {
        permission = Permission.storage;
      }

      bool results = await PermissionService.requestPermission(
        context: Get.context!,
        permission: permission,
      );
      if (!results) {
        return;
      }
    }

    DateFormat dateFormat = DateFormat('yyyyMMdd_HHmmss_SSS');
    String formattedDate = dateFormat.format(DateTime.now());
    String fileName = 'PicEncrypt_$formattedDate.jpg';

    String? imagePath;

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
        Directory dirPicEncrypt = await _checkDirectoryExists(picturesPath);
        imagePath = p.join(dirPicEncrypt.path, fileName);
      } else {
        String? safPath = _localStorage.getSafDirectory();

        if (safPath != null) {
          bool exists = await Directory(safPath).exists();
          if (exists) {
            imagePath = p.join(safPath, fileName);
          } else {
            await _localStorage.box.remove(StoreKeys.safDirectory.name);

            String? result = await _getSAFPath();
            if (result == null) {
              _onCustomSnackBar(content: const Text('已取消保存路径选择'));
              return;
            }

            await _localStorage.setSafDirectory(result);

            imagePath = p.join(safPath, fileName);
          }
        } else {
          String? result = await _getSAFPath();
          if (result == null) {
            _onCustomSnackBar(content: const Text('已取消保存路径选择'));
            return;
          }

          await _localStorage.setSafDirectory(result);

          imagePath = p.join(result, fileName);
        }
      }
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

      EasyLoading.dismiss();

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
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('保存文件失败'));

      debugPrint('error: ${e.toString()}');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> onSelectImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      Permission permission;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          permission = Permission.storage;
        } else {
          permission = Permission.photos;
        }
      } else {
        permission = Permission.photos;
      }

      bool results = await PermissionService.requestPermission(
        context: Get.context!,
        permission: permission,
      );
      if (!results) {
        return;
      }
    }

    isPicking.value = true;

    final type = await showModalBottomSheet<ProcessSelectionType>(
      context: Get.context!,
      builder: (_) => const ProcessSelectionDialog(),
    );

    isPicking.value = false;

    if (type == null) {
      return;
    }

    if (type == ProcessSelectionType.single) {
      try {
        String? path;
        if (Platform.isAndroid || Platform.isIOS) {
          path = await singleFileServices();
        } else {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowCompression: false,
            compressionQuality: 100,
            allowMultiple: false,
            readSequential: true,
          );

          path = result?.files.single.path;
        }
        print('tag - path: $path');
        if (path == null) {
          _onCustomSnackBar(content: const Text('已取消文件选择'));
          return;
        }

        await EasyLoading.show(status: 'Loading...');

        bool isGif = await FileTypeCheckUtil.checkFileIdentifier(
          filePath: path,
          fileSuffixType: FileSuffixType.gif,
        );
        if (isGif) {
          EasyLoading.dismiss();

          _onCustomSnackBar(content: const Text('GIF类型文件暂不支持'));
          return;
        }

        Uint8List bytes = await File(path).readAsBytes();

        if (Platform.isAndroid || Platform.isIOS) {
          CacheManagerUtil.clearCache();
        }

        img.Image? decodedImage = img.decodeImage(bytes);
        if (decodedImage == null) {
          EasyLoading.dismiss();

          _onCustomSnackBar(content: const Text('数据解码失败'));
          return;
        }

        const int maxImageSize = 4294967296;
        if (decodedImage.width * decodedImage.height > maxImageSize) {
          EasyLoading.dismiss();

          _onCustomSnackBar(content: const Text('图片尺寸过大'));

          return;
        }

        _image.value = img.Image.from(decodedImage);
        uiImage.value = img.Image.from(decodedImage);

        EasyLoading.dismiss();
      } catch (e, s) {
        isPicking.value = false;

        _onCustomSnackBar(content: const Text('导入图片解码失败'));

        debugPrint('error: ${e.toString()}');
        debugPrintStack(stackTrace: s);
      }
    } else {
      List<String>? imagePaths;
      if (type == ProcessSelectionType.multiple) {
        imagePaths = await multipleFileServices();
      } else if (type == ProcessSelectionType.folder) {
        imagePaths = await folderServices();
      }
      if (imagePaths == null) {
        return;
      }

      Get.toNamed(
        AppRoutes.processingImages,
        arguments: imagePaths,
      );
    }
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
    if (_image.value == null) {
      return;
    }

    await EasyLoading.show(status: 'Loading...');

    uiImage.value = img.Image.from(_image.value!);

    EasyLoading.dismiss();
  }

  /// 混淆
  void onEncrypt() {
    if (_image.value == null) {
      return;
    }

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
      case EncryptType.gilbert2dConfusion:
        _hilbertCurveConfusionEncode();
    }
  }

  /// 解混淆
  void onDecrypt() {
    if (_image.value == null) {
      return;
    }

    switch (encryptType.value) {
      case EncryptType.blockPixelConfusion:
        _blockPixelConfusionDecode(_anyStrKey.value);
        break;
      case EncryptType.rowPixelConfusion:
        _rowPixelConfusionDecode(_anyStrKey.value);
        break;
      case EncryptType.pixelConfusion:
        _pixelConfusionDecode(_anyStrKey.value);
        break;
      case EncryptType.picEncryptRowConfusion:
        _picEncryptRowConfusionDecode(_floatRangeKey.value);
        break;
      case EncryptType.picEncryptRowColConfusion:
        _picEncryptRowColConfusionDecode(_floatRangeKey.value);
        break;
      case EncryptType.gilbert2dConfusion:
        _hilbertCurveConfusionDecode();
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
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 方块混淆 解密
  Future<void> _blockPixelConfusionDecode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodeBlockPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 行像素混淆 加密
  Future<void> _rowPixelConfusionEncode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodeRowPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 方行像素混淆 解密
  Future<void> _rowPixelConfusionDecode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodeRowPixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 像素混淆 加密
  Future<void> _pixelConfusionEncode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodePixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 像素混淆 解密
  Future<void> _pixelConfusionDecode(String key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodePixelConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行模式 加密
  Future<void> _picEncryptRowConfusionEncode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodePicEncryptRowConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行模式 解密
  Future<void> _picEncryptRowConfusionDecode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodePicEncryptRowConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行+列模式 加密
  Future<void> _picEncryptRowColConfusionEncode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.encodePicEncryptRowColConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 兼容PicEncrypt：行+列模式 解密
  Future<void> _picEncryptRowColConfusionDecode(double key) async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.decodePicEncryptRowColConfusion(
      image: uiImage.value!,
      key: key,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 空间填充曲线混淆 加密
  Future<void> _hilbertCurveConfusionEncode() async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.gilbert2dTransformImage(
      image: uiImage.value!,
      isEncrypt: true,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('加密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }

  /// 空间填充曲线混淆 解密
  Future<void> _hilbertCurveConfusionDecode() async {
    await EasyLoading.show(status: 'Loading...');

    img.Image? newImage = await PicEncryptUtil.gilbert2dTransformImage(
      image: uiImage.value!,
      isEncrypt: false,
    );

    if (newImage == null) {
      EasyLoading.dismiss();

      _onCustomSnackBar(content: const Text('解密失败'));
      return;
    }

    uiImage.value = newImage;

    EasyLoading.dismiss();
  }
}
