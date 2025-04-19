import 'package:get/get.dart';

import 'controller.dart';

class ImageViewerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageViewerController>(() => ImageViewerController());
  }
}
