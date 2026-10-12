package com.softverse.softverse

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Saves a file straight into the public Downloads folder (no "Save as"
 * picker) and posts a "download complete" notification that opens it -
 * the way a browser download behaves.
 */
class DownloadsBridge(private val activity: Activity, messenger: BinaryMessenger) {
    private val channelId = "softverse_downloads"

    init {
        MethodChannel(messenger, "softverse/downloads").setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                    if (bytes == null || fileName == null) {
                        result.error("bad_args", "bytes and fileName are required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val uri = save(bytes, fileName, mimeType)
                        if (uri == null) {
                            result.success(false)
                        } else {
                            notifySaved(uri, fileName, mimeType)
                            result.success(true)
                        }
                    } catch (error: Exception) {
                        result.error("save_failed", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Android 10+ only: older versions need storage permission, so Dart falls back to the picker. */
    private fun save(bytes: ByteArray, fileName: String, mimeType: String): Uri? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val resolver = activity.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values) ?: return null
        resolver.openOutputStream(uri)?.use { it.write(bytes) }
        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return uri
    }

    private fun notifySaved(uri: Uri, fileName: String, mimeType: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            // Ask once; this download is saved either way.
            activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 9103)
            return
        }
        val manager = activity.getSystemService(NotificationManager::class.java) ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(channelId, "Downloads", NotificationManager.IMPORTANCE_DEFAULT)
            )
        }
        val open = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val pending = PendingIntent.getActivity(
            activity,
            fileName.hashCode(),
            open,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        @Suppress("DEPRECATION")
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(activity, channelId)
        } else {
            Notification.Builder(activity)
        }
        val notification = builder
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle(fileName)
            .setContentText("Download complete")
            .setContentIntent(pending)
            .setAutoCancel(true)
            .build()
        manager.notify(fileName.hashCode(), notification)
    }
}
