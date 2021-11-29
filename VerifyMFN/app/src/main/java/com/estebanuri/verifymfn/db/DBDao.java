package com.estebanuri.verifymfn.db;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;


import java.util.List;

@Dao
public interface DBDao {

    @Insert
    void insertFaceEmbeddings(List<FaceEmbeddingsRecord> records);

    @Insert
    void insertFaceEmbeddings(FaceEmbeddingsRecord record);

    @Query("DELETE FROM faceEmbeddings")
    void deleteFaceEmbeddings();
}
