package org.tensorflow.lite.tflite;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetector;
import com.google.mlkit.vision.face.FaceDetectorOptions;
import com.google.mlkit.vision.face.FaceLandmark;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutionException;

public class FaceEmbedder {

    private TFLiteModel model;

    private static final int TF_OD_API_INPUT_SIZE = 112;
    private static final boolean TF_OD_API_IS_QUANTIZED = false;
    private static final String TF_OD_API_MODEL_FILE = "mobile_face_net.tflite";

    //private Bitmap bitmap;
    private Bitmap faceBmp;
    private FaceDetector faceDetector;

    public String idAlgorithm()  {
        return "MFN.01";
    }

    public float getThreshold() {
        return 0.89f;
    }

    public float getMargin() {
        return 0.2f;
    }


    public FaceEmbedder(AssetManager mgr) throws IOException {

        //Context context = RekonApp.getAppContext();
        //FaceDetector detector = new FaceDetector.Builder(context)
        //        .setClassificationType(FaceDetector.ALL_CLASSIFICATIONS)
        //        .setProminentFaceOnly(true)
        //        //.setMode(FaceDetector.ACCURATE_MODE)
        //        .setMode(FaceDetector.FAST_MODE)
        //        .build();
        // Real-time contour detection of multiple faces
        FaceDetectorOptions options =
                new FaceDetectorOptions.Builder()
                        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
                        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
                        .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
                        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
                        .build();


        faceDetector = FaceDetection.getClient(options);



        final String modelFilename = TF_OD_API_MODEL_FILE;
        final int inputSize = TF_OD_API_INPUT_SIZE;
        final boolean isQuantized = TF_OD_API_IS_QUANTIZED;

        model = TFLiteModel.create(mgr, modelFilename, inputSize, isQuantized);

        //bitmap = null;
        faceBmp = Bitmap.createBitmap(TF_OD_API_INPUT_SIZE, TF_OD_API_INPUT_SIZE, Bitmap.Config.ARGB_8888);

    }


    private Face findLargestArea(final List<Face> faces) {

        Face face = null;
        float maxArea = 0;
        for (int i = 0; i < faces.size(); i++) {
            Face f = faces.get(i);
            //float area = f.getWidth() * f.getHeight();
            Rect bb = f.getBoundingBox();
            float area = bb.width() * bb.height();
            if (area > maxArea) {
                maxArea = area;
                face = f;
            }
        }
        return face;

    }

    public float[] run(final Bitmap bitmap)
            throws ExecutionException, InterruptedException {
        return run(bitmap, null);
    }


    public float[] run(final Bitmap bitmap, HashMap<String, Object> debugInfo)
            throws ExecutionException, InterruptedException {

        InputImage image = InputImage.fromBitmap(bitmap, 0); //Frame frame = new Frame.Builder().setBitmap(bitmap).build();
        Task<List<Face>> task = faceDetector.process(image);
        Tasks.await(task);
        List<Face> faces = task.getResult();

        Face face = findLargestArea(faces);
        if (face == null) {
            // no face found!!!
            return null;
        }


        //final Bitmap debugBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
        //final Canvas debugCanvas = new Canvas(debugBitmap);

        final Canvas cvFace = new Canvas(faceBmp);
        final RectF faceBB = new RectF(face.getBoundingBox());

//            final PointF pos = face.getPosition();
//            final RectF faceBB = new RectF(
//                    pos.x - face.getWidth()/2.0f,
//                    pos.y - face.getHeight()/2.0f,
//                    pos.x + face.getWidth()/2.0f,
//                    pos.x + face.getHeight()/2.0f);
//
//            // translates portrait to origin and scales to fit input inference size
        final Paint paint = new Paint();
        paint.setColor(Color.RED);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(2.0f);
        //debugCanvas.drawRect(faceBB, paint);

        // FACE ALIGNMENT:
        FaceLandmark landLeftEye = face.getLandmark(FaceLandmark.LEFT_EYE);
        FaceLandmark landRightEye = face.getLandmark(FaceLandmark.RIGHT_EYE);
        PointF leftEye = landLeftEye.getPosition();
        PointF rightEye = landRightEye.getPosition();
        float dY = rightEye.y - leftEye.y;
        float dX = rightEye.x - leftEye.x;
        double angleRad = Math.atan2(dY, dX);
        double angleDeg = Math.toDegrees(angleRad);// - 180;

        PointF eyesCenter = new PointF(
                (leftEye.x + rightEye.x) / 2,
                (leftEye.y + rightEye.y) /2
        );


        float sx = ((float) TF_OD_API_INPUT_SIZE) / faceBB.width();
        float sy = ((float) TF_OD_API_INPUT_SIZE) / faceBB.height();
        Matrix matrix = new Matrix();

        matrix.postTranslate(-eyesCenter.x, -eyesCenter.y);
        matrix.postRotate((float) -angleDeg);
        matrix.postTranslate(eyesCenter.x, eyesCenter.y);

        matrix.postTranslate(-faceBB.left, -faceBB.top);
        matrix.postScale(sx, sy);
        cvFace.drawBitmap(bitmap, matrix, null);

        if (debugInfo != null) {
            debugInfo.put("faceBmp", faceBmp);
        }

        float[][] result = model.run(faceBmp);
        return result[0];

    }

    public float distance(float[] emb1, float[] emb2) {

        float distance = 0;
        for (int i = 0; i < emb1.length; i++) {
            float diff = emb1[i] - emb2[i];
            distance += diff*diff;
        }
        distance = (float) Math.sqrt(distance);
        return distance;

    }

}
