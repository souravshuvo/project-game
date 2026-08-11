package com.childhood.cloudcourierclimb

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val preferences = getSharedPreferences("cloud_courier_climb", Context.MODE_PRIVATE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cloud_courier_climb/best_score"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadBestScore" -> {
                    result.success(preferences.getInt("best_score", 0))
                }
                "saveBestScore" -> {
                    val score = call.argument<Int>("score") ?: 0
                    preferences.edit().putInt("best_score", score).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
