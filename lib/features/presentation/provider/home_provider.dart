import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../../core/helper.dart';
// import '../../data/models/dashboard_new_model.dart';

/// Represents the different states of the login process.
enum LoginState { loading, loginSuccess, loginFailed, noLogin }

/// Represents the different states of the ftp connection
enum FtpConnectionState { loading, success, failed, none }

/// LoginProvider manages:
/// 1. USB tethering status.
/// 2. IP detection of mobile and PC.
/// 3. FTP connection and file stream.
/// 4. Login validation and UI state updates.
class StartUpAppProvider extends ChangeNotifier {
  /// Describes the overall flow:
  /// USB detected -> USB tethering enabled -> Device IP found -> FTP connection -> Data retrieval.

  // ---- Constants ----
  // static const String _ftpUsername = 'myuser';
  // static const String _ftpPassword = 'mypassword';
  // static const int _ftpPort = 2121;
  // static const String _ftpFileName = 'system_status.json';
  // static const String _fallbackFileName = 'abc.json';
  static const Duration _retryDelay = Duration(seconds: 3);
  // static const Duration _pollingInterval = Duration(seconds: 3);
  // static const String _adminUsername = 'admin';
  // static const String _adminPassword = 'admin123';

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

  // ---- FTP Connection State ----
  // bool _isFTPConnected = false;
  // bool get isFTPConnected => _isFTPConnected;


  // FTPConnect? _ftpConnect;
  // StreamSubscription? _ftpSubscription;
  // Timer? _reconnectionTimer;


  // ---- Login State ----
  // LoginState _loginState = LoginState.noLogin;
  // LoginState get loginState => _loginState;

  // String? _loginErrorMessage;
  // String? get loginErrorMessage => _loginErrorMessage;

  // --- Ftp connection State ---
  // FtpConnectionState _ftpConnectionState = FtpConnectionState.none;
  // FtpConnectionState get ftpConnectionState => _ftpConnectionState;

  // String? _ftpErrorMessage;
  // String? get ftpErrorMessage => _ftpErrorMessage;

  // Flag to prevent concurrent initialization attempts
  bool _isInitializing = false;
  bool _disposed = false;

  // DashboardNewModel? _fileData;
  // DashboardNewModel? get filedata => _fileData;

