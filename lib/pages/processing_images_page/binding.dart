import 'package:get/get.dart';

import 'controller.dart';

class ProcessingImagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessingImagesController>(() => ProcessingImagesController());
  }
}
