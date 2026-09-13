package com.softverse.softverse

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque
import java.util.UUID

@SuppressLint("MissingPermission")
class BlePrinterBridge(
    private val activity: Activity,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val channelName = "softverse/ble_printer"
        private const val logTag = "SoftverseBlePrinter"
        private const val scanDurationMs = 5_000L
        private const val connectTimeoutMs = 12_000L
        private const val mtuWaitTimeoutMs = 1_500L
        private val serviceUuid = UUID.fromString("49535343-FE7D-4AE5-8FA9-9FAFD205E455")
        private val writeUuid = UUID.fromString("49535343-8841-43F4-A8D4-ECBE34729BB3")
    }

    private val channel = MethodChannel(messenger, channelName)
    private val handler = Handler(Looper.getMainLooper())
    private val bluetoothManager =
        activity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val adapter get() = bluetoothManager.adapter

    private var scanCallback: ScanCallback? = null
    private var pendingScanResult: MethodChannel.Result? = null
    private val scannedDevices = linkedMapOf<String, BluetoothDevice>()

    private var gatt: BluetoothGatt? = null
    private var connectedAddress: String? = null
    private var isGattConnected = false
    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var writeType: Int = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
    private var pendingConnectResult: MethodChannel.Result? = null
    private var pendingWriteResult: MethodChannel.Result? = null
    private val writeQueue = ArrayDeque<ByteArray>()
    private var negotiatedPayloadSize = 20

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scan" -> scan(call.arguments?.toString()?.takeIf { it.isNotBlank() }, result)
            "connect" -> connect(call.arguments?.toString().orEmpty(), result)
            "writeBytes" -> writeBytes(call.arguments, result)
            "disconnect" -> {
                disconnect()
                result.success(true)
            }
            "connectionStatus" -> result.success(
                isGattConnected && gatt != null && writeCharacteristic != null
            )
            else -> result.notImplemented()
        }
    }

    private fun scan(targetAddress: String?, result: MethodChannel.Result) {
        Log.i(logTag, "Starting compatible BLE printer scan" + (targetAddress?.let { " (target $it)" } ?: ""))
        if (pendingScanResult != null) {
            result.error("BLE_SCAN_BUSY", "A BLE printer scan is already running.", null)
            return
        }
        val scanner = adapter?.bluetoothLeScanner
        if (adapter?.isEnabled != true || scanner == null) {
            result.error("BLE_OFF", "Bluetooth is turned off or BLE is unavailable.", null)
            return
        }
        scannedDevices.clear()
        pendingScanResult = result
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, scanResult: ScanResult) {
                scannedDevices[scanResult.device.address] = scanResult.device
                Log.i(logTag, "Found ${scanResult.device.name} at ${scanResult.device.address}")
                // Once we've re-spotted the printer we already know, there's no need to
                // keep listening out the full scan window before connecting to it — that
                // was adding several seconds of pure wait to every print.
                if (targetAddress != null && scanResult.device.address == targetAddress) {
                    finishScan(null)
                }
            }

            override fun onBatchScanResults(results: MutableList<ScanResult>) {
                results.forEach { scannedDevices[it.device.address] = it.device }
                if (targetAddress != null && scannedDevices.containsKey(targetAddress)) {
                    finishScan(null)
                }
            }

            override fun onScanFailed(errorCode: Int) {
                finishScan(errorCode)
            }
        }
        scanCallback = callback
        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(serviceUuid))
            .build()
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()
        scanner.startScan(listOf(filter), settings, callback)
        handler.postDelayed({ finishScan(null) }, scanDurationMs)
    }

    private fun finishScan(errorCode: Int?) {
        val result = pendingScanResult ?: return
        scanCallback?.let { adapter?.bluetoothLeScanner?.stopScan(it) }
        scanCallback = null
        pendingScanResult = null
        if (errorCode != null) {
            result.error("BLE_SCAN_FAILED", "BLE scan failed with code $errorCode.", null)
            return
        }
        result.success(
            scannedDevices.values.map { device ->
                mapOf(
                    "name" to (device.name ?: "BLE Printer"),
                    "address" to device.address
                )
            }
        )
        Log.i(logTag, "BLE scan completed with ${scannedDevices.size} result(s)")
    }

    private fun connect(address: String, result: MethodChannel.Result) {
        if (address.isBlank()) {
            result.error("BLE_ADDRESS_MISSING", "BLE printer address is missing.", null)
            return
        }
        if (pendingConnectResult != null) {
            result.error("BLE_CONNECT_BUSY", "A BLE connection is already in progress.", null)
            return
        }
        if (
            isGattConnected &&
            gatt != null &&
            writeCharacteristic != null &&
            connectedAddress == address
        ) {
            Log.i(logTag, "Reusing active BLE connection to $address")
            result.success(true)
            return
        }
        Log.i(logTag, "Connecting to BLE printer $address")
        disconnect()
        pendingConnectResult = result
        val device = try {
            adapter?.getRemoteDevice(address)
        } catch (error: IllegalArgumentException) {
            null
        }
        if (device == null) {
            completeConnect(false, "The BLE printer address is invalid.")
            return
        }
        connectedAddress = address
        gatt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            device.connectGatt(activity, false, gattCallback, BluetoothDevice.TRANSPORT_LE)
        } else {
            device.connectGatt(activity, false, gattCallback)
        }
        handler.postDelayed({
            if (pendingConnectResult != null) {
                completeConnect(false, "Timed out connecting to the BLE printer.")
            }
        }, connectTimeoutMs)
    }

    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            handler.post {
                if (gatt !== this@BlePrinterBridge.gatt) {
                    gatt.close()
                    return@post
                }
                Log.i(logTag, "GATT state status=$status newState=$newState")
                if (status != BluetoothGatt.GATT_SUCCESS) {
                    isGattConnected = false
                    completeConnect(false, "BLE connection failed with GATT status $status.")
                } else if (newState == BluetoothProfile.STATE_CONNECTED) {
                    isGattConnected = true
                    gatt.discoverServices()
                } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                    isGattConnected = false
                    if (pendingConnectResult != null) {
                        completeConnect(false, "The BLE printer disconnected during setup.")
                    } else {
                        writeCharacteristic = null
                        completeWrite(false, "The BLE printer disconnected.")
                    }
                }
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            handler.post {
                if (gatt !== this@BlePrinterBridge.gatt) return@post
                if (status != BluetoothGatt.GATT_SUCCESS) {
                    completeConnect(false, "Could not discover BLE printer services.")
                    return@post
                }
                val service: BluetoothGattService? = gatt.getService(serviceUuid)
                val characteristic = service?.getCharacteristic(writeUuid)
                if (characteristic == null) {
                    completeConnect(false, "The device is not a compatible Softverse BLE printer.")
                    return@post
                }
                writeCharacteristic = characteristic
                // Most BLE printer modules on this UART-style service only expose
                // "write without response" — forcing WRITE_TYPE_DEFAULT on those
                // makes every writeCharacteristic() call fail immediately.
                writeType = if (
                    characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE != 0
                ) {
                    BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
                } else {
                    BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
                }
                Log.i(logTag, "Softverse BLE write characteristic discovered")
                // Issuing a write while an MTU renegotiation is still in flight makes
                // several Android BLE stacks (Samsung's included) silently swallow the
                // write and eventually drop the link. Hold the "connected" result until
                // onMtuChanged fires (or this fallback timeout elapses) so the first
                // print job never races the MTU exchange.
                if (gatt.requestMtu(247)) {
                    handler.postDelayed({ finishMtuWait() }, mtuWaitTimeoutMs)
                } else {
                    completeConnect(true, null)
                }
            }
        }

        override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
            handler.post {
                if (gatt !== this@BlePrinterBridge.gatt) return@post
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    negotiatedPayloadSize = (mtu - 3).coerceIn(20, 244)
                }
                finishMtuWait()
            }
        }

        @Deprecated("Deprecated in Android 13")
        override fun onCharacteristicWrite(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            status: Int
        ) {
            handler.post {
                if (gatt !== this@BlePrinterBridge.gatt) return@post
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    writeNextChunk()
                } else {
                    completeWrite(false, "BLE write failed with GATT status $status.")
                }
            }
        }
    }

    private fun finishMtuWait() {
        if (pendingConnectResult == null) return
        completeConnect(true, null)
    }

    private fun completeConnect(success: Boolean, message: String?) {
        val result = pendingConnectResult ?: return
        pendingConnectResult = null
        if (success) {
            result.success(true)
        } else {
            disconnectGattOnly()
            result.error("BLE_CONNECT_FAILED", message ?: "Could not connect.", null)
        }
    }

    private fun writeBytes(arguments: Any?, result: MethodChannel.Result) {
        if (pendingWriteResult != null) {
            result.error("BLE_WRITE_BUSY", "A BLE print job is already being sent.", null)
            return
        }
        val values = arguments as? List<*>
        if (values == null || values.isEmpty()) {
            result.error("BLE_DATA_MISSING", "The BLE print job is empty.", null)
            return
        }
        if (gatt == null || writeCharacteristic == null) {
            result.error("BLE_NOT_CONNECTED", "Connect the BLE printer before printing.", null)
            return
        }
        writeQueue.clear()
        val bytes = ByteArray(values.size) { index ->
            ((values[index] as Number).toInt() and 0xff).toByte()
        }
        bytes.asList().chunked(negotiatedPayloadSize).forEach { chunk ->
            writeQueue.add(chunk.toByteArray())
        }
        pendingWriteResult = result
        Log.i(logTag, "Sending ${bytes.size} ESC/POS bytes over BLE")
        writeNextChunk()
    }

    private fun writeNextChunk() {
        val currentGatt = gatt
        val characteristic = writeCharacteristic
        if (currentGatt == null || characteristic == null) {
            completeWrite(false, "The BLE printer is no longer connected.")
            return
        }
        val chunk = writeQueue.pollFirst()
        if (chunk == null) {
            completeWrite(true, null)
            return
        }
        val started = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            currentGatt.writeCharacteristic(
                characteristic,
                chunk,
                writeType
            ) == android.bluetooth.BluetoothStatusCodes.SUCCESS
        } else {
            @Suppress("DEPRECATION")
            characteristic.writeType = writeType
            @Suppress("DEPRECATION")
            characteristic.value = chunk
            @Suppress("DEPRECATION")
            currentGatt.writeCharacteristic(characteristic)
        }
        if (!started) {
            completeWrite(false, "Android could not start the BLE write.")
        }
    }

    private fun completeWrite(success: Boolean, message: String?) {
        val result = pendingWriteResult ?: return
        pendingWriteResult = null
        writeQueue.clear()
        if (success) {
            result.success(true)
        } else {
            result.error("BLE_WRITE_FAILED", message ?: "Could not send BLE data.", null)
        }
    }

    private fun disconnectGattOnly() {
        isGattConnected = false
        writeCharacteristic = null
        val previousGatt = gatt
        gatt = null
        connectedAddress = null
        previousGatt?.disconnect()
        previousGatt?.close()
    }

    private fun disconnect() {
        completeWrite(false, "The BLE printer was disconnected.")
        disconnectGattOnly()
    }

    fun dispose() {
        finishScan(null)
        disconnect()
        channel.setMethodCallHandler(null)
    }
}
