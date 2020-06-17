### Real time face recognition with Android + MobileFaceNet + TensorFlow Lite

The impressive effect of having the state-of-the-art running on your hands

![](https://cdn-images-1.medium.com/max/800/1*LPNkC_og-5l1UGkPuMmzkA.png)

### Introduction

A friend of mine reacted to [my last post](https://medium.com/@estebanuri/real-time-face-mask-recognition-in-android-with-tensorflow-lite-215df6327265) with the following questions: **_“is it possible to make an app that compares faces on mobile_**  **_without an Internet connection? How accurate could it be?_**_”_. At that time I didn’t know the answer for his questions. Surely a deep learning model will do the job, but which one? And will it be light enough to fit in a mobile device? And will it be fast enough? And how accurate could it be? These questions remained in my mind like a “UNIX demon”, until I found the answers. In this article I walk through all those questions in detail, and as a corollary **I provide a working example application** that solves this problem in real time using the state-of-the-art convolutional neural network to accurate verify faces on mobile.

What are the key features of this app?

-   It recognizes faces **very accurately**
-   It works **offline**, in **real time**
-   It uses a **mobile-oriented** **deep learning** architecture

![](https://cdn-images-1.medium.com/max/400/1*4SwMMiDI_2mB0dYqDmuvUg.gif)

**An example of the working app.** Will Farrell (the comedian) vs Chad Smith (the drummer). People usually confuse them. First the faces are registered in the dataset, then the app recognizes the faces in runtime. Tested on my Google Pixel 3.
