package com.company.yks_mentor

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(Intent(this, com.dexterous.flutterlocalnotifications.ForegroundService::class.java))
        }
    }
} 