  /// Initializes the tethering and FTP connection process.
  Future<void> initialized() async {
    if (_disposed || _isInitializing) return;

    _isInitializing = true;
    // _clearErrorMessages();
    try {
      await _initializeConnection();
    } catch (e, s) {
      dev.log("Exception during initialization", error: e, stackTrace: s);
      // _handleConnectionError("Initialization failed: ${e.toString()}");
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

        // Step 3: Establish FTP connection
        // if (!await _establishFTPConnection()) {
        //   await _waitBeforeRetry();
        //   continue;
        // }
        // Step 4: Start data polling
        // _startDataPolling();
        break; // Success - exit retry loop
      } catch (e, s) {
        dev.log("Connection attempt failed", error: e, stackTrace: s);
        // _handleConnectionError(e.toString());
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

  /// Establishes FTP connection
  // Future<bool> _establishFTPConnection() async {
  //   _ftpConnect = FTPConnect(
  //     _deviceTetheringIP!,
  //     user: _ftpUsername,
  //     pass: _ftpPassword,
  //     port: _ftpPort,
  //     showLog: true,
  //   );
  //   try {
  //     _updateFTPState(FtpConnectionState.loading);
  //     final connected = await _ftpConnect!.connect();
  //     if (connected) {
  //       _isFTPConnected = true;
  //       _updateFTPState(FtpConnectionState.success, clearError: true);
  //       dev.log("FTP connected to $_deviceTetheringIP");
  //       return true;
  //     } else {
  //       _handleFTPConnectionFailure("FTP connection rejected");
  //       return false;
  //     }
  //   } catch (e, s) {
  //     dev.log("FTP connection failed", error: e, stackTrace: s);
  //     _handleFTPConnectionFailure(
  //       "Failed to establish FTP connection: ${e.toString()}",
  //     );
  //     return false;
  //   }
  // }

  /// Starts data polling from FTP
  // void _startDataPolling() {
  //   _ftpSubscription?.cancel();
  //   _ftpSubscription = _getFtpFileStreamData().listen(
  //     _handleFTPData,
  //     onError: _handleFTPStreamError,
  //     onDone: _handleFTPStreamDone,
  //   );
  // }

  /// Handles FTP data reception
  // void _handleFTPData(Map<String, dynamic>? jsonData) {
  //   if (_disposed) return;
  //   if (jsonData == null) {
  //     dev.log("Null JSON received from FTP, restarting connection...");
  //     _reconnectFTP();
  //   } else {
  //     try {
  //       _fileData = DashboardNewModel.fromMap(jsonData);
  //       notifyListeners();
  //       dev.log("Data successfully parsed and updated");
  //     } catch (e, s) {
  //       dev.log("Error parsing JSON data", error: e, stackTrace: s);
  //       _handleConnectionError("Data parsing error: ${e.toString()}");
  //     }
  //   }
  // }

  /// Handles FTP stream errors
  // void _handleFTPStreamError(dynamic error, StackTrace stackTrace) {
  //   dev.log("FTP stream error", error: error, stackTrace: stackTrace);
  //   _reconnectFTP();
  // }

  /// Handles FTP stream completion
  // void _handleFTPStreamDone() {
  //   dev.log("FTP stream completed");
  //   _reconnectFTP();
  // }

  /// Reconnects FTP after a delay
  // void _reconnectFTP() {
  //   if (_disposed) return;
  //   _cleanupFTPConnection();
  //   _reconnectionTimer?.cancel();
  //   _reconnectionTimer = Timer(_retryDelay, () {
  //     if (!_disposed) {
  //       initialized();
  //     }
  //   });
  // }

  /// Creates a stream that periodically fetches JSON data from FTP
  // Stream<Map<String, dynamic>?> _getFtpFileStreamData() async* {
  //   if (_ftpConnect == null || _disposed) return;
  //   try {
  //     final dir = await getTemporaryDirectory();
  //     final filePath = '${dir.path}/$_ftpFileName';
  //     final file = File(filePath);
  //     // Check if file exists on FTP server
  //     if (!await _ftpConnect!.existFile(_ftpFileName)) {
  //       dev.log("File $_ftpFileName not found on FTP server");
  //       yield null;
  //       return;
  //     }
  //     // Start polling
  //     while (_isFTPConnected && !_disposed) {
  //       try {
  //         final downloaded = await _ftpConnect!.downloadFile(
  //           _ftpFileName,
  //           file,
  //         );
  //         if (downloaded && await file.exists()) {
  //           final fileContents = await file.readAsString();
  //           final decodedJson = jsonDecode(fileContents);
  //           yield decodedJson;
  //         } else {
  //           dev.log("Download failed for $_ftpFileName");
  //           yield null;
  //           break;
  //         }
  //       } catch (e, s) {
  //         dev.log("Error during FTP file polling", error: e, stackTrace: s);
  //         yield null;
  //         break;
  //       }
  //       await Future.delayed(_pollingInterval);
  //     }
  //   } catch (e, s) {
  //     dev.log("Exception in FTP file stream", error: e, stackTrace: s);
  //     yield null;
  //   }
  // }

  /// Validates login credentials
  // Future<void> loginSubmit() async {
  //   if (_disposed) return;
  //   _updateLoginState(LoginState.loading);
  //   try {
  //     await Future.delayed(
  //       const Duration(milliseconds: 500),
  //     ); // Simulate network delay
  //     final username = _usernameController.text.trim();
  //     final password = _passwordController.text.trim();
  //     if (_validateCredentials(username, password)) {
  //       _updateLoginState(LoginState.loginSuccess, clearError: true);
  //       _updateFTPState(FtpConnectionState.none);
  //       dev.log("Login successful");
  //     } else {
  //       _updateLoginState(
  //         LoginState.loginFailed,
  //         errorMessage: "Incorrect username or password",
  //       );
  //       dev.log("Login failed: Invalid credentials");
  //     }
  //   } catch (e, s) {
  //     dev.log("Exception during login", error: e, stackTrace: s);
  //     _updateLoginState(
  //       LoginState.loginFailed,
  //       errorMessage: "Something went wrong during login",
  //     );
  //   }
  // }

  /// Validates user credentials
  // bool _validateCredentials(String username, String password) {
  //   return username.isNotEmpty &&
  //       password.isNotEmpty &&
  //       username == _adminUsername &&
  //       password == _adminPassword;
  // }

  /// Loads temporary test data from assets
  // Future<void> checkingTempData() async {
  //   if (_disposed) return;
  //   try {
  //     final String response = await rootBundle.loadString('assets/abc2.json');
  //     final Map<String, dynamic> data = json.decode(response);
  //     _fileData = DashboardNewModel.fromMap(data);
  //     notifyListeners();
  //     dev.log("Temporary data loaded successfully");
  //   } catch (e, s) {
  //     dev.log("Error loading temporary data", error: e, stackTrace: s);
  //   }
  // }

  // ---- Helper Methods ----

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

  /// Updates login state and notifies listeners
  // void _updateLoginState(
  //   LoginState newState, {
  //   String? errorMessage,
  //   bool clearError = false,
  // }) {
  //   _loginState = newState;
  //   if (clearError) {
  //     _loginErrorMessage = null;
  //   } else if (errorMessage != null) {
  //     _loginErrorMessage = errorMessage;
  //   }
  //   notifyListeners();
  // }

  /// Updates FTP state and notifies listeners
  // void _updateFTPState(
  //   FtpConnectionState newState, {
  //   String? errorMessage,
  //   bool clearError = false,
  // }) {
  //   _ftpConnectionState = newState;
  //   if (clearError) {
  //     _ftpErrorMessage = null;
  //   } else if (errorMessage != null) {
  //     _ftpErrorMessage = errorMessage;
  //   }
  //   notifyListeners();
  // }

  /// Handles FTP connection failures
  // void _handleFTPConnectionFailure(String errorMessage) {
  //   _isFTPConnected = false;
  //   _updateFTPState(FtpConnectionState.failed, errorMessage: errorMessage);
  // }

  /// Handles general connection errors
  // void _handleConnectionError(String errorMessage) {
  //   _updateFTPState(FtpConnectionState.failed, errorMessage: errorMessage);
  // }

  /// Clears error messages
  // void _clearErrorMessages() {
  //   _ftpErrorMessage = null;
  //   _loginErrorMessage = null;
  // }

  /// Waits before retrying connection
  Future<void> _waitBeforeRetry() async {
    dev.log("Retrying connection in ${_retryDelay.inSeconds} seconds...");
    await Future.delayed(_retryDelay);
  }

  /// Cleans up FTP connection resources
  // void _cleanupFTPConnection() {
  //   _ftpSubscription?.cancel();
  //   _ftpSubscription = null;
  //   _isFTPConnected = false;

  //   _ftpConnect?.disconnect().catchError((e) {
  //     dev.log("Error disconnecting FTP", error: e);
  //   });
  //   _ftpConnect = null;
  // }

  /// Cleans up all resources
  // void _cleanup() {
  //   _cleanupFTPConnection();
  //   _reconnectionTimer?.cancel();
  //   _reconnectionTimer = null;
  // }

  // ---- Public Methods ----

  /// Manually disconnects FTP and resets connection state
  // Future<void> disconnect() async {
  //   _cleanup();
  //   _updateFTPState(FtpConnectionState.none, clearError: true);
  //   _updateTetheringState(
  //     isUsbTethering: false,
  //     isMobileTetheringIpFound: false,
  //     isDeviceTethering: false,
  //   );
  // }

  /// Logs out user and cleans up
  // void logout() {
  //   // _updateLoginState(LoginState.noLogin, clearError: true);
  //   // _usernameController.clear();
  //   // _passwordController.clear();
  //   disconnect();
  // }

  @override
  void dispose() {
    _disposed = true;
    // _cleanup();
    // _usernameController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }
}
