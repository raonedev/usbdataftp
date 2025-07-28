import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

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
    log('❌ No ping response from $ip');

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
  const batchSize = 10;

  // Process IPs in batches
  for (int i = 1; i <= 255; i += batchSize) {
    // Calculate the end index for the current batch
    final endIndex = (i + batchSize - 1).clamp(1, 255);
    // Create a batch of IPs to ping
    final batchIps = List.generate(
      endIndex - i + 1,
      (index) => '$subnet.${i + index}',
      growable: false,
    );

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

Future<String?> getFileByMakingFTPConnection({required String hostIp}) async {
  final ftpConnect = FTPConnect(
    hostIp,
    user: 'anonymous',
    pass: '',
    port: 2121,
    showLog: true,
  );

  try {
    await ftpConnect.connect();
    log("Connected to FTP server");

    /// checking if file exist
    bool isFileExist = await ftpConnect.existFile('abc.json');
    if (!isFileExist) {
      throw Exception("File is not Exist.");
    }

    Timer.periodic(Duration(seconds: 2), (timer) async {
      // Get a temporary directory to store the file
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/abc.json';
      final file = File(filePath);

      // Download the file
      bool downloaded = await ftpConnect.downloadFile('abc.json', file);
      if (downloaded) {
        final fileContents = await file.readAsString();
        final decodedJson = jsonDecode(fileContents);
        return decodedJson;
      } else {
        throw Exception("Failed to getFile via FTP");
      }
    });
  } catch (e, s) {
    log("Exception occur while getting file", error: e, stackTrace: s);
  }
}

Stream<Map<String, dynamic>?> getFtpFileStream({
  required String hostIp,
  required BuildContext context,
}) async* {
  final ftpConnect = FTPConnect(
    hostIp,
    user: 'myuser',
    pass: 'mypassword',
    port: 2121,
    showLog: true,
  );

  try {
    await ftpConnect.connect();
    log("Connected to FTP server");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Connected to FTP server')));

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/abc.json';
    final file = File(filePath);

    // Check if file exists before streaming
    final isFileExist = await ftpConnect.existFile('abc.json');
    if (!isFileExist) {
      log("File not found on FTP server");
      yield null;
      await ftpConnect.disconnect();
      return;
    }

    // Start periodic fetch as stream
    while (true) {
      try {
        final downloaded = await ftpConnect.downloadFile('abc.json', file);
        if (downloaded) {
          final fileContents = await file.readAsString();
          final decodedJson = jsonDecode(fileContents);
          yield decodedJson;
        } else {
          log("Download failed");
          yield null;
        }
      } catch (e, s) {
        log("Error during FTP polling", error: e, stackTrace: s);
        yield null;
      }

      await Future.delayed(Duration(seconds: 2));
    }
  } catch (e, s) {
    log("Exception while connecting FTP", error: e, stackTrace: s);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
    yield null;
  }
}
