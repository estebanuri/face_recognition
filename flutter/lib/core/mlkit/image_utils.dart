import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imgLib;
import 'package:recognition_example/core/mlkit/ml_input.dart';

class ImageUtils {
  static Future<InputImage> convertToMlInputImage(MlInput mlInput) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in mlInput.image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      mlInput.image.width.toDouble(),
      mlInput.image.height.toDouble(),
    );

    final imageRotation =
        InputImageRotationMethods.fromRawValue(mlInput.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(mlInput.image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = mlInput.image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      inputImageData: inputImageData,
    );
    return inputImage;
  }

  static Future<imgLib.Image?> convertToImageLib(MlInput mlInput) async {
    imgLib.Image? img;
    if (mlInput.image.format.group == ImageFormatGroup.yuv420) {
      // android
      // img = await _convertYUV420(mlInput.image, mlInput.sensorOrientation);
      img = await _convertYUV420toImageColor(
        mlInput.image,
        mlInput.sensorOrientation,
      );
    } else {
      // ios
      // if (image.format.group == ImageFormatGroup.bgra8888)
      img = await _convertBGRA8888(mlInput.image);
    }
    return img;
  }

  // CameraImage BGRA8888 -> PNG
  // Color
  static Future<imgLib.Image> _convertBGRA8888(CameraImage image) async {
    return imgLib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imgLib.Format.bgra,
    );
  }

  static Future<imgLib.Image?> _convertYUV420toImageColor(
    CameraImage image,
    int sensorOrientation,
  ) async {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    var img = imgLib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }

    return imgLib.copyRotate(img, sensorOrientation);
  }

  // CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
  // Black
  static Future<imgLib.Image> _convertYUV420(
    CameraImage image,
    int sensorOrientation,
  ) async {
    var img = imgLib.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    return imgLib.copyRotate(img, sensorOrientation);
  }
}
