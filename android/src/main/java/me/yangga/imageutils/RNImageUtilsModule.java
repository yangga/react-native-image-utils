
package me.yangga.imageutils;

import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableMap;
import com.squareup.picasso.Picasso;

import org.opencv.android.Utils;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Size;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNImageUtilsModule extends ReactContextBaseJavaModule {

  private Map<String, Method> procedures = new HashMap<String, Method>();
  private final ReactApplicationContext reactContext;

  public RNImageUtilsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;

    try {
        // register procedures
        initProcedures(Crop.class);
        initProcedures(Scale.class);
        initProcedures(Trans.class);
    }
    catch (Exception e) {
        Log.e("RNImageUtil", e.toString());
    }
  }

  @Override
  public String getName() {
    return "RNImageUtils";
  }

  @ReactMethod
  public void proxies(final ReadableMap outOptions, final String imageUri, final ReadableArray proxyParams, final Callback callback) {
      try {
          Bitmap bmp = Picasso.with(this.reactContext)
                  .load(imageUri)
                  .get();

          ReadableMap res = proxiesProc(bmp, outOptions, proxyParams, callback);
          bmp.recycle();

          callback.invoke(null, res);
      }
      catch (Exception e) {
          Log.e("RNImageUtil", e.toString());
          e.printStackTrace();
          callback.invoke(e.toString());
      }
  }

  ReadableMap proxiesProc(final Bitmap bmp, final ReadableMap outOptions, final ReadableArray proxyParams, final Callback callback) throws Exception {
      Mat matSrc = new Mat();
      Utils.bitmapToMat(bmp, matSrc);

      for (int i=0; i<proxyParams.size(); i++) {
          final ReadableMap p = proxyParams.getMap(i);
          final String cmd = p.getString("cmd");
          final ReadableMap param = p.getMap("param");

          Method method = this.procedures.get(cmd);
          if (null == method) {
              throw new Exception("invalid method : " + cmd);
          }
          Mat newMat = (Mat)method.invoke(null, matSrc, param);
          if (null == newMat) {
              throw new Exception("invalid result mat : " + cmd);
          }

          if (matSrc != newMat) {
              matSrc.release();
              matSrc = newMat;
          }
      }

      // convert result Mat to Bitmp
      Bitmap bmpRes = Bitmap.createBitmap(matSrc.cols(), matSrc.rows(), Bitmap.Config.ARGB_8888);
      Utils.matToBitmap(matSrc, bmpRes);

      // save result to file
      final String format = outOptions.getString("format");
      final int quality = ((Double) (outOptions.getDouble("quality") * 100.0f)).intValue();
      String outputPath = outOptions.getString("path");

      File newFile;
      if (null != outputPath && 0 < outputPath.length()) {
        newFile = new File(outputPath);
        if(!newFile.createNewFile()) {
            throw new IOException("The file already exists");
        }
      } else {
          File outputDir = this.reactContext.getCacheDir(); // context being the Activity pointer
          newFile = File.createTempFile("tempRNImageUtil", "."+format, outputDir);
          outputPath = newFile.toPath().toString();
      }

      byte[] bitmapData = bitmapToData(bmpRes, format, quality);
      dataToFile(newFile, bitmapData);

      WritableMap map = Arguments.createMap();
      map.putString("path", outputPath);
      map.putString("uri", "file://" + Uri.parse(outputPath).toString());
      map.putInt("fileSize", bitmapData.length);
      map.putInt("width", matSrc.cols());
      map.putInt("height", matSrc.rows());

      matSrc.release();

      return map;
  }

  void initProcedures(Class<?> cls) {
      Method[] methods = cls.getDeclaredMethods();
      for (Method m : methods) {
          ImageUtilsProcedure an = m.getAnnotation(ImageUtilsProcedure.class);
          if (an != null) {
              m.setAccessible(true);
              this.procedures.put(m.getName(), m);
          }
      }
  }

  byte[] bitmapToData(Bitmap bmp, String format, int quality) throws java.io.IOException {
      Bitmap.CompressFormat compressFormat = Bitmap.CompressFormat.valueOf(format);
      ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
      bmp.compress(compressFormat, quality, outputStream);
      byte[] bitmapData = outputStream.toByteArray();

      outputStream.flush();
      outputStream.close();

      return bitmapData;
  }

  void dataToFile(File f, byte[] data) throws java.io.IOException {
      FileOutputStream fos = new FileOutputStream(f);
      fos.write(data);
      fos.flush();
      fos.close();
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