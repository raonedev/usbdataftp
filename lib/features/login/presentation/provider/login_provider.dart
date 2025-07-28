import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:usbdataftptest/helper.dart';

enum LoginState { loading, loginSucess, loginFailed, noLogin }

class LoginProvider extends ChangeNotifier {
  ///usb detected-> usb tethering -> device ip found -> ftp connection -> data retrival

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

  bool _isFTPConnected = false;
  bool get isFTPConnected => _isFTPConnected;

  FTPConnect? _ftpConnect;
  StreamSubscription? _ftpSub;

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

  LoginState _loginState = LoginState.noLogin;
  LoginState get loginState => _loginState;

  Future<void> initialized() async {
    while (!_isFTPConnected) {
      try {
        _mobileTetheringIp = await getTetheringMobileIP();
        if (_mobileTetheringIp != null) {
          _isUsbTethering = true;
          _isMobileTetheringIpFound = true;
          log("tethering connected");
          notifyListeners();
          if (_deviceTetheringIP != null) {
            // trying ping last store
            log("last record ip changed");
            _deviceTetheringIP = await pingSingleIp(_deviceTetheringIP!);
          }

          _deviceTetheringIP ??= await findPcIpByPingSubnet(
            _mobileTetheringIp!,
          );

          if (_deviceTetheringIP != null) {
            _isDeviceTethering = true;
            log("device ip found");
            notifyListeners();

            _ftpConnect = FTPConnect(
              _deviceTetheringIP!,
              user: 'myuser',
              pass: 'mypassword',
              port: 2121,
              showLog: true,
            );

            try {
              final connected = await _ftpConnect!.connect();
              if (connected) {
                log("ftp connected");
                _isFTPConnected = true;
                notifyListeners();

                _ftpSub = getFtpFileStreamData(ftpConnect: _ftpConnect!).listen(
                  (jsonData) async {
                    log(jsonData.toString());
                    if (jsonData == null) {
                      await _ftpSub?.cancel();
                      _ftpSub = null;
                      _isFTPConnected = false;
                      notifyListeners();
                      await initialized(); // retry if FTP stream fails
                    }
                  },
                );
                break;
              } else {
                log("ftp disconnected");
                _isFTPConnected = false;
                notifyListeners();
              }
            } catch (ftpError, ftpStack) {
              log(
                "FTP connection failed",
                error: ftpError,
                stackTrace: ftpStack,
              );
            }
          } else {
            _isDeviceTethering = false;
            log("device tethering disconnected");
            notifyListeners();
          }
        } else {
          _isUsbTethering = false;
          _isMobileTetheringIpFound = false;
          _isDeviceTethering = false;
          log("usb tethering false");
          notifyListeners();
        }
      } catch (e, s) {
        log("Exception during initialization", error: e, stackTrace: s);
      }

      // 💤 Wait before retrying
      log("Retrying FTP connection in 3 seconds...");
      await Future.delayed(Duration(seconds: 3));
    }
  }

  Stream<Map<String, dynamic>?> getFtpFileStreamData({
    required FTPConnect ftpConnect,
  }) async* {
    try {
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

        await Future.delayed(Duration(seconds: 3));
      }
    } catch (e, s) {
      log("Exception while connecting FTP", error: e, stackTrace: s);
      yield null;
    }
  }

  Future<void> loginSubmit() async {
    _loginState = LoginState.loading;
    notifyListeners();
    try {
      if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _usernameController.text.trim() == "admin" &&
          _passwordController.text.trim() == "admin123") {
        _loginState = LoginState.loginSucess;
        log("login success");
        notifyListeners();
      }
    } catch (e) {
      log("Exception while login");
      _loginState = LoginState.loginFailed;
      notifyListeners();
    }
  }
}
