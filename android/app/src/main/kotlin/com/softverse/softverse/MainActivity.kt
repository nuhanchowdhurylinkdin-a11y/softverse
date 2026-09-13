package com.softverse.softverse

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val bluetoothPermissionRequestCode = 9102
    private var bluetoothPermissionResult: MethodChannel.Result? = null
    private var blePrinterBridge: BlePrinterBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        blePrinterBridge = BlePrinterBridge(
            this,
            flutterEngine.dartExecutor.binaryMessenger
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "softverse/app_settings")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openAppSettings" -> {
                        val intent = Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(true)
                    }
                    "requestBluetoothPermissions" -> requestBluetoothPermissions(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestBluetoothPermissions(result: MethodChannel.Result) {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
        } else {
            emptyArray()
        }
        if (permissions.isEmpty()) {
            result.success(true)
            return
        }
        if (permissions.all { checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED }) {
            result.success(true)
            return
        }
        if (bluetoothPermissionResult != null) {
            result.success(false)
            return
        }
        bluetoothPermissionResult = result
        requestPermissions(permissions, bluetoothPermissionRequestCode)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != bluetoothPermissionRequestCode) return
        val granted = grantResults.isNotEmpty() &&
            grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        bluetoothPermissionResult?.success(granted)
        bluetoothPermissionResult = null
    }

    override fun onDestroy() {
        blePrinterBridge?.dispose()
        blePrinterBridge = null
        super.onDestroy()
    }
}
