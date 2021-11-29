package com.estebanuri.verifymfn.db;

import androidx.room.TypeConverter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.Date;

public class Converters {

    @TypeConverter
    public static Date dateFromLong(Long value) {

        return value == null ? null : new Date(value);

    }

    @TypeConverter
    public static Long longFromDate(Date date) {

        return date == null ? null : date.getTime();

    }



    @TypeConverter
    public static float[] floatArrayFromByteArray(byte[] bytes)  {

        float[] floats = null;
        try {

            ByteArrayInputStream bas = new ByteArrayInputStream(bytes);
            DataInputStream ds = new DataInputStream(bas);
            floats = new float[bytes.length / 4];  // 4 bytes per float
            for (int i = 0; i < floats.length; i++)
            {
                    floats[i] = ds.readFloat();
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return floats;
    }

    @TypeConverter
    public static byte[] byteArrayFromFloatArray(float[] floats)  {

        byte[] bytes = null;
        try {
            ByteArrayOutputStream bas = new ByteArrayOutputStream();
            DataOutputStream ds = new DataOutputStream(bas);
            for (float f : floats) {
                    ds.writeFloat(f);
            }
            bytes = bas.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return bytes;
    }


}