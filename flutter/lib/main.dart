import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:recognition_example/router/my_router.dart';
import 'package:recognition_example/router/router_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      enableLog: true,
      title: 'Recognition Example',
      initialBinding: MyAppBinding(),
      initialRoute: RouteName.root,
      getPages: MyRouter.pages,
      builder: EasyLoading.init(),
    );
  }
}

class MyAppBinding implements Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
  }
}
