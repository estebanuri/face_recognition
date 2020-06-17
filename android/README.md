
# Real time face mask detection in Android 

[![real time face mask detection in android](http://img.youtube.com/vi/9bxqWqg1Ixo/0.jpg)](https://www.youtube.com/watch?v=9bxqWqg1Ixo "demo")

### Overview
The recent coronavirus pandemic has pushed people around the world to new challenges. In this context of uncertainty, we can all play our role by contributing to the fight against this disease. This is an excellent opportunity to put technology at the service of humanity. From my place I could try to contribute with the tools that I can work on. So here I've developed an application to detect face masks in the smartphone. This application works in real time.

### Motivation
Although it is not entirely clear how much the use of the face mask can protect us from the virus, it is chilling to see how far a simple sneeze can drop breath droplets, potentially carrying with them the virus. If the use of the face mask could reduce at least a bit the propagation I think it is worth it to enforce its use.

A solution that is within everyone's reach could help to control the use of the face mask. And today everyone has a smartphone, so perhaps a mobile application could help. This post solves this problem using an Android mobile application that recognizes face masks. I hope this small contribution is useful.


## A good face mask detector for mobile
The great Adrian Rosebrock, has recently published  [a great article](https://www.pyimagesearch.com/2020/05/04/covid-19-face-mask-detector-with-opencv-keras-tensorflow-and-deep-learning/) about how to train a deep learning model to achieve this task. In his post he used [this](https://github.com/prajnasb/observations) dataset provided by [Prajna Bhandary](https://www.linkedin.com/feed/update/urn:li:activity:6655711815361761280/), which was very cleverly generated (by artificially drawing face masks over the positions of detected face landmarks).
The approach proposed by Adrian is to utilize a two-stages detector, first a face detector is applied, to retrieve the faces positions. Then each face is cropped and prepossessed to be feed into the second model which does a binary classification detecting between **"mask"** or **"no-mask"**.

![enter image description here](https://miro.medium.com/max/1400/1*9zeIJ3ySJfLnCV6T0DhnUg.png)

The model was converted from Keras to TensorFlow Lite using the **TocoConverter** python class to migrate from the Keras '*.h5'* format to the TensorFlow Lite *'.tflite'* format.


## Based on TensorFlow Lite Object Recognition Example
This code modified from the TensorFlow's object detection canonical example, to be used with the face mask model described above. In that repository we can find the source code for Android, iOS and Raspberry Pi. Here we will focus on making it work on Android, but doing it on the other platforms would simply consist of doing the analogous procedure.

## Adding the Face Recognition Step
The original code works with a single model (trained on the COCO dataset) and computes the results in one single step. For this app, we need to implement the two steps detection. Most of the work will consist in splitting the detection, first the face detection and second the mask detection. For the face detection step we are going to use the Google ML kit.
he original app defines two bitmaps (the rgbFrameBitmap where the preview frame is copied, and the croppedBitmap which is originally used to feed the inference model). We are going to define two additional bitmaps for processing, the portraitBmp and the faceBmp. The first is simply to rotate the input frame in portrait mode for devices that have the sensor in landscape orientation. And the faceBmp bitmap is used to draw every detected face, cropping its detected location, and re-scaling to 224 x 224 px to be used as input of the MobileNetV2 model. The frameToCropTransform converts coordinates from the original bitmap to the cropped bitmap space, and cropToFrameTransform does it in the opposite direction.

When the frames arrive the face detector is used. Face detection is done on the croppedBitmap, since is smaller it can speed up the detection process.

If faces are detected, the original frame is drawn in the portraitBmp bitmap to proceed with the second step detection. For each detected face, its bounding box is retrieved and mapped from the cropped space to the original space. This way we can get a better resolution image to feed the mask detector. Face cropping is done by translating the portrait bitmap to the face's origin and scaling in such a way the face bounding box size matches the 224x224 pixels. Finally the mask detector is invoked.

## Adding the mask detection step
First the TensorFlow Lite model file was added to the assets folder of the project.

And then the required parameters to fit our model requirements in the DetectorActivity configuration section were adjusted. We set the input size of the model to **TF_OD_API_INPUT_SIZE = 224**, and **TF_OD_IS_QUANTIZED = false**. We need to point to the mask detector file. Also we can create a label map text file with the classes names "mask" and "no-mask". Also we define a larger preview size to (800x600) px. to have better resolution for our detector.

