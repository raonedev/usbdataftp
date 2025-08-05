import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/helper.dart';
import '../../data/models/dashboard_new_model.dart';


/// Represents the different states of the login process.
enum LoginState { loading, loginSucess, loginFailed, noLogin }

/// Represents the different states of the ftp connection
enum FtpConnectionState { loading, sucess, fialed, none }

/// LoginProvider manages:
/// 1. USB tethering status.
/// 2. IP detection of mobile and PC.
/// 3. FTP connection and file stream.
/// 4. Login validation and UI state updates.
class LoginProvider extends ChangeNotifier {
  /// Describes the overall flow:
  /// USB detected -> USB tethering enabled -> Device IP found -> FTP connection -> Data retrieval.

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
  bool _isFTPConnected = false;
  bool get isFTPConnected => _isFTPConnected;

  FTPConnect? _ftpConnect;
  StreamSubscription? _ftpSub;

  // ---- Login Controllers ----
  TextEditingController _usernameController = TextEditingController();
  TextEditingController get usernameController => _usernameController;
  set usernameController(TextEditingController value) {
    _usernameController = value;
    notifyListeners();
  }

  TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;
  set passwordController(TextEditingController value) {
    _passwordController = value;
    notifyListeners();
  }

  // ---- Login State ----
  LoginState _loginState = LoginState.noLogin;
  LoginState get loginState => _loginState;
  set loginState(LoginState value) {
    _loginState = value;
    notifyListeners();
  }

  String? _loginErrorMessage;
  String? get loginErrorMessage => _loginErrorMessage;

  // --- Ftp connection State ---
  FtpConnectionState _ftpConnectionState = FtpConnectionState.none;
  FtpConnectionState get ftpConnectionState => _ftpConnectionState;
  String? _ftpErrorMessage;
  String? get ftpErrorMessage=>_ftpErrorMessage;

  // Flag to prevent concurrent initialization attempts
  bool _isInitializing = false;

  DashboardNewModel? _fileData;
  DashboardNewModel? get filedata => _fileData;

  /// Initializes the tethering and FTP connection process.
  /// - Detects mobile tethering IP.
  /// - Pings or finds the device (PC) IP on the same subnet.
  /// - Establishes an FTP connection.
  /// - Listens for a JSON file periodically
  Future<void> initialized() async {
    if (_isInitializing || _isFTPConnected) return;
    _isInitializing = true;

    while (!_isFTPConnected) {
      _ftpErrorMessage=null;
      try {
        // Attempt to retrieve mobile device IP (via tethering).
        _mobileTetheringIp = await getTetheringMobileIP();
        if (_mobileTetheringIp != null) {
          _isUsbTethering = true;
          _isMobileTetheringIpFound = true;
          dev.log("tethering connected");
          notifyListeners();
          // If previous PC IP exists, try pinging to verify it's still valid.
          if (_deviceTetheringIP != null) {
            _deviceTetheringIP = await pingSingleIp(_deviceTetheringIP!);
            dev.log("Checked last known IP: $_deviceTetheringIP");
          }
          // If still null, discover the PC IP by pinging the subnet.
          _deviceTetheringIP ??= await findPcIpByPingSubnet(
            _mobileTetheringIp!,
          );

          if (_deviceTetheringIP != null) {
            _isDeviceTethering = true;
            notifyListeners();
            dev.log("Device (PC) IP found: $_deviceTetheringIP");
            // Setup FTP connection
            _ftpConnect = FTPConnect(
              _deviceTetheringIP!,
              user: 'myuser',
              pass: 'mypassword',
              port: 2121,
              showLog: true,
            );
            try {
              _ftpConnectionState = FtpConnectionState.loading;
              notifyListeners();
              final connected = await _ftpConnect!.connect();
              if (connected) {
                _isFTPConnected = true;
                _ftpConnectionState = FtpConnectionState.sucess;
                _ftpErrorMessage=null;
                notifyListeners();
                dev.log("FTP connected to $_deviceTetheringIP");
                // Start listening to FTP file stream
                _ftpSub = getFtpFileStreamData(ftpConnect: _ftpConnect!).listen(
                  (jsonData) async {
                    if (jsonData == null) {
                      // JSON file disappeared or became invalid — restart logic
                      dev.log("Null JSON received from FTP, restarting...");
                      await _ftpSub?.cancel();
                      _ftpSub = null;
                      _isFTPConnected = false;
                      notifyListeners();
                      // Retry safely without recursion
                      Future.microtask(() => initialized());
                    } else {
                      _fileData = DashboardNewModel.fromMap(jsonData);
                      notifyListeners();
                      dev.log("data found");
                    }
                  },
                );
                break; // Exit retry loop on successful connection
              } else {
                // Connection failed
                dev.log("FTP connection rejected.");
                _ftpConnectionState = FtpConnectionState.fialed;
                _ftpErrorMessage="Failed to fetching data.";
                _isFTPConnected = false;
                notifyListeners();
              }
            } catch (ftpError, ftpStack) {
              _ftpConnectionState = FtpConnectionState.fialed;
              _ftpErrorMessage="Failed to fetching data.";
              notifyListeners();
              dev.log(
                "FTP connection failed",
                error: ftpError,
                stackTrace: ftpStack,
              );
            }
          } else {
            // Device (PC) IP not found
            _isDeviceTethering = false;
            dev.log("Device tethering disconnected or not found.");
            notifyListeners();
          }
        } else {
          // USB Tethering not active
          _isUsbTethering = false;
          _isMobileTetheringIpFound = false;
          _isDeviceTethering = false;
          dev.log("usb tethering false");
          notifyListeners();
        }
      } catch (e, s) {
        dev.log("Exception during initialization", error: e, stackTrace: s);
      }

      // Wait before next retry attempt
      dev.log("Retrying FTP connection in 3 seconds...");
      await Future.delayed(Duration(seconds: 3));
    }
    _isInitializing = false;
  }

