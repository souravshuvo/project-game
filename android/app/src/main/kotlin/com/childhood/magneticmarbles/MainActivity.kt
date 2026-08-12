package com.childhood.magneticmarbles

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "magnetic_marbles/progress"
        ).setMethodCallHandler { call, result ->
            val preferences = getSharedPreferences(
                "magnetic_marbles_progress",
                Context.MODE_PRIVATE
            )

            when (call.method) {
                "loadProgress" -> result.success(preferences.getString("payload", null))
                "saveProgress" -> {
                    val payload = call.arguments as? String
                    if (payload == null) {
                        result.error("invalid_payload", "Progress payload must be a string.", null)
                    } else {
                        preferences.edit().putString("payload", payload).apply()
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
