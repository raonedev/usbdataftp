import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:usbdataftptest/features/data/models/recordings_model.dart';

import '../../../data/models/camera_status_model.dart';
import '../../../data/models/sys_info_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum IpCamerasState { loading, sucess, failed, none }

enum GetSysInfoState { sucess, loading, failed, none }

enum RecordingFileState { loading, sucess, failed, none }

enum CopyingFileState { loading, sucess, failed, none }

class GetSysInfoFileManagement extends ChangeNotifier {
  final List<SystemInfoModel> _systemInfoModel = [];
  IpCameras? _ipCameras;
  AllRecordingsFiles? _allRecordingsFiles;

  IpCamerasState _ipCamerasState = IpCamerasState.none;
  GetSysInfoState _getSysInfoState = GetSysInfoState.none;
  RecordingFileState _recordingFileState = RecordingFileState.none;
  CopyingFileState _copyingFileState = CopyingFileState.none;

  String _sysInfoErrorMessage = "";
  String _ipCamerasErrorMessage = "";
  String _recordingFileError = "";
  String _copyingFileError = "";
  String _copyingFileSucess = "";

  /// getter
  /// -> data
  List<SystemInfoModel> get systemInfoModel => List.unmodifiable(_systemInfoModel);
  IpCameras? get ipCameras => _ipCameras;
  AllRecordingsFiles? get allRecordingsFiles => _allRecordingsFiles;

  /// -> state
  GetSysInfoState get getSysInfoState => _getSysInfoState;
  IpCamerasState get ipCamerasState => _ipCamerasState;
  RecordingFileState get recordingFileState => _recordingFileState;
  CopyingFileState get copyingFileState => _copyingFileState;

  /// -> error message
  String get sysInfoErrorMessage => _sysInfoErrorMessage;
  String get ipCamerasErrorMessage => _ipCamerasErrorMessage;
  String get recordingFileError => _recordingFileError;
  String get copyingFileError => _copyingFileError;
  String get copyingFileSucess => _copyingFileSucess;

  StreamSubscription<String>? _subscription;

  /// Connect to SSE and gettinf sys info data stream in every 2 sec
  Future<void> connectToSysInfoStream({
    required String baseUrl,
    required String token,
  }) async {
    try {
      final request = http.Request(
        "GET",
        Uri.parse("$baseUrl/getAllDataStream"),
      );
      final client = http.Client();
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Cache-Control": "no-cache",
        "Accept": "text/event-stream",
      });
      final response = await client.send(request);

      _subscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith("data: ")) {
                final jsonString = line.substring(6);
                final info = SystemInfoModel.fromJson(jsonString);

                /// Keep only last 5
                if (_systemInfoModel.length >= 5) {
                  _systemInfoModel.removeAt(0);
                }
                _systemInfoModel.add(info);
                _sysInfoErrorMessage = '';
                _getSysInfoState = GetSysInfoState.sucess;
                notifyListeners();
              }
            },
            onError: (err) {
              _sysInfoErrorMessage = err.toString();
              _getSysInfoState = GetSysInfoState.failed;
              notifyListeners();
            },
            cancelOnError: false,
          );
    } catch (e) {
      _sysInfoErrorMessage = e.toString();
      _getSysInfoState = GetSysInfoState.failed;
      notifyListeners();
    }
  }

  /// fetch cameras and status of active and recordings
  Future<void> fetchIpCameras({
    required String baseUrl,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/getcameras");

    try {
      final response = await http
          .get(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _ipCameras = IpCameras.fromJson(decoded);
        _ipCamerasErrorMessage = "";
        _ipCamerasState = IpCamerasState.sucess;
        notifyListeners();
      } else {
        _ipCamerasErrorMessage =
            "Failed to fetch cameras (status ${response.statusCode})";
        _ipCamerasState = IpCamerasState.failed;
        notifyListeners();
      }
    } catch (e) {
      _ipCamerasErrorMessage = e.toString();
      _ipCamerasState = IpCamerasState.failed;
      notifyListeners();
    }
  }

  /// fetch all recording files
  Future<void> fetchAllRecordings({
    required String baseUrl,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/getrecordings");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _allRecordingsFiles = AllRecordingsFiles.fromJson(response.body);
        _recordingFileState = RecordingFileState.sucess;
        _recordingFileError = "";
        notifyListeners();
      } else {
        _recordingFileError =
            "Failed to fetch recordings (status ${response.statusCode})";
        _recordingFileState = RecordingFileState.failed;
        notifyListeners();
      }
    } catch (e) {
      _recordingFileError = e.toString();
      _recordingFileState = RecordingFileState.failed;
      notifyListeners();
    }
  }

  /// send data
  Future<void> sendRecordings({
    required List<RecordingFileModel> allRecordingsFilesToTransfer,
    required Disk disk,
    required String token,
    required String baseUrl,
  }) async {
    _copyingFileState = CopyingFileState.loading;
    _copyingFileSucess = "";
    _copyingFileError = "";
    notifyListeners();
    for (var recording in allRecordingsFilesToTransfer) {
      final sourcePath = recording.path;
      final destinationPath = "${disk.mountedPointPath}/${recording.name}";

      final body = {
        "sourcePath": sourcePath,
        "destinationPath": destinationPath,
      };

      try {
        final response = await http.post(
          Uri.parse("$baseUrl/copy-file"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final res = jsonDecode(response.body);
          _copyingFileState = CopyingFileState.sucess;
          _copyingFileSucess = "sucess : ${recording.name}";
          _copyingFileError = "";
          log("✅ Copied: ${res['message']} - ${recording.name}");
        } else {
          _copyingFileState = CopyingFileState.failed;
          _copyingFileSucess = "";
          _copyingFileError = "Failed to copy ${recording.name}";
          notifyListeners();
          log("❌ Failed to copy ${recording.name}: ${response.body}");
        }
      } catch (e) {
        _copyingFileState = CopyingFileState.failed;
        _copyingFileSucess = "";
        _copyingFileError = "Failed to copy ${recording.name}";
        notifyListeners();
        log("⚠️ Error copying ${recording.name}: $e");
      }
    }
  }

  /// Disconnect stream
  void disconnectStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    disconnectStream();
    super.dispose();
  }
}
