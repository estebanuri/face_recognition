import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:recognition_example/core/mlkit/face_detector_painter.dart';
import 'package:recognition_example/core/mlkit/ml_input.dart';
import 'package:recognition_example/core/mlkit/tensor_process.dart';
import 'package:recognition_example/core/view_utils.dart';
import 'package:recognition_example/core/mlkit/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imgLib;

class CameraResult {
  final imgLib.Image image;
  final List<double> feature;

  CameraResult(this.image, this.feature);
}

typedef CameraResultCallback = Future Function(CameraResult result);

class CameraViewController extends GetxController {
  final CameraResultCallback _onImageScanned;

  // camera controllers
  CameraController? camController;
  CustomPaint? customPaint;
  CameraLensDirection _sensor = CameraLensDirection.front;

  // Machine Learning
  TensorProcess? _tensorProcess;
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();

  CameraViewController(this._onImageScanned);

  @override
  void onReady() {
    super.onReady();
    _loadModel();
    _startLiveFeed();
  }

  Future _loadModel() async {
    try {
      final interpreter = await Interpreter.fromAsset(
        'mobile_face_net.tflite',
        options: InterpreterOptions()..threads = 3,
      );

      _tensorProcess = TensorProcess(interpreter);
    } catch (e) {
      print('Failed to load model. $e');
    }
  }

  Future _startLiveFeed() async {
    final cam = await _pickCamera();
    final controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    controller.startImageStream(_processCameraImage);

    camController = controller;
    update();
  }

  @override
  void onClose() {
    destroy();
    super.onClose();
  }

  void destroy() async {
    await _stopLiveFeed();
    await _faceDetector.close();
    _tensorProcess?.close();
  }

  Future _stopLiveFeed() async {
    await camController?.stopImageStream();
    await camController?.dispose();
    camController = null;
  }

  Future<CameraDescription> _pickCamera() async {
    final cameras = await availableCameras();
    final selected = cameras.firstWhere(
      (cam) => cam.lensDirection == _sensor,
      orElse: () => cameras[0], // impossible phone has no cam
    );
    return selected;
  }

  void switchCam() async {
    if (_sensor == CameraLensDirection.back) {
      _sensor = CameraLensDirection.front;
    } else {
      _sensor = CameraLensDirection.back;
    }
    await _stopLiveFeed();
    await _startLiveFeed();
  }

  // region process image
  bool isBusyDetectFace = false;
  Future _processCameraImage(CameraImage image) async {
    if (isBusyDetectFace) return;
    isBusyDetectFace = true;

    final camera = await _pickCamera();
    final mlInput = MlInput(image, camera.sensorOrientation);
    final inputImage = await ImageUtils.convertToMlInputImage(mlInput);

    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
      customPaint = CustomPaint(painter: painter, size: Get.size);
    } else {
      customPaint = null;
    }
    isBusyDetectFace = false;
    update();

    if (faces.isNotEmpty) {
      checkFace(mlInput, faces[0]);
    }
  }

  bool isBusyRecognizeFace = false;
  void checkFace(MlInput mlInput, Face face) async {
    final processor = _tensorProcess;
    if (isBusyRecognizeFace || processor == null) return;
    isBusyRecognizeFace = true;

    // pre-process
    final pngImage = await ImageUtils.convertToImageLib(mlInput);
    if (pngImage == null) return;

    final croppedFace = imgLib.copyCrop(
      pngImage,
      face.boundingBox.topLeft.dx.toInt(),
      face.boundingBox.topLeft.dy.toInt(),
      face.boundingBox.width.toInt(),
      face.boundingBox.height.toInt(),
    );

    // process
    final feature = await processor.recognizeImage(croppedFace, face);

    // post result
    await _onImageScanned(CameraResult(croppedFace, feature));

    isBusyRecognizeFace = false;
  }

  // endregion
}

class CameraView extends StatelessWidget {
  final CameraResultCallback _onImageScanned;

  const CameraView(
    this._onImageScanned, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraViewController>(
      init: CameraViewController(_onImageScanned),
      builder: (c) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: getBody(c, Theme.of(context).canvasColor),
      ),
    );
  }

  Widget getBody(CameraViewController ctlr, Color color) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: getCamSurface(ctlr),
            ),
          ),
          12.vSpace,
          const Text(
            'Lihat Ke Arah Kamera',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          8.vSpace,
          const Text(
            'Tahan pose anda sekitar 5 detik',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          12.vSpace,
          _floatingActionButton(ctlr),
          12.vSpace,
        ],
      ),
    );
  }

  Widget _floatingActionButton(CameraViewController ctlr) {
    return FloatingActionButton(
      child: const Icon(
        Icons.cameraswitch_rounded,
        color: Colors.white,
      ),
      elevation: 0,
      highlightElevation: 0,
      onPressed: ctlr.switchCam,
    );
  }

  Widget getCamSurface(CameraViewController ctlr) {
    final camController = ctlr.camController;
    if (camController == null || camController.value.isInitialized == false) {
      return Container();
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CameraPreview(camController),
        if (ctlr.customPaint != null) ctlr.customPaint!,
      ],
    );
  }
}
