import 'package:get/get.dart';

import 'controller.dart';

class ExamineImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamineImageController>(() => ExamineImageController());
  }
}
