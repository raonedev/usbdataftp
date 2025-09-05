import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../../core/helper.dart';
class StartUpAppProvider extends ChangeNotifier {
  static const Duration _retryDelay = Duration(seconds: 3);

  // ---- USB Tethering & IP Detection State ----
  bool _isUsbTethering = false;
  bool get isUsbTethering => _isUsbTethering;

  bool _isMobileTetheringIpFound = false;
  bool get isMobileTetheringIpFound => _isMobileTetheringIpFound;

  String? _mobileTetheringIp;
  String? get mobileTetheringIP => _mobileTetheringIp;

  bool _isDeviceTethering = false;
  bool get isDeviceTethering => _isDeviceTethering;

  String? _deviceTetheringIP;
  String? get deviceTetheringIP => _deviceTetheringIP;
  bool _isInitializing = false;
  bool _disposed = false;

  Future<void> initialized() async {
    if (_disposed || _isInitializing) return;

    _isInitializing = true;
    try {
      await _initializeConnection();
    } catch (e, s) {
      dev.log("Exception during initialization", error: e, stackTrace: s);
    } finally {
      _isInitializing = false;
    }
  }

  /// Private method to handle the connection initialization logic
  Future<void> _initializeConnection() async {
    while (!_isDeviceTethering && !_disposed) {
      try {
        // Step 1: Detect mobile tethering IP
        if (!await _detectMobileTetheringIP()) {
          await _waitBeforeRetry();
          continue;
        }

        // Step 2: Find device IP
        if (!await _findDeviceIP()) {
          await _waitBeforeRetry();
          continue;
        }

        break; 
      } catch (e, s) {
        dev.log("Connection attempt failed", error: e, stackTrace: s);
        await _waitBeforeRetry();
      }
    }
  }

  /// Detects mobile tethering IP
  Future<bool> _detectMobileTetheringIP() async {
    _mobileTetheringIp = await getTetheringMobileIP();

    if (_mobileTetheringIp != null) {
      _updateTetheringState(
        isUsbTethering: true,
        isMobileTetheringIpFound: true,
      );
      dev.log("Mobile tethering IP found: $_mobileTetheringIp");
      return true;
    } else {
      _updateTetheringState(
        isUsbTethering: false,
        isMobileTetheringIpFound: false,
        isDeviceTethering: false,
      );
      dev.log("Mobile tethering not active");
      return false;
    }
  }

  /// Finds device (PC) IP
  Future<bool> _findDeviceIP() async {
    // Try previous known IP first
    if (_deviceTetheringIP != null) {
      final validIP = await pingSingleIp(_deviceTetheringIP!);
      if (validIP != null) {
        _deviceTetheringIP = validIP;
        dev.log("Previous device IP still valid: $_deviceTetheringIP");
        _isDeviceTethering = true;
        notifyListeners();
        return true;
      }
    }

    // Discover new IP by pinging subnet
    _deviceTetheringIP = await findPcIpByPingSubnet(_mobileTetheringIp!);

    if (_deviceTetheringIP != null) {
      _isDeviceTethering = true;
      notifyListeners();
      dev.log("Device IP found: $_deviceTetheringIP");
      return true;
    } else {
      _isDeviceTethering = false;
      notifyListeners();
      dev.log("Device IP not found");
      return false;
    }
  }

  /// Updates tethering state and notifies listeners
  void _updateTetheringState({
    bool? isUsbTethering,
    bool? isMobileTetheringIpFound,
    bool? isDeviceTethering,
  }) {
    bool shouldNotify = false;

    if (isUsbTethering != null && _isUsbTethering != isUsbTethering) {
      _isUsbTethering = isUsbTethering;
      shouldNotify = true;
    }

    if (isMobileTetheringIpFound != null &&
        _isMobileTetheringIpFound != isMobileTetheringIpFound) {
      _isMobileTetheringIpFound = isMobileTetheringIpFound;
      shouldNotify = true;
    }

    if (isDeviceTethering != null && _isDeviceTethering != isDeviceTethering) {
      _isDeviceTethering = isDeviceTethering;
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Waits before retrying connection
  Future<void> _waitBeforeRetry() async {
    dev.log("Retrying connection in ${_retryDelay.inSeconds} seconds...");
    await Future.delayed(_retryDelay);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
