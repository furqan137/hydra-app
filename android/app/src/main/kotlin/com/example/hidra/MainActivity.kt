package com.example.hidra

import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

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
                    result.success(true)
                }

                "disableSecure" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
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

                // 🔒 HIDE APP → SHOW FAKE DIALER
                "hide" -> {
                    toggleAppIcon(hide = true)
                    result.success(true)
                }

                // 🔓 UNHIDE APP → SHOW REAL ICON
                "show" -> {
                    toggleAppIcon(hide = false)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ================= CORE TOGGLING LOGIC =================

    private fun toggleAppIcon(hide: Boolean) {
        val pm = applicationContext.packageManager

        val realApp = ComponentName(
            applicationContext,
            "com.example.hidra.MainActivityAlias"
        )

        val fakeDialer = ComponentName(
            applicationContext,
            "com.example.hidra.FakeDialerAlias"
        )

        if (hide) {
            // Hide Hidra → Show Phone
            pm.setComponentEnabledSetting(
                realApp,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )

            pm.setComponentEnabledSetting(
                fakeDialer,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        } else {
            // Show Hidra → Hide Phone
            pm.setComponentEnabledSetting(
                fakeDialer,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )

            pm.setComponentEnabledSetting(
                realApp,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }

        // 🔥 FORCE LAUNCHER REFRESH SAFELY
        Handler(Looper.getMainLooper()).postDelayed({
            finishAndRemoveTask()
        }, 300)
    }
}
