import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as imgLib;

class TensorProcess {
  final Interpreter interpreter;
  final _outputBuffer = List<List<double>>.filled(
    1,
    List<double>.filled(192, 0),
  );

  TensorProcess(this.interpreter);

  void close() {
    interpreter.close();
  }

  Future<List<double>> recognizeImage(imgLib.Image pngImage, Face face) async {
    // inputImage
    final inputShape = interpreter.getInputTensor(0).shape;
    final input = _TensorInput(pngImage, face, inputShape);

    // process
    TensorImage inputImage = _preProcess(input);

    List<Object> inputs = [inputImage.buffer];
    var outputs = {0: _outputBuffer};

    // inference
    interpreter.runForMultipleInputs(inputs, outputs);

    return _outputBuffer.first;
  }

  TensorImage _preProcess(_TensorInput input) {
    TensorImage tensorImage = TensorImage(TfLiteType.float32)
      ..loadImage(input.oriImage);

    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(input.inputShape[2], input.inputShape[2]))
        .add(ResizeOp(
          input.inputShape[1],
          input.inputShape[2],
          ResizeMethod.NEAREST_NEIGHBOUR,
        ))
        .build()
        .process(tensorImage);
  }
}

class _TensorInput {
  final imgLib.Image oriImage;
  final Face face;
  final List<int> inputShape;

  _TensorInput(this.oriImage, this.face, this.inputShape);
}
