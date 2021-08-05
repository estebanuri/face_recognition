import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recognition_example/router/router_name.dart';

class RootPageController extends GetxController {
  void goToRegisterPage() {
    Get.toNamed(RouteName.register_face);
  }

  void goToDetectPage() {
    Get.toNamed(RouteName.detect_face);
  }
}

class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RootPageController>(
      init: RootPageController(),
      builder: (ctlr) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recognition Example'),
          ),
          body: createBody(ctlr),
        );
      },
    );
  }

  ListView createBody(RootPageController ctlr) {
    return ListView(
      padding: const EdgeInsets.all(21),
      children: [
        const Text('No Face Registered'),
        Container(height: 21),
        ElevatedButton(
          child: const Text('Register Face'),
          onPressed: () => ctlr.goToRegisterPage(),
        ),
        ElevatedButton(
          child: const Text('Detect Face'),
          onPressed: () => ctlr.goToDetectPage(),
        ),
      ],
    );
  }
}
