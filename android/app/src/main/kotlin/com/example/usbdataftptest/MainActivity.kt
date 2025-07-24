package com.example.usbdataftptest

import android.content.Context
import android.net.ConnectivityManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.NetworkInterface // Import NetworkInterface
import android.util.Log // Import Log
import io.flutter.plugin.common.EventChannel
import java.util.*
import kotlin.concurrent.fixedRateTimer

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.usbdataftptest/network"
    private val EVENT_CHANNEL = "com.example.usbdataftptest/networkEvents"
    private var timer: Timer? = null
    private var lastIp: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGatewayIp") {
                val gatewayIp = getGatewayIp()
                if (gatewayIp != null) {
                    result.success(gatewayIp)
                } else {
                    result.error("UNAVAILABLE", "Gateway IP not found", null)
                }
            } else {
                result.notImplemented()
            }
        }

         EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    timer = fixedRateTimer("tetheringCheck", true, 0, 2000) {
                        val ip = getGatewayIp()
                        if (ip != lastIp) {
                            lastIp = ip
                            events.success(ip ?: null)
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    timer?.cancel()
                    timer = null
                }
            }
        )
    }

     private fun getGatewayIp(): String? {
        // val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        // val activeNetwork = connectivityManager.activeNetwork ?: return null
        // val linkProperties = connectivityManager.getLinkProperties(activeNetwork) ?: return null

        // for (route in linkProperties.routes) {
        //     if (route.isDefaultRoute && route.gateway != null) {
        //         return route.gateway?.hostAddress
        //     }
        // }
        // return null
         return getUsbTetheredIp()
    }

    private fun getUsbTetheredIp(): String? {
        val interfaces = NetworkInterface.getNetworkInterfaces()
        Log.d("DEBUG", "Available interfaces:")
        for (iface in interfaces) {
            Log.d("DEBUG", "Interface: ${iface.name}")
            val name = iface.name
            if (name.contains("rndis") || name.contains("usb")) {  // <- RNDIS or USB tethering
                val addresses = iface.inetAddresses
                while (addresses.hasMoreElements()) {
                    val addr = addresses.nextElement()
                    if (!addr.isLoopbackAddress && addr.hostAddress.indexOf(':') < 0) {
                        return addr.hostAddress  // Return IPv4
                    }
                }
            }
        }
        return null
    }
}
