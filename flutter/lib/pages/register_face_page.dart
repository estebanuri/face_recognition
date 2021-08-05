import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recognition_example/pages/camera_view.dart';

class RegisterFaceController extends GetxController {
  Future processImage(CameraResult cameraResult) async {}
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
