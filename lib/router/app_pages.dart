import 'package:get/get.dart';
import 'package:picencrypt/pages/home/home.binding.dart';
import 'package:picencrypt/pages/home/home_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
