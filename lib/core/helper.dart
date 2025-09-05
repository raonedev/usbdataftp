import 'dart:async';
import 'dart:developer';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Shows a Cupertino-style alert dialog.
///
/// Example:
/// ```dart
/// showCustomAlertDialog(
///   context,
///   title: 'Warning',
///   message: 'Do you want to proceed?',
///   onConfirm: () => print('Confirmed'),
/// );
/// ```
Future<void> showCustomAlertDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'OK',
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          if (cancelText != null)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            isDefaultAction: true,
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}

Future<void> openUsbTetherSettings() async {
  try {
    const intent = AndroidIntent(
      action: 'android.settings.TETHER_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  } catch (e) {
    log("Exception", error: e);
  }
}

Future<String?> getTetheringMobileIP() async {
  const platform = MethodChannel('com.example.usbdataftptest/network');
  try {
    final String? ip = await platform.invokeMethod('getGatewayIp');
    log(ip.toString());
    return ip;
  } on PlatformException catch (e) {
    log("Failed to get IP: ${e.message}");
    return null;
  }
}

// Function to ping a single IP
Future<String?> pingSingleIp(String ip) async {
  final ping = Ping(ip, count: 1, timeout: 1);
  try {
    await for (final PingData data in ping.stream) {
      if (data.response != null) {
        log(
          '✅ Host $ip responded: time=${data.response!.time?.inMilliseconds}ms',
        );
        return ip;
      } else if (data.error != null) {
        log('❌ $ip error: ${data.error}');
      }
    }
    // log('❌ No ping response from $ip');

    return null;
  } catch (e) {
    log('❌ $ip error: $e');
    return null;
  }
}

Future<String?> findPcIpByPingSubnet(String androidIp) async {
  final parts = androidIp.split('.');
  if (parts.length != 4) return null;

  final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
  const batchSize = 12;
  log("Finding IP ....;\tCurrent Batch size :$batchSize");
  // Process IPs in batches
  for (int i = 1; i <= 255; i += batchSize) {
    // Calculate the end index for the current batch
    final endIndex = (i + batchSize - 1).clamp(1, 255);
    // Create a batch of IPs to ping
    final batchIps = <String>[];
    for (int j = i; j <= endIndex; j++) {
      final ip = '$subnet.$j';
      if (ip == androidIp) continue;
      batchIps.add(ip);
    }

    // Ping all IPs in the batch concurrently
    final results = await Future.wait(
      batchIps.map((ip) => pingSingleIp(ip)),
      eagerError: true,
    );

    // Check if any IP in the batch responded
    for (final result in results) {
      if (result != null) {
        return result; // Return the first successful IP
      }
    }
  }

  return null; // No reachable host found
}


 Future<bool> checkPing({required String baseUrl}) async {
    try {
      final String ip = Uri.parse(baseUrl).host;
      return await pingSingleIp(ip) != null;
    } on FormatException {
      log('Error: Invalid URL format for baseUrl');
      return false;
    }
  }