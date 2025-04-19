import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picencrypt/common/local_storage.dart';
import 'package:picencrypt/pages/home_page/bean/encrypt_type.dart';
import 'package:picencrypt/pages/home_page/bean/input_format_bean.dart';
import 'package:picencrypt/router/app_pages.dart';
import 'package:picencrypt/service/application_service/open_platform_image_view.dart';
import 'package:picencrypt/service/application_service/permission_service.dart';
import 'package:picencrypt/utils/cache_manager_util.dart';
import 'package:picencrypt/utils/compute_util.dart';
import 'package:picencrypt/utils/create_file_name_util.dart';
import 'package:picencrypt/utils/logger_utils.dart';
import 'package:picencrypt/widgets/dialog_mode_select.dart';
import 'package:picencrypt/widgets/dialog_textField.dart';
import 'package:picencrypt_converter/picencrypt_converter.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'model.dart';

class ProcessingImagesController extends GetxController {
  final LoggerUtils _logger = LoggerUtils();

  final LocalStorage _localStorage = LocalStorage();

  RxBool isLoading = true.obs;
  Rx<List<EncryptImageBean>> uiImages = Rx<List<EncryptImageBean>>([]);
  final Rx<List<EncryptImageBean>> _images = Rx<List<EncryptImageBean>>([]);

  // 禁止输入空格
  final _disableSpaceFormat = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  // 允许数字和小数点
  final _floatFormat = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  RxString _anyStrKey = RxString('0.666');
  RxDouble _floatRangeKey = RxDouble(0.666);

  late Rx<InputFormatBean> inputFormatBean = Rx<InputFormatBean>(
    InputFormatBean(
      formats: [_disableSpaceFormat],
      keyboardType: TextInputType.text,
      labelText: '可为任意字符串',
    ),
  );

  Rx<EncryptType> encryptType = Rx<EncryptType>(
    EncryptType.blockPixelConfusion,
  );
  Rx<FocusNode> focusNode = Rx<FocusNode>(FocusNode());
  Rx<TextEditingController> textController = Rx<TextEditingController>(
    TextEditingController(text: '0.666'),
  );

  late Rx<ListObserverController> observerController;
  Rx<ScrollController> scrollController = Rx(ScrollController());
  RxBool showBackToTopButton = false.obs;

  RxInt total = 0.obs;
  RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    observerController = Rx(ListObserverController(
      controller: scrollController.value,
    ));

