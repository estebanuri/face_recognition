package com.estebanuri.verifymfn

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.estebanuri.verifymfn.db.DB
import com.estebanuri.verifymfn.db.FaceEmbeddingsRecord
import org.apache.commons.compress.archivers.tar.TarArchiveEntry
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.gzip.GzipCompressorInputStream
import org.junit.Test
import org.junit.runner.RunWith
import org.tensorflow.lite.tflite.FaceEmbedder
import java.io.*
import java.net.URL


/**
 * Instrumented test, which will execute on an Android device.
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
@RunWith(AndroidJUnit4::class)
class ProcessLFWTest {

    private val TAG: String = "ProcessLFWTest"

    fun download(link: String, path: String) {
        URL(link).openStream().use { input ->
            FileOutputStream(File(path)).use { output ->
                input.copyTo(output)
            }
        }
    }

    fun getContext(): Context {
        return InstrumentationRegistry.getInstrumentation().targetContext
    }

    fun map2local(url: String) : String {
        val outdir = getContext().filesDir

        val filename: String = url.substring(url.lastIndexOf("/") + 1)
        val file: File = File(outdir, filename)
        val des = file.absolutePath
        return des

    }


    fun extractTarGZ(inputFile: File) {

        //val inputFile = File(inputFile)
        val fis = FileInputStream(inputFile)

        val BUFFER_SIZE = 4096

        val gzipIn = GzipCompressorInputStream(fis)
        try {
            val tarIn = TarArchiveInputStream(gzipIn)
            var entry : TarArchiveEntry?

            while (true) {
                entry = tarIn.nextEntry as TarArchiveEntry?
                if (entry == null) {
                    break
                }

                val name = entry.name

                val fullFile = File(getContext().filesDir, name)
                if (entry.isDirectory()) {

                    if (!fullFile.exists()) {
                        val created = fullFile.mkdir()
                        Log.d(TAG, "extractTarGZ: directory $created")
                    }
                }
                else {
                    Log.d(TAG, "extractTarGZ: extracting file $name")
                    var count: Int
                    val data = ByteArray(BUFFER_SIZE)
                    val fos = FileOutputStream(fullFile, false)
                    BufferedOutputStream(fos, BUFFER_SIZE).use { dest ->
                        while (tarIn.read(data, 0, BUFFER_SIZE).also { count = it } != -1) {
                            dest.write(data, 0, count)
                        }
                    }
                }
            }

        }
        catch (e: Exception) {

        }


    }

    fun downloadLFW() {

        Log.d(TAG, "Starting")

        // All images as gzipped tar file
        val lfwUrl = "http://vis-www.cs.umass.edu/lfw/lfw.tgz"
        val lfwMD5 = "a17d05bd522c52d84eca14327a23d494"

        val local = map2local(lfwUrl)
        val localFile = File(local)


        if (!localFile.exists()) {
            Log.d(TAG, "downloading LFW file")
            download(lfwUrl, local)
            assert(localFile.exists())
        }
        else
            if (localFile.exists()) {
                //Log.d(TAG, "LFW file found")
                extractTarGZ(localFile)
                localFile.delete()
            }

    }

    fun encodeBitmap(bmp: Bitmap): ByteArray {
        val bos = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, 100, bos)
        return bos.toByteArray()
    }

    // Downloads from the official site, the labeled faces in the wild
    // dataset, and computes its embeddings.
    // Results are stored into a SQLite database.

    @Test
    fun processLFW() {

        val basePath = getContext().filesDir
        val dir = File(basePath, "/lfw")
        if (!dir.exists()) {
            dir.mkdirs()
            downloadLFW()
        }
        assert(dir.exists())

        val subDirs = dir.list()
                .sortedBy { it.toLowerCase() }

        Log.d(TAG, "processLFW: loading face embedder...")

        val faceEmbedder = FaceEmbedder(getContext().assets)
        val dao = DB.getInstance(getContext()).dao
        dao.deleteFaceEmbeddings()

        val debugInfo = HashMap<String, Any>()
        for (sd in subDirs) {

            val personName = sd
            val subDir = File(dir, "/" + sd)
            val imgPaths = subDir.list()

            for (imgPath in imgPaths) {
                val imgFile = File(subDir, imgPath)
                Log.d(TAG, "processLfw: ${personName}, ${imgPath}")

                val bitmap = BitmapFactory.decodeFile(imgFile.absolutePath)

                val embeddings = faceEmbedder.run(bitmap, debugInfo)

                val rec = FaceEmbeddingsRecord()
                rec.embeddings = embeddings
                rec.idPerson = personName
                rec.idResource = imgPath
                rec.idAlgorithm = "0"
                rec.image = encodeBitmap(debugInfo["faceBmp"] as Bitmap)

                dao.insertFaceEmbeddings(rec)

                bitmap.recycle()

            }

        }

    }
}