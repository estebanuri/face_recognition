import 'package:camera/camera.dart';

class MlInput {
  final CameraImage image;
  final int sensorOrientation;

  MlInput(this.image, this.sensorOrientation);
}
