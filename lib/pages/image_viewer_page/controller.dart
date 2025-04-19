import 'dart:typed_data';

import 'package:get/get.dart';

class ImageViewerController extends GetxController {
  late List<Uint8List> imageBytes;

  @override
  void onInit() {
    imageBytes = Get.arguments;
    super.onInit();
  }

  @override
  void onReady() {}

  @override
  void onClose() {}
}
