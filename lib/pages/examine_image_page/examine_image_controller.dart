import 'dart:typed_data';

import 'package:get/get.dart';

class ExamineImageController extends GetxController {
  late Uint8List imageData;

  @override
  void onInit() {
    imageData = Get.arguments;
    super.onInit();
  }

  @override
  void onReady() {}

  @override
  void onClose() {}
}
