import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recognition_example/pages/camera_view.dart';

class DetectFacePageController extends GetxController {
  Future processImage(CameraResult cameraResult) async {}
}

class DetectFacePage extends StatelessWidget {
  const DetectFacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetectFacePageController>(
      init: DetectFacePageController(),
      builder: (c) => Scaffold(
        appBar: AppBar(title: const Text('Detect Face')),
        body: CameraView(c.processImage),
      ),
    );
  }
}
