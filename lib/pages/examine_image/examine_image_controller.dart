import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class ExamineImageController extends GetxController {
  late Rx<img.Image> uiImage;

  @override
  void onInit() {
    uiImage = Rx<img.Image>(Get.arguments);
    super.onInit();
  }

  @override
  void onReady() {}

  @override
  void onClose() {
    uiImage.close();
  }
}
