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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cloud_courier_climb/settings"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadSettings" -> {
                    result.success(
                        mapOf(
                            "soundEnabled" to preferences.getBoolean("sound_enabled", true),
                            "hapticsEnabled" to preferences.getBoolean("haptics_enabled", true),
                            "completedChallengeSteps" to preferences.getInt("completed_challenge_steps", 0)
                        )
                    )
                }
                "saveSettings" -> {
                    val editor = preferences.edit()
                    call.argument<Boolean>("soundEnabled")?.let {
                        editor.putBoolean("sound_enabled", it)
                    }
                    call.argument<Boolean>("hapticsEnabled")?.let {
                        editor.putBoolean("haptics_enabled", it)
                    }
                    call.argument<Int>("completedChallengeSteps")?.let {
                        val savedSteps = preferences.getInt("completed_challenge_steps", 0)
                        if (it > savedSteps) {
                            editor.putInt("completed_challenge_steps", it)
                        }
                    }
                    editor.apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
