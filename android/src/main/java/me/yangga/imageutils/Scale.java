package me.yangga.imageutils;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Paint;

import com.facebook.react.bridge.ReadableMap;

import org.opencv.android.Utils;
import org.opencv.core.Mat;

final class Scale {

    @ImageUtilsProcedure
    static Mat scaleCSB(Mat src, ReadableMap param) {
        // min: -100, default: 0, max: 100
        final float contrast = (float)param.getDouble("contrast");
        final float saturation = (float)param.getDouble("saturation");
        final float brightness = (float)param.getDouble("brightness");

        Bitmap bmp = Bitmap.createBitmap(src.cols(), src.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(src, bmp);

        Bitmap bmpOut = Bitmap.createBitmap(bmp.getWidth(), bmp.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bmpOut);

        ColorMatrix cm = new ColorMatrix();

        ColorFilterGenerator.adjustContrast(cm, Double.valueOf(contrast).intValue());
        ColorFilterGenerator.adjustBrightness(cm, brightness);
        ColorFilterGenerator.adjustSaturation(cm, saturation);

        Paint paint = new Paint();
        paint.setColorFilter(new ColorMatrixColorFilter(cm));
        canvas.drawBitmap(bmp, 0, 0, paint);

        Mat matRes = new Mat();
        Utils.bitmapToMat(bmpOut, matRes);

        bmp.recycle();
        bmpOut.recycle();

        return matRes;
    }

}
