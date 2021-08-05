import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recognition_example/pages/camera_view.dart';
import 'package:recognition_example/pages/root_page.dart';

class DetectFaceController extends GetxController {
  final RootPageController _rootPageController = Get.find<RootPageController>();
  String name = 'Unknown';

  // region process image
  int lastTimeFaceIsDifferent = DateTime.now().millisecondsSinceEpoch;
  int lastTimeFaceIsSame = DateTime.now().millisecondsSinceEpoch;
  bool backInProcess = false;
  Future processImage(CameraResult cameraResult) async {
    final isBelowThreshold = await compareMeanRecord(cameraResult.feature);
    if (isBelowThreshold) {
      if (name != _rootPageController.name) {
        name = _rootPageController.name;
        update();
      }
    } else {
      if (name != 'Unknown') {
        name = 'Unknown';
        update();
      }
    }
  }

  Future<bool> compareMeanRecord(List<double> feature) async {
    final cameraResult = _rootPageController.cameraResult;
    if (cameraResult == null) return false;

    double sumItem = 0;
    for (int i = 0; i < cameraResult.feature.length; i++) {
      final diff = cameraResult.feature[i] - feature[i];
      sumItem += diff * diff;
    }
    final distance = sqrt(sumItem);
    return distance < 0.13;
  }
  // endregion
}

class DetectFacePage extends StatelessWidget {
  const DetectFacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetectFaceController>(
      init: DetectFaceController(),
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('Face: ${c.name}')),
        body: CameraView(c.processImage),
      ),
    );
  }
}
