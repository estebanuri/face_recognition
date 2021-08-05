import 'package:get/get.dart';
import 'package:recognition_example/pages/detect_face_page.dart';
import 'package:recognition_example/pages/register_face_page.dart';
import 'package:recognition_example/pages/root_page.dart';
import 'package:recognition_example/router/router_name.dart';

class MyRouter {
  static List<GetPage> pages = [
    GetPage(
      name: RouteName.root,
      page: () => RootPage(),
    ),
    GetPage(
      name: RouteName.register_face,
      page: () => RegisterFacePage(),
    ),
    GetPage(
      name: RouteName.detect_face,
      page: () => DetectFacePage(),
    ),
  ];
}