    _onInit();
    super.onInit();
  }

  @override
  void onReady() {}

  @override
  void onClose() {
    EasyLoading.dismiss();
    _images.close();
    uiImages.close();
    focusNode.close();
    textController.close();
    scrollController.close();
  }

  Future<void> _onInit() async {
    List<String> imagePaths = Get.arguments;
    total.value = imagePaths.length;

    List<Uint8List> dataList = [];
    for (String path in imagePaths) {
      Uint8List bytes = await File(path).readAsBytes();
      dataList.add(bytes);
    }

    List<(img.Image, Uint8List)> results = await ComputeUtil.handleList(
      progressCallback: (value) {
        progress.value = value;
      },
      param: dataList,
      processingFunction: (bytes) {
        img.Image decodedImage = img.decodeImage(bytes)!;
        Uint8List data = Uint8List.fromList(img.encodeJpg(decodedImage));
        return (decodedImage, data);
      },
    );

    List<EncryptImageBean> items = [];
    for (int i = 0; i < results.length; i++) {
      img.Image image = results[i].$1;
      EncryptImageBean item = EncryptImageBean(
        image: image,
        renderingData: results[i].$2,
        inputFormatBean: InputFormatBean(
          formats: [_disableSpaceFormat],
          keyboardType: TextInputType.text,
          labelText: '可为任意字符串',
        ),
      );
      items.add(item);
    }

    uiImages.value = List.from(items);
    _images.value = List.from(items);

    isLoading.value = false;

    if (Platform.isAndroid || Platform.isIOS) {
      CacheManagerUtil.clearCache();
    }
  }

  Future<void> onOpenExamineImage(int index) async {
    img.Image image = uiImages.value[index].image;

    if (Platform.isAndroid || Platform.isIOS) {
      isLoading.value = true;

      await EasyLoading.show(status: 'Loading...');

      Uint8List imageData = await ComputeUtil.handle(
        param: image,
        processingFunction: (image) => img.encodeJpg(image),
      );

      EasyLoading.dismiss();

      await Get.toNamed(AppRoutes.photoView, arguments: imageData);

      isLoading.value = false;
    } else {
      openPlatformImageService(image);
    }
  }

  void onUpdateAllEncryptType(EncryptType value) {
    bool value1 = EncryptType.picEncryptRowConfusion == value;
    bool value2 = EncryptType.picEncryptRowColConfusion == value;
    if (value1 || value2) {
      inputFormatBean.value = InputFormatBean(
        formats: [_disableSpaceFormat, _floatFormat],
        keyboardType: TextInputType.number,
        labelText: '范围 0.1 - 0.9',
      );

      textController.value.text = _floatRangeKey.toString();
    } else {
      inputFormatBean.value = InputFormatBean(
        formats: [_disableSpaceFormat],
        keyboardType: TextInputType.text,
        labelText: '可为任意字符串',
      );

      textController.value.text = _anyStrKey.value;
    }

    encryptType.value = value;

    List<EncryptImageBean> tempList = List.from(uiImages.value);
    for (int i = 0; i < tempList.length; i++) {
      tempList[i] = tempList[i].copyWith(
        inputFormatBean: inputFormatBean.value,
        encryptType: encryptType.value,
      );
    }

    uiImages.value = List.from(tempList);
  }

  /// 检查输入密钥条件
  void onAllValidateInput(String value) {
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

    List<EncryptImageBean> tempList = List.from(uiImages.value);
    for (int i = 0; i < tempList.length; i++) {
      tempList[i] = tempList[i].copyWith(
        anyStrKey: _anyStrKey.value,
        floatRangeKey: _floatRangeKey.value,
      );
    }

    uiImages.value = List.from(tempList);
  }

  Future<void> setChildEncryptTypeDialog(int index) async {
    List<EncryptImageBean> tempList = List.from(uiImages.value);

    EncryptType encryptType = tempList[index].encryptType;

    EncryptType? result = await showDialog<EncryptType>(
      context: Get.context!,
      builder: (_) {
        return DialogModeSelect(encryptType: encryptType);
      },
    );

    if (result == null) {
      return;
    }

    tempList[index] = tempList[index].copyWith(
      encryptType: result,
    );

    uiImages.value = List.from(tempList);
  }

  Future<void> setChildValidateInputDialog(int index) async {
    List<EncryptImageBean> tempList = List.from(uiImages.value);

    EncryptImageBean item = tempList[index];

    EncryptImageBean? result = await showDialog<EncryptImageBean>(
      context: Get.context!,
      builder: (_) {
        return DialogTextField(item: item);
      },
    );

    if (result == null) {
      return;
    }

    tempList[index] = result;

    uiImages.value = List.from(tempList);
  }

  void onObserve(ListViewObserveModel model) {
    // int firstIndex = model.displayingChildIndexList.first;
    // int lastIndex = model.displayingChildIndexList.last;
    // debugPrint('firstIndex: $firstIndex, lastIndex: $lastIndex');

    showBackToTopButton.value = model.displayingChildIndexList.last >= 5;
  }

  void onBackToTop() {
    scrollController.value.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  Future<void> onAllSave() async {
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

    String timeName = CreateFileNameUtil.timeName();
    String fileName = 'PicEncrypt_$timeName.jpg';

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
      final downloadsDir = await getDownloadsDirectory();

      String? savePath = await FilePicker.platform.getDirectoryPath(
        initialDirectory: downloadsDir?.path,
      );
      if (savePath != null) {
        imagePath = p.join(savePath, fileName);
      }
    }

    if (imagePath == null) {
      _onCustomSnackBar(content: const Text('取消保存'));
      return;
    }

    await EasyLoading.showProgress(0.0, status: 'Loading...');

    List<EncryptImageBean> tempImages = List.from(uiImages.value);

    List<Uint8List> dataList = await ComputeUtil.handleList(
      progressCallback: (value) {
        EasyLoading.showProgress(value, status: '${(value * 100).toInt()}%');
      },
      param: tempImages,
      processingFunction: (item) {
        return img.encodeJpg(item.image);
      },
    );

    EasyLoading.showProgress(0.0, status: 'Loading...');

    List<String> failedList = [];
    for (int i = 0; i < dataList.length; i++) {
      double value = (i + 1) / dataList.length;
      EasyLoading.showProgress(value, status: '${(value * 100).toInt()}%');

      Uint8List data = dataList[i];

      try {
        String dir = p.dirname(imagePath);
        String baseName = p.basenameWithoutExtension(imagePath);

        String newBaseName = '${baseName}_$i';
        String newImagePath = p.join(dir, '$newBaseName.jpg');

        await File(newImagePath).writeAsBytes(data);
      } catch (e) {
        failedList.add(imagePath);
        continue;
      }
    }

    EasyLoading.dismiss();

    _onCustomSnackBar(content: const Text('保存成功'));

    if (failedList.isEmpty) {
      return;
    }

    Widget content = Column(
      children: [
        const Text('下列文件保存失败:'),
        Flexible(
          child: ListView.builder(
            itemCount: failedList.length,
            itemBuilder: (BuildContext context, int index) {
              String path = failedList[index];
              return Text(path);
            },
          ),
        ),
      ],
    );
    final List<Widget> actions = [
      TextButton(
        onPressed: () => Navigator.of(Get.context!).pop(true),
        child: const Text('确定'),
      ),
    ];

    Widget dialog = AlertDialog(
      title: const Text('保存'),
      content: content,
      actions: actions,
    );
    if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(
        title: const Text('保存路径'),
        content: content,
        actions: actions,
      );
    }

    showDialog<bool>(
      context: Get.context!,
      builder: (_) => dialog,
    );
  }

  /// 还原
  Future<void> onAllReset() async {
    await EasyLoading.show(status: 'Loading...');

    for (int i = 0; i < _images.value.length; i++) {
      _images.value[i] = _images.value[i].copyWith(
        encryptType: uiImages.value[i].encryptType,
        anyStrKey: uiImages.value[i].anyStrKey,
        floatRangeKey: uiImages.value[i].floatRangeKey,
      );
    }

    uiImages.value = List.from(_images.value);

    EasyLoading.dismiss();
  }

  /// 混淆
  Future<void> onAllEncrypt() async {
    var start = DateTime.now();
    await EasyLoading.showProgress(0.0, status: 'Loading...');

    try {
      List<(EncryptType, EncryptImageBean)> tempList = uiImages.value.map((e) {
        return (encryptType.value, e);
      }).toList();

      List<EncryptImageBean> results = await ComputeUtil.handleList(
        progressCallback: (value) {
          EasyLoading.showProgress(value, status: '${(value * 100).toInt()}%');
        },
        param: tempList,
        processingFunction: (value) {
          EncryptType encryptType = value.$1;
          EncryptImageBean item = value.$2;

          img.Image originalImage = item.image;
          String anyStrKey = item.anyStrKey;
          double floatRangeKey = item.floatRangeKey;

          img.Image image;
          switch (encryptType) {
            case EncryptType.blockPixelConfusion:
              image = BlockPixelConfusionUtil.encodeImg(
                image: originalImage,
                key: anyStrKey,
              );
              break;
            case EncryptType.rowPixelConfusion:
              image = RowPixelConfusionUtil.encodeImg(
                image: originalImage,
                key: anyStrKey,
              );
              break;
            case EncryptType.pixelConfusion:
              image = PixelConfusionUtil.encodeImg(
                image: originalImage,
                key: anyStrKey,
              );
              break;
            case EncryptType.picEncryptRowConfusion:
              image = PicEncryptRowConfusionUtil.encodeImg(
                image: originalImage,
                key: floatRangeKey,
              );
              break;
            case EncryptType.picEncryptRowColConfusion:
              image = PicEncryptRowColConfusionUtil.encodeImg(
                image: originalImage,
                key: floatRangeKey,
              );
              break;
            case EncryptType.gilbert2dConfusion:
              image = Gilbert2dConfusionUtil.transformImage(
                image: originalImage,
                isEncrypt: true,
              );
              break;
          }

          var renderingData = Uint8List.fromList(img.encodeJpg(image));
          return item.copyWith(image: image, renderingData: renderingData);
        },
      );

      Duration duration = DateTime.now().difference(start);
      debugPrint('混淆: $duration');

      uiImages.value = List.from(results);

      EasyLoading.dismiss();
    } catch (e, s) {
      EasyLoading.dismiss();

      _logger.e('混淆失败', error: e, stackTrace: s);
    }
  }

  /// 解混淆
  Future<void> onAllDecrypt() async {
    var start = DateTime.now();
    await EasyLoading.showProgress(0.0, status: 'Loading...');

    try {
      List<(EncryptType, EncryptImageBean)> tempList = uiImages.value.map((e) {
        return (encryptType.value, e);
      }).toList();

      List<EncryptImageBean> results = await ComputeUtil.handleList(
        progressCallback: (value) {
          EasyLoading.showProgress(value, status: '${(value * 100).toInt()}%');
        },
        param: tempList,
        processingFunction: (value) {
          EncryptType encryptType = value.$1;
          EncryptImageBean item = value.$2;

          img.Image originalImage = item.image;
          String anyStrKey = item.anyStrKey;
          double floatRangeKey = item.floatRangeKey;

          img.Image image;
          switch (encryptType) {
            case EncryptType.blockPixelConfusion:
              image = BlockPixelConfusionUtil.decodeImg(
                image: originalImage,
                key: anyStrKey,
              );
              break;
            case EncryptType.rowPixelConfusion:
              image = RowPixelConfusionUtil.decodeImg(
                image: originalImage,
                key: anyStrKey,
              );
              break;
            case EncryptType.pixelConfusion:
              image = PixelConfusionUtil.decodeImg(
                image: originalImage,
                key: anyStrKey,
              );
              break;
            case EncryptType.picEncryptRowConfusion:
              image = PicEncryptRowConfusionUtil.decodeImg(
                image: originalImage,
                key: floatRangeKey,
              );
              break;
            case EncryptType.picEncryptRowColConfusion:
              image = PicEncryptRowColConfusionUtil.decodeImg(
                image: originalImage,
                key: floatRangeKey,
              );
              break;
            case EncryptType.gilbert2dConfusion:
              image = Gilbert2dConfusionUtil.transformImage(
                image: originalImage,
                isEncrypt: false,
              );
              break;
          }

          var renderingData = Uint8List.fromList(img.encodeJpg(image));
          return item.copyWith(image: image, renderingData: renderingData);
        },
      );

      Duration duration = DateTime.now().difference(start);
      debugPrint('解混淆: $duration');

      uiImages.value = List.from(results);

      EasyLoading.dismiss();
    } catch (e, s) {
      EasyLoading.dismiss();

      _logger.e('解码失败', error: e, stackTrace: s);
    }
  }

  Future<void> onChildSave(int index) async {
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

    String timeName = CreateFileNameUtil.timeName();
    String fileName = 'PicEncrypt_$timeName.jpg';

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
      final downloadsDir = await getDownloadsDirectory();

      String? savePath = await FilePicker.platform.getDirectoryPath(
        initialDirectory: downloadsDir?.path,
      );
      if (savePath != null) {
        imagePath = p.join(savePath, fileName);
      }
    }

    if (imagePath == null) {
      _onCustomSnackBar(content: const Text('取消保存'));
      return;
    }

    await EasyLoading.show(status: 'Loading...');

    EncryptImageBean item = uiImages.value[index];

    try {
      await File(imagePath).writeAsBytes(img.encodeJpg(item.image));

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

      _logger.e('保存失败', error: e, stackTrace: s);
    }
  }

  /// 还原
  Future<void> onChildReset(int index) async {
    List<EncryptImageBean> tempList = List.from(uiImages.value);

    tempList[index] = _images.value[index].copyWith(
      inputFormatBean: inputFormatBean.value,
      encryptType: encryptType.value,
      anyStrKey: _anyStrKey.value,
      floatRangeKey: _floatRangeKey.value,
    );

    uiImages.value = List.from(tempList);
  }

  /// 混淆
  Future<void> onChildEncrypt(int index) async {
    EncryptImageBean item = uiImages.value[index];
    img.Image originalImage = item.image;
    String anyStrKey = item.anyStrKey;
    double floatRangeKey = item.floatRangeKey;

    img.Image image;
    switch (item.encryptType) {
      case EncryptType.blockPixelConfusion:
        image = BlockPixelConfusionUtil.encodeImg(
          image: originalImage,
          key: anyStrKey,
        );
        break;
      case EncryptType.rowPixelConfusion:
        image = RowPixelConfusionUtil.encodeImg(
          image: originalImage,
          key: anyStrKey,
        );
        break;
      case EncryptType.pixelConfusion:
        image = PixelConfusionUtil.encodeImg(
          image: originalImage,
          key: anyStrKey,
        );
        break;
      case EncryptType.picEncryptRowConfusion:
        image = PicEncryptRowConfusionUtil.encodeImg(
          image: originalImage,
          key: floatRangeKey,
        );
        break;
      case EncryptType.picEncryptRowColConfusion:
        image = PicEncryptRowColConfusionUtil.encodeImg(
          image: originalImage,
          key: floatRangeKey,
        );
        break;
      case EncryptType.gilbert2dConfusion:
        image = Gilbert2dConfusionUtil.transformImage(
          image: originalImage,
          isEncrypt: true,
        );
        break;
    }

    List<EncryptImageBean> tempList = List.from(uiImages.value);

    Uint8List renderingImage = await ComputeUtil.handle(
      param: image,
      processingFunction: (data) {
        return Uint8List.fromList(img.encodeJpg(data));
      },
    );

    tempList[index] = tempList[index].copyWith(
      image: image,
      renderingData: renderingImage,
    );

    uiImages.value = List.from(tempList);
  }

  /// 解混淆
  Future<void> onChildDecrypt(int index) async {
    EncryptImageBean item = uiImages.value[index];
    img.Image originalImage = item.image;
    String anyStrKey = item.anyStrKey;
    double floatRangeKey = item.floatRangeKey;

    img.Image image;
    switch (item.encryptType) {
      case EncryptType.blockPixelConfusion:
        image = BlockPixelConfusionUtil.decodeImg(
          image: originalImage,
          key: anyStrKey,
        );
        break;
      case EncryptType.rowPixelConfusion:
        image = RowPixelConfusionUtil.decodeImg(
          image: originalImage,
          key: anyStrKey,
        );
        break;
      case EncryptType.pixelConfusion:
        image = PixelConfusionUtil.decodeImg(
          image: originalImage,
          key: anyStrKey,
        );
        break;
      case EncryptType.picEncryptRowConfusion:
        image = PicEncryptRowConfusionUtil.decodeImg(
          image: originalImage,
          key: floatRangeKey,
        );
        break;
      case EncryptType.picEncryptRowColConfusion:
        image = PicEncryptRowColConfusionUtil.decodeImg(
          image: originalImage,
          key: floatRangeKey,
        );
        break;
      case EncryptType.gilbert2dConfusion:
        image = Gilbert2dConfusionUtil.transformImage(
          image: originalImage,
          isEncrypt: false,
        );
        break;
    }

    List<EncryptImageBean> tempList = List.from(uiImages.value);

    Uint8List renderingImage = await ComputeUtil.handle(
      param: image,
      processingFunction: (data) {
        return Uint8List.fromList(img.encodeJpg(data));
      },
    );

    tempList[index] = tempList[index].copyWith(
      image: image,
      renderingData: renderingImage,
    );

    uiImages.value = List.from(tempList);
  }

  Future<String?> _getSAFPath() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  Future<Directory> _checkDirectoryExists(String dirPath) async {
    String tempPath = p.join(dirPath, 'PicEncrypt');
    final tempDirectory = Directory(tempPath);
    bool exists = await tempDirectory.exists();
    if (exists) {
      return tempDirectory;
    } else {
      Directory directory = await tempDirectory.create(recursive: true);
      return directory;
    }
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
}
