import cv2
import numpy as np
from keras_facenet import FaceNet
from tensorflow.keras import models

# def normalize(image, fixed=False):
#     if fixed:
#         return (np.float32(image) - 127.5) / 127.5
#     else:
#         mean = np.mean(image)
#         std = np.std(image)
#         std_adj = np.maximum(std, 1.0 / np.sqrt(image.size))
#         y = np.multiply(np.subtract(image, mean), 1 / std_adj)
#         return y
#
#
# face_net = FaceNet()
#
# dets, crops = face_net.crop("images/a0_adrian1.png")
# face = crops[0]
# cv2.imshow("adrian", cv2.cvtColor(face, cv2.COLOR_RGB2BGR))
#
# face = cv2.resize(face, (160, 160))
# face = normalize(face)
# X = np.expand_dims(face, axis=0)
#
# model_file = 'models/hiroki/facenet_keras.h5'
# hiroki_model = models.load_model(model_file)
# embeedings = hiroki_model.predict(X)
# #embeedings = face_net.model.predict(X)
#
# print(np.linalg.norm(embeedings))
# cv2.waitKey()

# Loads Hiroki's FaceNet model
model_file = 'models/hiroki/facenet_keras.h5'
hiroki_model = models.load_model(model_file)

# Creates a random image
img = np.random.randint(0, 255, (160, 160, 3), dtype='uint8')
#cv2.imshow("random", img)
#cv2.waitKey()

# converts image to float and normalizes it
img = (np.float32(img) - 127.5) / 127.5

# prepares the shape to feed the dnn
X = np.expand_dims(img, axis=0)

# runs model inference
embeedings = hiroki_model.predict(X)

# prints out some output info
print("EMBEEDINGS shape:", embeedings.shape, "norm", np.linalg.norm(embeedings))

