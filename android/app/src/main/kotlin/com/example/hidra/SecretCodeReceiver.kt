package com.example.hidra

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log

class SecretCodeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "android.provider.Telephony.SECRET_CODE") return

        try {
            Log.d("HIDRA", "Secret dial code detected")

            // 🔑 Tell Flutter this is a secret launch
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

            prefs.edit()
                .putBoolean("flutter.launch_via_secret_code", true)
                .apply()

            val pm = context.packageManager

            // 🚨 CRITICAL FIX:
            // Disable FakeDialerAlias so Android DOES NOT launch it
            pm.setComponentEnabledSetting(
                ComponentName(context, "com.example.hidra.FakeDialerAlias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )

            // Launch real activity
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            context.startActivity(launchIntent)

        } catch (e: Exception) {
            Log.e("HIDRA", "SecretCodeReceiver error", e)
        }
    }
}
