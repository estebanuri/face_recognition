package com.estebanuri.verifymfn.db;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;

@Entity(tableName = "faceEmbeddings", primaryKeys = {"idResource"})
public class FaceEmbeddingsRecord {


    @NonNull
    public String idResource;

    @NonNull
    public String idAlgorithm;

    @NonNull
    public String idPerson;

    @ColumnInfo(typeAffinity = ColumnInfo.BLOB)
    public float[] embeddings;

    @ColumnInfo(typeAffinity = ColumnInfo.BLOB)
    public byte[] image;


}