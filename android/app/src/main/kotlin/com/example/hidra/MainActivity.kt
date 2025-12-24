package com.example.hidra

import android.content.ComponentName
import android.content.pm.PackageManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SCREENSHOT_CHANNEL = "hidra/screenshot"
    private val HIDE_APP_CHANNEL = "hide_app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ================= SCREENSHOT BLOCK =================
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREENSHOT_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecure" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(null)
                }

                "disableSecure" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // ================= HIDE / SHOW APP ICON =================
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HIDE_APP_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hide" -> {
                    hideRealAppIcon()
                    showFakeDialerIcon()

                    // 🔥 CRITICAL: CLOSE TASK CLEANLY
                    finishAndRemoveTask()

                    result.success(null)
                }

                "show" -> {
                    showRealAppIcon()
                    hideFakeDialerIcon()

                    // 🔥 CRITICAL: CLOSE TASK CLEANLY
                    finishAndRemoveTask()

                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ================= ICON TOGGLING =================

    private fun hideRealAppIcon() {
        applicationContext.packageManager.setComponentEnabledSetting(
            ComponentName(applicationContext, "com.example.hidra.MainActivityAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun showRealAppIcon() {
        applicationContext.packageManager.setComponentEnabledSetting(
            ComponentName(applicationContext, "com.example.hidra.MainActivityAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun showFakeDialerIcon() {
        applicationContext.packageManager.setComponentEnabledSetting(
            ComponentName(applicationContext, "com.example.hidra.FakeDialerAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun hideFakeDialerIcon() {
        applicationContext.packageManager.setComponentEnabledSetting(
            ComponentName(applicationContext, "com.example.hidra.FakeDialerAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
    }
}
