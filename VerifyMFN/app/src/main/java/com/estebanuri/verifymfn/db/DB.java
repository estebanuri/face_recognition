package com.estebanuri.verifymfn.db;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

@Database(entities = {
        FaceEmbeddingsRecord.class
    },
        exportSchema = false,
        version = 1)
@TypeConverters({Converters.class})
public abstract class DB extends RoomDatabase {

    private static DB instance;

    public abstract DBDao getDAO();

    public static DB getInstance(Context context) {

        if (instance == null) {
            instance =
                    Room.databaseBuilder(context.getApplicationContext(), DB.class, "db")
                            // allow queries on the main thread.
                            // Don't do this on a real app! See PersistenceBasicSample for an example.
                            .allowMainThreadQueries()
                            .fallbackToDestructiveMigration()
                            .build();
        }
        return instance;
    }

    public static void destroyInstance() {
        instance = null;
    }
}