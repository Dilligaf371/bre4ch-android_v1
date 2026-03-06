package com.breach.breach_v2

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val BADGE_CHANNEL = "com.qyber.breach/badge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create FCM notification channel (Android 8+)
        createNotificationChannel()

        // Badge clearing channel (Android equivalent — clears notifications)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BADGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "clearBadge" -> {
                        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        nm.cancelAll()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "breach_alerts",
                "BRE4CH Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Critical operational alerts from BRE4CH"
                enableVibration(true)
                enableLights(true)
            }
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }
}
