import 'package:get/get.dart';

import 'examine_image_controller.dart';

class ExamineImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamineImageController>(() => ExamineImageController());
  }
}
