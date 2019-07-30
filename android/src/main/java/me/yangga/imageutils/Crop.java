package me.yangga.imageutils;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;

import com.facebook.react.bridge.ReadableMap;

import org.opencv.android.Utils;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;
import org.opencv.utils.Converters;

import java.util.Arrays;
import java.util.List;

final class Crop {
    @ImageUtilsProcedure
    static Mat cropPerspective(Mat src, ReadableMap param) {
        final Point tl = new Point(param.getMap("topLeft").getDouble("x"), param.getMap("topLeft").getDouble("y"));
        final Point tr = new Point(param.getMap("topRight").getDouble("x"), param.getMap("topRight").getDouble("y"));
        final Point bl = new Point(param.getMap("bottomLeft").getDouble("x"), param.getMap("bottomLeft").getDouble("y"));
        final Point br = new Point(param.getMap("bottomRight").getDouble("x"), param.getMap("bottomRight").getDouble("y"));

        final Size sizeDst = new Size(src.cols(), src.rows());

        final List<Point> listPtSrc = toPoints(tl, tr, bl, br);
        final List<Point> listPtDst = sizeToPoints(sizeDst);

        Mat src_mat = Converters.vector_Point2f_to_Mat(listPtSrc);
        Mat dst_mat = Converters.vector_Point2f_to_Mat(listPtDst);

        Mat perspectiveTransform = Imgproc.getPerspectiveTransform(src_mat, dst_mat);

        Mat dst = new Mat();
        Imgproc.warpPerspective(src,
                dst,
                perspectiveTransform,
                sizeDst,
                Imgproc.INTER_CUBIC);

        return dst;
    }

    @ImageUtilsProcedure
    static Mat cropRoundedCorner(Mat src, ReadableMap param) {
        final float radius = (float)param.getDouble("radius");

        Bitmap bitmap = Bitmap.createBitmap(src.cols(), src.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(src, bitmap);

        Bitmap output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());
        final RectF rectF = new RectF(rect);

        paint.setAntiAlias(true);
        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);
        canvas.drawRoundRect(rectF, radius, radius, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, rect, rect, paint);

        Mat matRes = new Mat();
        Utils.bitmapToMat(output, matRes);

        output.recycle();

        return matRes;
    }


    static List<Point> sizeToPoints(Size size) {
        return toPoints(
                new Point(0, 0),
                new Point(size.width, 0),
                new Point(0, size.height),
                new Point(size.width, size.height)
        );
    }

    static List<Point> toPoints(Point tl, Point tr, Point bl, Point br) {
        return Arrays.asList(bl, tr, tl, br);
    }
}
