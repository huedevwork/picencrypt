import 'package:get/get.dart';
import 'package:picencrypt/pages/home/home.binding.dart';
import 'package:picencrypt/pages/home/home_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.Home;

  static final routes = [
    GetPage(
      name: AppRoutes.Home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
