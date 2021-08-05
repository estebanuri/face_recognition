import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recognition_example/core/view_utils.dart';
import 'package:recognition_example/pages/camera_view.dart';
import 'package:recognition_example/router/router_name.dart';

class RootPageController extends GetxController {
  CameraResult? _cameraResult;
  String name = 'No Face';

  Future<String> askForPersonName() async {
    String name = "";
    await Get.dialog(
      Dialog(
        child: ListView(
          padding: const EdgeInsets.all(21),
          shrinkWrap: true,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Person Name'),
              textInputAction: TextInputAction.next,
              onChanged: (t) => name = t,
            ),
            12.vSpace,
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Register Person'),
            ),
          ],
        ),
      ),
    );
    return name;
  }

  bool canScanFace() => _cameraResult != null;

  void goToRegisterPage() async {
    String name = await askForPersonName();
    if (name.isNotEmpty) {
      final camResult = await Get.toNamed(RouteName.register_face);
      handleCamResult(name, camResult);
    } else {
      Get.defaultDialog(
        title: 'Name empty',
        middleText: 'Please fill person name',
      );
    }
  }

  void handleCamResult(final String name, dynamic cameraResult) {
    if (cameraResult is! CameraResult) return;
    _cameraResult = cameraResult;
    this.name = name;
    update();

    Get.defaultDialog(
      title: 'Person Registered',
      middleText: 'You can use the "Detect Page" button',
    );
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
    final textRegister = ctlr.canScanFace() ? 'Replace' : 'Register';
    return ListView(
      padding: const EdgeInsets.all(21),
      children: [
        Text('${ctlr.name} Registered'),
        21.hSpace,
        Container(height: 21),
        ElevatedButton(
          child: Text('$textRegister Face'),
          onPressed: () => ctlr.goToRegisterPage(),
        ),
        ElevatedButton(
          child: const Text('Detect Face'),
          onPressed: ctlr.canScanFace() ? () => ctlr.goToDetectPage() : null,
        ),
      ],
    );
  }
}
