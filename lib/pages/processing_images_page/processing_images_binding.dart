import 'package:get/get.dart';

import 'processing_images_controller.dart';

class ProcessingImagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessingImagesController>(() => ProcessingImagesController());
  }
}
