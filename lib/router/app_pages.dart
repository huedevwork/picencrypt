import 'package:get/get.dart';
import 'package:picencrypt/pages/examine_image_page/binding.dart';
import 'package:picencrypt/pages/examine_image_page/view.dart';
import 'package:picencrypt/pages/home_page/binding.dart';
import 'package:picencrypt/pages/home_page/view.dart';
import 'package:picencrypt/pages/processing_images_page/binding.dart';
import 'package:picencrypt/pages/processing_images_page/view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.processingImages,
      page: () => const ProcessingImagesPage(),
      binding: ProcessingImagesBinding(),
    ),
    GetPage(
      name: AppRoutes.photoView,
      page: () => const ExamineImagePage(),
      binding: ExamineImageBinding(),
    ),
  ];
}
