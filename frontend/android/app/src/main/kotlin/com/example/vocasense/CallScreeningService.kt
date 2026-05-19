package com.example.vocasense

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONArray

class CallScreeningService : CallScreeningService() {

    companion object {
        private const val CHANNEL_ID = "vocasense_spam_alerts"
        private const val CHANNEL_NAME = "Spam Call Alerts"
        private const val NOTIFICATION_ID = 1001
    }

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneNumber = callDetails.handle?.schemeSpecificPart ?: ""

        Log.d("VocaSense", "Incoming call from: $phoneNumber")

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val rawSpamList = prefs.getString("flutter.spam_numbers_cache", "[]") ?: "[]"

        val spamNumbers = mutableListOf<String>()
        val jsonArray = JSONArray(rawSpamList)

        for (i in 0 until jsonArray.length()) {
            spamNumbers.add(jsonArray.getString(i))
        }

        val isSpam = spamNumbers.contains(phoneNumber)

        val response = CallResponse.Builder()

        if (isSpam) {
            Log.d("VocaSense", "SPAM DETECTED FROM CACHE")
            savePendingCallLog(phoneNumber, "spam", 0.95)

            showSpamNotification(phoneNumber)

            response
                .setDisallowCall(true)
                .setSilenceCall(true)
                .setRejectCall(true)
                .setSilenceCall(true)
                .setSkipCallLog(false)
                .setSkipNotification(false)
        } else {
            response.setDisallowCall(false)
        }

        respondToCall(callDetails, response.build())
    }

    private fun showSpamNotification(phoneNumber: String) {
        createNotificationChannel()

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("Warning: Possible spam call")
            .setContentText("Incoming call from $phoneNumber may be unsafe.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        try {
            NotificationManagerCompat.from(this).notify(NOTIFICATION_ID, notification)
        } catch (e: SecurityException) {
            Log.e("VocaSense", "Notification permission missing", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Alerts when VocaSense detects a spam call"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun savePendingCallLog(phoneNumber: String, status: String, riskScore: Double) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val key = "flutter.pending_call_logs"
        val oldRaw = prefs.getString(key, "[]") ?: "[]"
        val array = JSONArray(oldRaw)

        val obj = org.json.JSONObject()
        obj.put("phone", phoneNumber)
        obj.put("status", status)
        obj.put("risk_score", riskScore)
        obj.put("source", "android_screening")
        obj.put("timestamp", System.currentTimeMillis())

        array.put(obj)

        prefs.edit().putString(key, array.toString()).apply()

        Log.d("VocaSense", "Pending call log saved: $phoneNumber")
    }
}