import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recognition_example/pages/camera_view.dart';

class RegisterFaceController extends GetxController {
  // region process image
  List<double> _meanFeature = [];
  int startCompareFeature = 0;
  bool backInProcess = false;
  Future processImage(CameraResult cameraResult) async {
    if (_meanFeature.isEmpty) {
      await scheduleCalculateRecord(cameraResult.feature);
      startCompareFeature = DateTime.now().millisecondsSinceEpoch;
    } else {
      // isBelowThreshold == isFaceSame
      final isBelowThreshold = await compareMeanRecord(cameraResult.feature);

      // if 3 second pass and under treshold, close cam
      int endCompareFeature = DateTime.now().millisecondsSinceEpoch;
      if (isBelowThreshold && endCompareFeature - startCompareFeature > 3000) {
        if (backInProcess) return;
        backInProcess = true;
        Get.back(result: CameraResult(cameraResult.image, _meanFeature));
      } else if (!isBelowThreshold) {
        _meanFeature = [];
      }
    }
  }

  final List<List<double>> _features = List.empty(growable: true);
  int startAddFeature = 0;
  Future scheduleCalculateRecord(List<double> feature) async {
    if (_features.isEmpty) {
      startAddFeature = DateTime.now().millisecondsSinceEpoch;
    }
    _features.add(feature);
    int endAddFeature = DateTime.now().millisecondsSinceEpoch;

    // only calculate mean if has pass 1.5s
    if (endAddFeature - startAddFeature < 1500) return;
    _meanFeature = await calculateMean(_features);
    _features.clear(); // reset holder
  }

  Future<List<double>> calculateMean(List<List<double>> features) async {
    final firstItem = features.first;
    final List<double> meanFeature = List.filled(firstItem.length, 0);

    for (int j = 0; j < firstItem.length; j++) {
      double sumItem = 0;
      for (int i = 0; i < features.length; i++) {
        final feature = features[i];
        sumItem += feature[j];
      }

      meanFeature[j] = sumItem / features.length;
    }

    return meanFeature;
  }

  Future<bool> compareMeanRecord(List<double> feature) async {
    double sumItem = 0;
    for (int i = 0; i < _meanFeature.length; i++) {
      final diff = _meanFeature[i] - feature[i];
      sumItem += diff * diff;
    }
    final distance = sqrt(sumItem);
    return distance < 0.1;
  }
  // endregion
}

class RegisterFacePage extends StatelessWidget {
  const RegisterFacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterFaceController>(
      init: RegisterFaceController(),
      builder: (c) => Scaffold(
        appBar: AppBar(title: const Text('Register Face')),
        body: CameraView(c.processImage),
      ),
    );
  }
}
