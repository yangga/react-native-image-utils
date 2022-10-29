package me.yangga.imageutils;

import com.facebook.react.bridge.ReadableMap;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

final class Trans {
    @ImageUtilsProcedure
    static Mat transOrientRotate(Mat src, ReadableMap param) {
        final int degrees = param.getInt("degrees");
        if (degrees == 90) {
            Core.transpose(src, src);
            Core.flip(src, src, 1);
        } else if (degrees == 180) {
            Core.flip(src, src, -1);
        } else if (degrees == 270) {
            Core.transpose(src, src);
            Core.flip(src, src, 0);
        }

        return src;
    }

    @ImageUtilsProcedure
    static Mat transResize(Mat src, ReadableMap param) {
        final double width = param.getInt("width");
        final double height = param.getInt("height");

        Mat dst = new Mat();
        Imgproc.resize(src, dst, new Size(width, height));

        return dst;
    }

    @ImageUtilsProcedure
    static Mat transScale(Mat src, ReadableMap param) {
        final double scale = param.getDouble("scale");

        Mat dst = new Mat();
        Imgproc.resize(src, dst, new Size(src.width()*scale, src.height()*scale));

        return dst;
    }
}
