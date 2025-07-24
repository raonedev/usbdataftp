import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

class FtpDemoScreen extends StatefulWidget {
  const FtpDemoScreen({super.key});

  @override
  State<FtpDemoScreen> createState() => _FtpDemoScreenState();
}

class _FtpDemoScreenState extends State<FtpDemoScreen> {
  String _logMessage = '';
  late FTPConnect ftpConnect;
  Future<String?> getGatewayIpFromNative() async {
    const platform = MethodChannel('com.example.usbdataftptest/network');
    try {
      final String? ip = await platform.invokeMethod('getGatewayIp');
      log(ip.toString());
      setState(() {
        _logMessage = ip.toString();
      });
      return ip;
    } on PlatformException catch (e) {
      log("Failed to get IP: ${e.message}");
      setState(() {
        _logMessage = "Failed to get IP: ${e.message}";
      });
      return null;
    }
  }

  Future<void> openUsbTetherSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.TETHER_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  Future<String?> pingSubnet(String androidIp) async {
    final parts = androidIp.split('.');
    if (parts.length != 4) return null;

    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    const batchSize = 10;

    // Function to ping a single IP
    Future<String?> pingSingleIp(String ip) async {
      final ping = Ping(ip, count: 1, timeout: 1);
      try {
        await for (final PingData data in ping.stream) {
          if (data.response != null) {
            log(
              '✅ Host $ip responded: time=${data.response!.time?.inMilliseconds}ms',
            );
            setState(() {
              _logMessage =
                  "✅ Host $ip responded: time=${data.response!.time?.inMilliseconds}ms";
            });
            return ip;
          } else if (data.error != null) {
            log('❌ $ip error: ${data.error}');
            setState(() {
              _logMessage = "❌ $ip error: ${data.error}";
            });
          }
        }
        log('❌ No ping response from $ip');
        setState(() {
          _logMessage = "❌ No ping response from $ip";
        });
        return null;
      } catch (e) {
        log('❌ $ip error: $e');
        setState(() {
          _logMessage = "❌ $ip error: $e";
        });
        return null;
      }
    }

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

  Future<String?> getHostIp(BuildContext context) async {
    final phoneHostApi = await getGatewayIpFromNative();
    if (phoneHostApi == null) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enable USB Tethering'),
            content: const Text(
              'Connect usb to your phone and device '
              'Look for a toggle labeled "USB tethering" and turn it on.',
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  await openUsbTetherSettings();
                  Navigator.pop(context);
                  // await Future.delayed(const Duration(seconds: 1));
                },
              ),
            ],
          );
        },
      ).then((value) {
        getHostIp(context);
      });
    } else {
      final hostIp = await pingSubnet(phoneHostApi);
      if (hostIp != null) {
        log("device ip is $hostIp");
        setState(() {
          _logMessage = "device ip is $hostIp";
        });
        return hostIp;
      } else {
        log("device ip not found");
        setState(() {
          _logMessage = "device ip not found";
        });

        return null;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    /// python3 -m pyftpdlib -i 192.168.42.129 -p 2121
    /// sudo lsof -i -P -n | grep LISTEN | grep 2121
    ///
    initializedApp();
  }

  Future<void> initializedApp() async {
    final String? hostIp = await getHostIp(context);
    if (hostIp != null) {
      ftpConnect = FTPConnect(
        hostIp,
        user: 'anonymous',
        pass: '',
        port: 2121,
        showLog: true,
      );

      try {
        await ftpConnect.connect();
        log("Connected to FTP server");
        setState(() {
          _logMessage = "Connected to FTP server";
        });
        bool isFileExist = await ftpConnect.existFile('abc.json');
        setState(() {
          _logMessage = "file existance : ${isFileExist.toString()}";
        });

        if (isFileExist) {
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

              setState(() {
                _logMessage = "File content: $fileContents";
              });
            } else {
              setState(() {
                _logMessage = "Failed to download file.";
              });
            }
          });
        }
      } catch (e, s) {
        log("Error: ", error: e, stackTrace: s);
        setState(() {
          _logMessage = "Error $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("testing it\n $_logMessage"),
          ElevatedButton(
            onPressed: () async {
              await initializedApp();
            },
            child: Text("initialized again"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ftpConnect.disconnect();
              log("Disconnected");
            },
            child: Text("Disconnect"),
          ),
        ],
      ),
    );
  }
}
