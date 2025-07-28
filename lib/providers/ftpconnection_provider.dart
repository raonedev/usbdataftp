import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usbdataftptest/helper.dart';
import 'package:usbdataftptest/models/dashboard_model.dart';

class FtpConnectionProvider extends ChangeNotifier {

  int _count =0;
  int get count =>_count;

  bool _isChecking = false;
  bool get isChecking => _isChecking;

  bool _isDialogVisible = false;
  bool get isDialogVisible => _isDialogVisible;
  set isDialogVisible(bool value) {
    _isDialogVisible = value;
    notifyListeners();
  }

  String? _deviceIp;
  String? _mobileTetheringIP;

  Timer? _tetheringTimer;
  StreamSubscription? _ftpSub;

  DashboardModel? _fileData;
  DashboardModel? get filedata => _fileData;

  final Map<String, String> _ipCache = {};

  Future<void> poolingToKnowUSBStatus({required BuildContext context}) async {
    _tetheringTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _count++;
      connectingWithFTPServerAndGetData(context: context);
    });
    connectingWithFTPServerAndGetData(context: context);
  }

  Future<void> connectingWithFTPServerAndGetData({required BuildContext context}) async {
    if (_isChecking) return;
    _isChecking = true;
    notifyListeners();
    try {
      _mobileTetheringIP = await getTetheringMobileIP();
      if (_mobileTetheringIP == null) {
        if (!_isDialogVisible) {
          isDialogVisible = true;
          // Let UI display dialog when this flag is true
        }
        _isChecking = false;
        notifyListeners();
        return;
      }
      if (_isDialogVisible) {
        _isDialogVisible = false; // Close dialog if tethering started
        notifyListeners();
      }

      log("Tethering IP Found: $_mobileTetheringIP");
       ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tethering IP Found: $_mobileTetheringIP"))
    );

      // Continue with initialization once tethering is available
      log("Tethering IP Found: $_mobileTetheringIP");
      // _deviceIp = await findPcIpByPingSubnet(_mobileTetheringIP!);
      // Check in cache first
      if (_ipCache.containsKey(_mobileTetheringIP)) {
        _deviceIp = _ipCache[_mobileTetheringIP];
        log("Found IP in cache: $_deviceIp");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("finding device ip"))
    );
        _deviceIp = await findPcIpByPingSubnet(_mobileTetheringIP!);
        if (_deviceIp != null) {
          _ipCache[_mobileTetheringIP!] = _deviceIp!;
          log("New IP found and cached: $_deviceIp");
        }
      }
      await _ftpSub?.cancel();
      _ftpSub = null;
      if (_deviceIp != null) {
         ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("device ip found $_deviceIp"))
    );
        _ftpSub = getFtpFileStream(hostIp: _deviceIp!,context: context).listen((jsonData) {
          if (jsonData != null) {
            // log("Received JSON: $jsonData");
            _fileData = DashboardModel.fromMap(jsonData);
            notifyListeners();
          } else {
            log("No data received or error occurred");
          }
        });
      }
    } catch (err, strc) {
      log("Exception in getting tethering ip", error: err, stackTrace: strc);
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> checkingTempData() async {
    _isChecking = true;
    notifyListeners();
    final String response = await rootBundle.loadString('assets/abc.json');
    final Map<String, dynamic> data = json.decode(response);
    _fileData = DashboardModel.fromMap(data);
    log(_fileData.toString());
    _isChecking = false;
    notifyListeners();
  }

  Future<void> disposeProvider() async {
    _tetheringTimer?.cancel();
    _ipCache.clear();
    _ftpSub?.cancel();
  }
}


 // _isChecking = true;
      // _mobileTetheringIP = await getTetheringMobileIP();

      // while (_mobileTetheringIP == null) {
      //   _mobileTetheringIP = await getTetheringMobileIP();
      //   if (_mobileTetheringIP == null && !_isDialogVisible) {
      //     _isDialogVisible = true;
      //     notifyListeners();
      //     //  await showCustomAlertDialog(
      //     //   context,
      //     //   title: "USB Tethering not found!",
      //     //   message:
      //     //       'Please connect USB with device\nthen turn on USB Tethering',
      //     //   confirmText: "Open Settings",
      //     //   onConfirm: () {
      //     //     openUsbTetherSettings();
      //     //     _isDialogVisible = false;
      //     //   },
      //     // );
      //   }
      // }