package me.yangga.imageutils;

import android.media.ExifInterface;
import android.net.Uri;
import android.util.Log;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.Tag;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

final class Meta {
    public static void metaReadData(String imagePath, final Callback callback) {
        try {
            Uri imageUri = Uri.parse(imagePath);
            File imageFile = new File(imageUri.getPath());
            Metadata metadata = ImageMetadataReader.readMetadata(imageFile);
            WritableMap metaDataMap = Arguments.createMap();
            for (Directory directory : metadata.getDirectories()) {
                WritableMap directoryMap = Arguments.createMap();
                for (Tag tag : directory.getTags()) {
                    directoryMap.putString(tag.getTagName(),tag.toString());
                }
                metaDataMap.putMap(directory.getName(),directoryMap);
            }
            callback.invoke(null, metaDataMap);
        } catch (Exception e) {
            Log.e("RNImageUtil", e.toString());
            e.printStackTrace();
            callback.invoke(e.toString());
        }
    }

    public static void metaWriteData(String imagePath, ReadableMap metadataRM, final Callback callback){
        try{
            Uri imageUri = Uri.parse(imagePath);
            ExifInterface exifInterface = new ExifInterface(imageUri.getPath());
            HashMap<String,Object> metadataHM= metadataRM.toHashMap();
            Iterator iter = metadataHM.entrySet().iterator();
            while(iter.hasNext()){
                Map.Entry entry = (Map.Entry) iter.next();
                exifInterface.setAttribute(entry.getKey().toString(),entry.getValue().toString());
            }
            exifInterface.saveAttributes();
            callback.invoke(null, "");
        } catch(Exception e){
            Log.e("RNImageUtil", e.toString());
            e.printStackTrace();
            callback.invoke(e.toString());
        }
    }
}
