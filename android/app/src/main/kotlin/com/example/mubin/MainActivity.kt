package com.example.mubin

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {

    private val METHOD_CHANNEL = "com.example.mubin/method"
    private val EVENT_CHANNEL = "com.example.mubin/stream"

    private var eventSink: EventChannel.EventSink? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var currentSurfaceProvider: Preview.SurfaceProvider? = null
    private lateinit var cameraExecutor: ExecutorService
    
    private lateinit var prayerAnalyzer: PrayerAnalyzer
    private var frameCounter = 0
    private var isLiveAnalysisActive = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        prayerAnalyzer = PrayerAnalyzer(this)
        prayerAnalyzer.init()
    }

    // Dedicated thread pool for video processing
    private val videoExecutor: ExecutorService = Executors.newFixedThreadPool(2)

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
        videoExecutor.shutdown()
        prayerAnalyzer.close()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register NativeViewFactory
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "camera_preview",
            NativeViewFactory { surfaceProvider ->
                currentSurfaceProvider = surfaceProvider
                startCameraXBinding()
            }
        )

        // Setup EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // Setup MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startInference" -> {
                    isLiveAnalysisActive = true
                    startCameraXBinding()
                    result.success(null)
                }
                "stopInference" -> {
                    isLiveAnalysisActive = false
                    cameraProvider?.unbindAll()
                    result.success(null)
                }
                "toggleCamera" -> {
                    result.success(null) // omitted for brevity
                }
                "analyzeImage" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val postureResult = prayerAnalyzer.analyzeImage(path)
                        if (postureResult != null) {
                            result.success(
                                mapOf(
                                    "label" to postureResult.label,
                                    "confidence" to postureResult.confidence,
                                    "inferenceTime" to postureResult.inferenceTime
                                )
                            )
                        } else {
                            result.error("ERROR", "Failed to analyze image", null)
                        }
                    } else {
                        result.error("ERROR", "Path is null", null)
                    }
                }
                "analyzeVideo" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        videoExecutor.execute {
                            try {
                                val retriever = android.media.MediaMetadataRetriever()
                                retriever.setDataSource(path)

                                val durationStr = retriever.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_DURATION)
                                val durationMs = durationStr?.toLongOrNull() ?: 0L

                                val results = mutableListOf<Map<String, Any>>()
                                val intervalMs = 1000L
                                val totalSteps = (durationMs / intervalMs).toInt() + 1
                                var currentStep = 0

                                val startTime = System.currentTimeMillis()
                                val sdf = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", java.util.Locale.US)
                                Log.d("MainActivity", "--- Video analysis started at: ${sdf.format(java.util.Date(startTime))} ---")
                                Log.d("MainActivity", "Video total duration: ${durationMs}ms, total frames to process: $totalSteps")

                                for (timeMs in 0 until durationMs step intervalMs) {
                                    val frameStartTime = System.currentTimeMillis()
                                    var mlInferenceTime = 0L
                                    val frameBitmap = getScaledFrame(retriever, timeMs * 1000)
                                    if (frameBitmap != null) {
                                        val bitmap = if (frameBitmap.config == android.graphics.Bitmap.Config.ARGB_8888) {
                                            frameBitmap
                                        } else {
                                            val converted = frameBitmap.copy(android.graphics.Bitmap.Config.ARGB_8888, true)
                                            frameBitmap.recycle()
                                            converted
                                        }

                                        if (bitmap != null) {
                                            val postureResult = prayerAnalyzer.analyze(bitmap, 0)
                                            if (postureResult != null) {
                                                mlInferenceTime = postureResult.inferenceTime
                                                val progress = currentStep.toFloat() / totalSteps.toFloat()
                                                val map = mapOf(
                                                    "timestampMs" to timeMs,
                                                    "label" to postureResult.label,
                                                    "confidence" to postureResult.confidence,
                                                    "inferenceTime" to postureResult.inferenceTime,
                                                    "progress" to progress
                                                )
                                                results.add(map)
                                                
                                                runOnUiThread {
                                                    eventSink?.success(map)
                                                }
                                            }
                                            bitmap.recycle()
                                        }
                                    }
                                    currentStep++
                                    val frameEndTime = System.currentTimeMillis()
                                    Log.d("MainActivity", "Frame $currentStep/$totalSteps (video timestamp: ${timeMs}ms) processed in ${frameEndTime - frameStartTime}ms (TFLite Inference: ${mlInferenceTime}ms)")
                                }
                                retriever.release()
                                
                                val endTime = System.currentTimeMillis()
                                val totalTimeSec = (endTime - startTime) / 1000.0
                                Log.d("MainActivity", "--- Video analysis finished at: ${sdf.format(java.util.Date(endTime))} ---")
                                Log.d("MainActivity", "Total processing time: ${totalTimeSec}s for $totalSteps frames")

                                runOnUiThread {
                                    result.success(results)
                                }
                            } catch (e: Exception) {
                                Log.e("MainActivity", "Failed to analyze video", e)
                                runOnUiThread {
                                    result.error("ERROR", "Failed to analyze video", null)
                                }
                            }
                        }
                    } else {
                        result.error("ERROR", "Path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startCameraXBinding() {
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.CAMERA), 10)
            return
        }

        val surfaceProvider = currentSurfaceProvider ?: return

        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()

            frameCounter = 0

            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(surfaceProvider)
            }

            val imageAnalysis = ImageAnalysis.Builder()
                // Use RGBA_8888 because tensor image conversion handles Bitmap easily, and CameraX supports direct toBitmap on newer APIs anyway
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .setTargetResolution(android.util.Size(640, 480))
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()

            imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
                processImageProxy(imageProxy)
            }

            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

            try {
                cameraProvider?.unbindAll()
                cameraProvider?.bindToLifecycle(
                    this, cameraSelector, preview, imageAnalysis
                )
            } catch (exc: Exception) {
                Log.e("MainActivity", "Use case binding failed", exc)
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun processImageProxy(imageProxy: ImageProxy) {
        if (!isLiveAnalysisActive) {
            imageProxy.close()
            return
        }

        val currentFrame = frameCounter++
        if (currentFrame % PrayerConfig.FRAME_SKIP != 0) {
            imageProxy.close()
            return
        }

        val bitmap = imageProxy.toBitmap()
        val rotationDegrees = imageProxy.imageInfo.rotationDegrees

        val postureResult = prayerAnalyzer.analyze(bitmap, rotationDegrees)

        if (postureResult != null) {
            runOnUiThread {
                eventSink?.success(
                    mapOf(
                        "label" to postureResult.label,
                        "confidence" to postureResult.confidence,
                        "inferenceTime" to postureResult.inferenceTime
                    )
                )
            }
        }

        imageProxy.close()
    }

    private fun getScaledFrame(retriever: android.media.MediaMetadataRetriever, timeUs: Long): android.graphics.Bitmap? {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
            try {
                val bitmap = retriever.getScaledFrameAtTime(
                    timeUs,
                    android.media.MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                    640,
                    640
                )
                if (bitmap != null) return bitmap
            } catch (e: Exception) {
                Log.w("MainActivity", "getScaledFrameAtTime failed, trying fallback", e)
            }
        }
        
        // Fallback for older APIs or failures
        try {
            val fullFrame = retriever.getFrameAtTime(
                timeUs,
                android.media.MediaMetadataRetriever.OPTION_CLOSEST_SYNC
            ) ?: return null
            val scaled = android.graphics.Bitmap.createScaledBitmap(fullFrame, 640, 640, false)
            fullFrame.recycle()
            return scaled
        } catch (e: Exception) {
            Log.e("MainActivity", "Fallback frame extraction failed", e)
            return null
        }
    }
}
