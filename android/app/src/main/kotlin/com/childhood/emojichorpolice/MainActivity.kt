package com.childhood.emojichorpolice

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "emoji_chor_police/progress"
    private val preferencesName = "emoji_chor_police_progress"
    private val progressKey = "progress_json"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            val preferences = getSharedPreferences(preferencesName, Context.MODE_PRIVATE)

            when (call.method) {
                "load" -> result.success(preferences.getString(progressKey, null))
                "save" -> {
                    val json = call.argument<String>("json")
                    if (json == null) {
                        result.error("missing_json", "Progress JSON is required.", null)
                    } else {
                        preferences.edit().putString(progressKey, json).apply()
                        result.success(null)
                    }
                }
                "clear" -> {
                    preferences.edit().remove(progressKey).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