  /// Creates a stream that periodically fetches and yields JSON data
  /// from the FTP server (`abc.json` file).
  ///
  /// - Checks if the file exists first.
  /// - Downloads and parses it every 3 seconds.
  /// - If an error occurs or file is missing, yields `null`.
  Stream<Map<String, dynamic>?> getFtpFileStreamData({
    required FTPConnect ftpConnect,
  }) async* {
    try {
      final dir = await getTemporaryDirectory();
      // final filePath = '${dir.path}/abc.json';
      final filePath = '${dir.path}/system_status.json';
      final file = File(filePath);

      // Verify file exists before polling
      final isFileExist = await ftpConnect.existFile('system_status.json');
      if (!isFileExist) {
        dev.log("File not found on FTP server");
        yield null;
        await ftpConnect.disconnect();
        return;
      }

      // Start polling the file every 3 seconds
      while (true) {
        try {
          final downloaded = await ftpConnect.downloadFile('abc.json', file);
          if (downloaded) {
            final fileContents = await file.readAsString();
            final decodedJson = jsonDecode(fileContents);
            yield decodedJson;
          } else {
            dev.log("Download failed");
            yield null;
            break; // Stop polling on download failure
          }
        } catch (e, s) {
          dev.log("Error during FTP polling", error: e, stackTrace: s);
          yield null;
          break; // Exit polling loop
        }

        await Future.delayed(Duration(seconds: 3));
      }
    } catch (e, s) {
      dev.log("Exception while connecting FTP", error: e, stackTrace: s);
      yield null;
    }
  }

  /// Validates login credentials against static values.
  ///
  /// - Updates login state accordingly.
  /// - Admin login: username `admin`, password `admin123`.
  Future<void> loginSubmit() async {
    _loginState = LoginState.loading;
    notifyListeners();
    try {
      if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _usernameController.text.trim() == "admin" &&
          _passwordController.text.trim() == "admin123") {
        _loginState = LoginState.loginSucess;
        _loginErrorMessage = null;
        _ftpConnectionState = FtpConnectionState.none;
        dev.log("login success");
        notifyListeners();
      } else {
        dev.log("incorrect username OR password");
        _loginErrorMessage = "incorrect username OR password";
        _loginState = LoginState.loginFailed;
        notifyListeners();
      }
    } catch (e) {
      dev.log("Exception while login");
      _loginErrorMessage = "Something went wrong";
      _loginState = LoginState.loginFailed;
      notifyListeners();
    }
  }

  Future<void> checkingTempData() async {
    final String response = await rootBundle.loadString('assets/abc2.json');
    final Map<String, dynamic> data = json.decode(response);
    _fileData = DashboardNewModel.fromMap(data);
    notifyListeners();
  }


  /// disposing the login provider
  Future<void> dispose()async{
    
  }
}
