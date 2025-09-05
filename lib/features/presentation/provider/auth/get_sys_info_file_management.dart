import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usbdataftptest/core/helper.dart';
import 'package:usbdataftptest/features/data/models/recordings_model.dart';

import '../../../data/models/camera_status_model.dart';
import '../../../data/models/sys_info_model.dart';
import 'dart:convert';
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
  List<SystemInfoModel> get systemInfoModel =>
      List.unmodifiable(_systemInfoModel);
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

  final bool _isConencted = true;
  bool get isConencted => _isConencted;

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

      // Check if the response is successful
      if (response.statusCode != 200) {
        throw Exception('Failed to connect to stream: ${response.statusCode}');
      }

      // DO NOT wait for the first chunk. REMOVE these lines:
      // final List<int> firstChunk =  await response.stream.first;
      // dev.log(firstChunk.toString());

      // IMMEDIATELY start listening to the stream
      _subscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              // dev.log('Received line: $line'); // Debug log

              // Filter out empty lines and only process data lines
              if (line.trim().isEmpty) return;

              if (line.startsWith("data: ")) {
                try {
                  final jsonString = line.substring(6).trim();
                  // dev.log('JSON string: $jsonString'); // Debug log

                  // Create SystemInfoModel from the parsed JSON
                  final info = SystemInfoModel.fromJson(jsonString);

                  // Keep only last 5 entries
                  if (_systemInfoModel.length >= 5) {
                    _systemInfoModel.removeAt(0);
                  }

                  _systemInfoModel.add(info);

                  _sysInfoErrorMessage = '';
                  _getSysInfoState = GetSysInfoState.sucess;
                  notifyListeners();
                } catch (parseError) {
                  dev.log('JSON parsing error: $parseError'); // Debug log
                  _sysInfoErrorMessage = 'Failed to parse data: $parseError';
                  _getSysInfoState = GetSysInfoState.failed;
                  notifyListeners();
                }
              } else if (line.startsWith("event: error")) {
                // Handle server-sent error events
                _sysInfoErrorMessage = 'Server error received';
                _getSysInfoState = GetSysInfoState.failed;
                notifyListeners();
              }
            },
            onError: (err) {
              dev.log('Stream error: $err'); // Debug log
              _sysInfoErrorMessage = err.toString();
              _getSysInfoState = GetSysInfoState.failed;
              notifyListeners();
            },
            onDone: () {
              dev.log('Stream completed'); // Debug log
            },
            cancelOnError: false,
          );
    } catch (e) {
      dev.log('Connection error: $e'); // Debug log
      _sysInfoErrorMessage = e.toString();
      _getSysInfoState = GetSysInfoState.failed;
      notifyListeners();
    }
  }

  Future<void> connectToSysInfoStreamMock() async {
    try {
      await _subscription?.cancel();
      final controller = StreamController<String>();
      final random = Random();

      double cpuUsage = 20;
      double ramUsage = 30;
      double gpuUsage = 10;

      // Example hard disk list (mutable)
      final hardDisks = [
        {"name": "sda", "status": "Healthy", "total_gb": 256, "used_gb": 50},
        {"name": "sdb", "status": "Healthy", "total_gb": 512, "used_gb": 100},
      ];

      _subscription = controller.stream.listen(
        (line) {
          if (line.startsWith("data: ")) {
            final jsonString = line.substring(6);
            final info = SystemInfoModel.fromJson(jsonString);

            if (_systemInfoModel.length >= 5) {
              _systemInfoModel.removeAt(0);
              dev.log('_systemInfoModel remove');
            }
            dev.log('_systemInfoModel added');
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

      Timer.periodic(const Duration(seconds: 2), (timer) {
        // Small random fluctuation (-2..+2)
        cpuUsage = (cpuUsage + random.nextDouble() * 4 - 2).clamp(0, 100);
        ramUsage = (ramUsage + random.nextDouble() * 4 - 2).clamp(0, 100);
        gpuUsage = (gpuUsage + random.nextDouble() * 4 - 2).clamp(0, 100);

        // Occasionally flip a disk status
        if (random.nextDouble() < 0.1) {
          final idx = random.nextInt(hardDisks.length);
          hardDisks[idx]["status"] = (hardDisks[idx]["status"] == "Healthy")
              ? "UnHealthy"
              : "Healthy";
        }

        final mock = {
          "ram": {
            "usage_percent": ramUsage,
            "total_gb": 8,
            "used_gb": ramUsage * 0.08,
            "free_gb": 8 - ramUsage * 0.08,
          },
          "cpu": {
            "usage": cpuUsage,
            "temperature_celsius": 30 + cpuUsage * 0.2,
          },
          "gpu": {
            "usage": gpuUsage,
            "temperature_celsius": 25 + gpuUsage * 0.3,
          },
          "hard_disk": hardDisks,
          "network": {
            "upload_speed_kib": random.nextDouble() * 10,
            "download_speed_kib": random.nextDouble() * 20,
          },
          "storage": {"usage": 9, "total_gb": 1027},
          "location": {
            "_id": "mock-id",
            "Time": DateTime.now().toIso8601String(),
            "Latitude": 29.38 + random.nextDouble() * 0.01,
            "Longitude": 76.96 + random.nextDouble() * 0.01,
            "FixQuality": "1",
            "NoOfSatellite": "${6 + random.nextInt(3)}",
            "Altitude": "${250 + random.nextInt(20)}",
            "Course": "",
          },
        };

        controller.add("data: ${jsonEncode(mock)}");
      });
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
        dev.log('/get camera response is \n\n ${response.body}');
        _ipCameras = IpCameras.fromJson(response.body);
        _ipCamerasErrorMessage = "";
        _ipCamerasState = IpCamerasState.sucess;
        notifyListeners();
      } else {
        _ipCamerasErrorMessage = "Failed to fetch cameras (status ${response.statusCode})";
        _ipCamerasState = IpCamerasState.failed;
        notifyListeners();
      }
    } catch (e) {
      dev.log("geting camera error", error: e);
      _ipCamerasErrorMessage = e.toString();
      _ipCamerasState = IpCamerasState.failed;
      notifyListeners();
    }
  }

  Future<void> fetchMockCameras() async {
    try {
      // Load JSON file from assets
      final jsonString = await rootBundle.loadString(
        'assets/camera_status.json',
      );

      // Parse into your model
      _ipCameras = IpCameras.fromJson(jsonString);

      _ipCamerasErrorMessage = "";
      _ipCamerasState = IpCamerasState.sucess;
      notifyListeners();
    } catch (e) {
      _ipCamerasErrorMessage = "Failed to load mock data: $e";
      _ipCamerasState = IpCamerasState.failed;
      notifyListeners();
    }
  }

  /// fetch all recording files
  Future<void> fetchAllRecordings({
    required String baseUrl,
    required String token,
    int limit = 500,
    int offset = 0,
  }) async {
    final url = Uri.parse("$baseUrl/getrecordings?limit=$limit&offset=$offset");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // _allRecordingsFiles = AllRecordingsFiles.fromJson(response.body);
        _allRecordingsFiles = await AllRecordingsFiles.fromJsonIsolate(
          response.body,
        );
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

  Future<void> fetchAllRecordingsMock() async {
    const mockJson = '''
{
  "recordings": [
    {
      "name": "08-06-05-706454.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-06-05-706454.ts",
      "size": 1243620,
      "created": "2025-09-02T08:06:05.706Z",
      "modified": "2025-09-02T08:06:08.455Z",
      "sizeFormatted": "1.19 MB",
      "deviceId": 283
    },
    {
      "name": "08-06-05-706454.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-06-05-706454.ts",
      "size": 1243620,
      "created": "2025-09-02T08:06:05.706Z",
      "modified": "2025-09-02T08:06:08.455Z",
      "sizeFormatted": "1.19 MB",
      "deviceId": 284
    },
    {
      "name": "08-05-49-535275.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-05-49-535275.ts",
      "size": 2237764,
      "created": "2025-09-02T08:05:49.535Z",
      "modified": "2025-09-02T08:05:54.932Z",
      "sizeFormatted": "2.13 MB",
      "deviceId": 283
    },
    {
      "name": "08-05-49-535275.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-05-49-535275.ts",
      "size": 2237764,
      "created": "2025-09-02T08:05:49.535Z",
      "modified": "2025-09-02T08:05:54.932Z",
      "sizeFormatted": "2.13 MB",
      "deviceId": 284
    },
    {
      "name": "08-05-31-383170.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-05-31-383170.ts",
      "size": 2385344,
      "created": "2025-09-02T08:05:31.383Z",
      "modified": "2025-09-02T08:05:37.733Z",
      "sizeFormatted": "2.27 MB",
      "deviceId": 283
    },
    {
      "name": "08-05-31-383170.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-05-31-383170.ts",
      "size": 2385344,
      "created": "2025-09-02T08:05:31.383Z",
      "modified": "2025-09-02T08:05:37.733Z",
      "sizeFormatted": "2.27 MB",
      "deviceId": 284
    },
    {
      "name": "08-05-10-404266.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-05-10-404266.ts",
      "size": 1200380,
      "created": "2025-09-02T08:05:10.404Z",
      "modified": "2025-09-02T08:05:13.686Z",
      "sizeFormatted": "1.14 MB",
      "deviceId": 283
    },
    {
      "name": "08-05-10-404266.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-05-10-404266.ts",
      "size": 1200380,
      "created": "2025-09-02T08:05:10.404Z",
      "modified": "2025-09-02T08:05:13.686Z",
      "sizeFormatted": "1.14 MB",
      "deviceId": 284
    },
    {
      "name": "08-04-49-655884.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-49-655884.ts",
      "size": 1236288,
      "created": "2025-09-02T08:04:49.656Z",
      "modified": "2025-09-02T08:04:52.635Z",
      "sizeFormatted": "1.18 MB",
      "deviceId": 283
    },
    {
      "name": "08-04-49-655884.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-49-655884.ts",
      "size": 1236288,
      "created": "2025-09-02T08:04:49.656Z",
      "modified": "2025-09-02T08:04:52.635Z",
      "sizeFormatted": "1.18 MB",
      "deviceId": 284
    },
    {
      "name": "08-04-43-491435.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-43-491435.ts",
      "size": 1256592,
      "created": "2025-09-02T08:04:43.491Z",
      "modified": "2025-09-02T08:04:46.464Z",
      "sizeFormatted": "1.2 MB",
      "deviceId": 283
    },
    {
      "name": "08-04-43-491435.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-43-491435.ts",
      "size": 1256592,
      "created": "2025-09-02T08:04:43.491Z",
      "modified": "2025-09-02T08:04:46.464Z",
      "sizeFormatted": "1.2 MB",
      "deviceId": 284
    },
    {
      "name": "08-04-28-195358.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-28-195358.ts",
      "size": 4539448,
      "created": "2025-09-02T08:04:28.195Z",
      "modified": "2025-09-02T08:04:40.540Z",
      "sizeFormatted": "4.33 MB",
      "deviceId": 283
    },
    {
      "name": "08-04-28-195358.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-28-195358.ts",
      "size": 4539448,
      "created": "2025-09-02T08:04:28.195Z",
      "modified": "2025-09-02T08:04:40.540Z",
      "sizeFormatted": "4.33 MB",
      "deviceId": 284
    },
    {
      "name": "08-04-13-090172.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-13-090172.ts",
      "size": 4700564,
      "created": "2025-09-02T08:04:13.090Z",
      "modified": "2025-09-02T08:04:25.416Z",
      "sizeFormatted": "4.48 MB",
      "deviceId": 283
    },
    {
      "name": "08-04-13-090172.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-13-090172.ts",
      "size": 4700564,
      "created": "2025-09-02T08:04:13.090Z",
      "modified": "2025-09-02T08:04:25.416Z",
      "sizeFormatted": "4.48 MB",
      "deviceId": 284
    },
    {
      "name": "08-04-04-568404.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-04-568404.ts",
      "size": 1157328,
      "created": "2025-09-02T08:04:04.568Z",
      "modified": "2025-09-02T08:04:07.291Z",
      "sizeFormatted": "1.1 MB",
      "deviceId": 283
    },
    {
      "name": "08-04-04-568404.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-04-04-568404.ts",
      "size": 1157328,
      "created": "2025-09-02T08:04:04.568Z",
      "modified": "2025-09-02T08:04:07.291Z",
      "sizeFormatted": "1.1 MB",
      "deviceId": 284
    },
    {
      "name": "08-03-47-917432.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-03-47-917432.ts",
      "size": 4419316,
      "created": "2025-09-02T08:03:47.917Z",
      "modified": "2025-09-02T08:03:58.951Z",
      "sizeFormatted": "4.21 MB",
      "deviceId": 283
    },
    {
      "name": "08-03-47-917432.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-03-47-917432.ts",
      "size": 4419316,
      "created": "2025-09-02T08:03:47.917Z",
      "modified": "2025-09-02T08:03:58.951Z",
      "sizeFormatted": "4.21 MB",
      "deviceId": 284
    },
    {
      "name": "08-03-42-097071.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-03-42-097071.ts",
      "size": 1317692,
      "created": "2025-09-02T08:03:42.097Z",
      "modified": "2025-09-02T08:03:45.228Z",
      "sizeFormatted": "1.26 MB",
      "deviceId": 283
    },
    {
      "name": "08-03-42-097071.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-03-42-097071.ts",
      "size": 1317692,
      "created": "2025-09-02T08:03:42.097Z",
      "modified": "2025-09-02T08:03:45.228Z",
      "sizeFormatted": "1.26 MB",
      "deviceId": 284
    },
    {
      "name": "08-03-11-818187.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-03-11-818187.ts",
      "size": 2330260,
      "created": "2025-09-02T08:03:11.818Z",
      "modified": "2025-09-02T08:03:17.828Z",
      "sizeFormatted": "2.22 MB",
      "deviceId": 283
    },
    {
      "name": "08-03-11-818187.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-03-11-818187.ts",
      "size": 2330260,
      "created": "2025-09-02T08:03:11.818Z",
      "modified": "2025-09-02T08:03:17.828Z",
      "sizeFormatted": "2.22 MB",
      "deviceId": 284
    },
    {
      "name": "08-02-44-226562.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-44-226562.ts",
      "size": 9990884,
      "created": "2025-09-02T08:02:44.226Z",
      "modified": "2025-09-02T08:03:08.860Z",
      "sizeFormatted": "9.53 MB",
      "deviceId": 283
    },
    {
      "name": "08-02-44-226562.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-44-226562.ts",
      "size": 9990884,
      "created": "2025-09-02T08:02:44.226Z",
      "modified": "2025-09-02T08:03:08.860Z",
      "sizeFormatted": "9.53 MB",
      "deviceId": 284
    },
    {
      "name": "08-02-38-662413.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-38-662413.ts",
      "size": 1278024,
      "created": "2025-09-02T08:02:38.662Z",
      "modified": "2025-09-02T08:02:41.193Z",
      "sizeFormatted": "1.22 MB",
      "deviceId": 283
    },
    {
      "name": "08-02-38-662413.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-38-662413.ts",
      "size": 1278024,
      "created": "2025-09-02T08:02:38.662Z",
      "modified": "2025-09-02T08:02:41.193Z",
      "sizeFormatted": "1.22 MB",
      "deviceId": 284
    },
    {
      "name": "08-02-33-503400.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-33-503400.ts",
      "size": 1140220,
      "created": "2025-09-02T08:02:33.503Z",
      "modified": "2025-09-02T08:02:36.072Z",
      "sizeFormatted": "1.09 MB",
      "deviceId": 283
    },
    {
      "name": "08-02-33-503400.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-33-503400.ts",
      "size": 1140220,
      "created": "2025-09-02T08:02:33.503Z",
      "modified": "2025-09-02T08:02:36.072Z",
      "sizeFormatted": "1.09 MB",
      "deviceId": 284
    },
    {
      "name": "08-02-00-964558.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-00-964558.ts",
      "size": 4705452,
      "created": "2025-09-02T08:02:00.964Z",
      "modified": "2025-09-02T08:02:14.542Z",
      "sizeFormatted": "4.49 MB",
      "deviceId": 283
    },
    {
      "name": "08-02-00-964558.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-02-00-964558.ts",
      "size": 4705452,
      "created": "2025-09-02T08:02:00.964Z",
      "modified": "2025-09-02T08:02:14.542Z",
      "sizeFormatted": "4.49 MB",
      "deviceId": 284
    },
    {
      "name": "08-01-55-928370.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-01-55-928370.ts",
      "size": 1607024,
      "created": "2025-09-02T08:01:55.997Z",
      "modified": "2025-09-02T08:01:58.759Z",
      "sizeFormatted": "1.53 MB",
      "deviceId": 283
    },
    {
      "name": "08-01-55-928370.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-01-55-928370.ts",
      "size": 1607024,
      "created": "2025-09-02T08:01:55.997Z",
      "modified": "2025-09-02T08:01:58.759Z",
      "sizeFormatted": "1.53 MB",
      "deviceId": 284
    },
    {
      "name": "08-01-33-872546.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-01-33-872546.ts",
      "size": 672476,
      "created": "2025-09-02T08:01:34.013Z",
      "modified": "2025-09-02T08:01:35.680Z",
      "sizeFormatted": "656.71 KB",
      "deviceId": 283
    },
    {
      "name": "08-01-33-872546.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/08-01-33-872546.ts",
      "size": 672476,
      "created": "2025-09-02T08:01:34.013Z",
      "modified": "2025-09-02T08:01:35.680Z",
      "sizeFormatted": "656.71 KB",
      "deviceId": 284
    },
    {
      "name": "07-58-41-546437.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-58-41-546437.ts",
      "size": 1045092,
      "created": "2025-09-02T07:58:41.546Z",
      "modified": "2025-09-02T07:58:44.971Z",
      "sizeFormatted": "1020.6 KB",
      "deviceId": 283
    },
    {
      "name": "07-58-41-546437.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-58-41-546437.ts",
      "size": 1045092,
      "created": "2025-09-02T07:58:41.546Z",
      "modified": "2025-09-02T07:58:44.971Z",
      "sizeFormatted": "1020.6 KB",
      "deviceId": 284
    },
    {
      "name": "07-58-16-221909.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-58-16-221909.ts",
      "size": 5031256,
      "created": "2025-09-02T07:58:16.223Z",
      "modified": "2025-09-02T07:58:34.755Z",
      "sizeFormatted": "4.8 MB",
      "deviceId": 283
    },
    {
      "name": "07-58-16-221909.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-58-16-221909.ts",
      "size": 5031256,
      "created": "2025-09-02T07:58:16.223Z",
      "modified": "2025-09-02T07:58:34.755Z",
      "sizeFormatted": "4.8 MB",
      "deviceId": 284
    },
    {
      "name": "07-58-11-420935.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-58-11-420935.ts",
      "size": 1130820,
      "created": "2025-09-02T07:58:11.421Z",
      "modified": "2025-09-02T07:58:14.204Z",
      "sizeFormatted": "1.08 MB",
      "deviceId": 283
    },
    {
      "name": "07-58-11-420935.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-58-11-420935.ts",
      "size": 1130820,
      "created": "2025-09-02T07:58:11.421Z",
      "modified": "2025-09-02T07:58:14.204Z",
      "sizeFormatted": "1.08 MB",
      "deviceId": 284
    },
    {
      "name": "07-57-55-276200.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-55-276200.ts",
      "size": 3193368,
      "created": "2025-09-02T07:57:55.276Z",
      "modified": "2025-09-02T07:58:04.569Z",
      "sizeFormatted": "3.05 MB",
      "deviceId": 283
    },
    {
      "name": "07-57-55-276200.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-55-276200.ts",
      "size": 3193368,
      "created": "2025-09-02T07:57:55.276Z",
      "modified": "2025-09-02T07:58:04.569Z",
      "sizeFormatted": "3.05 MB",
      "deviceId": 284
    },
    {
      "name": "07-57-44-545047.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-44-545047.ts",
      "size": 2243216,
      "created": "2025-09-02T07:57:44.545Z",
      "modified": "2025-09-02T07:57:50.049Z",
      "sizeFormatted": "2.14 MB",
      "deviceId": 283
    },
    {
      "name": "07-57-44-545047.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-44-545047.ts",
      "size": 2243216,
      "created": "2025-09-02T07:57:44.545Z",
      "modified": "2025-09-02T07:57:50.049Z",
      "sizeFormatted": "2.14 MB",
      "deviceId": 284
    },
    {
      "name": "07-57-16-149981.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-16-149981.ts",
      "size": 1268436,
      "created": "2025-09-02T07:57:16.150Z",
      "modified": "2025-09-02T07:57:19.058Z",
      "sizeFormatted": "1.21 MB",
      "deviceId": 283
    },
    {
      "name": "07-57-16-149981.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-16-149981.ts",
      "size": 1268436,
      "created": "2025-09-02T07:57:16.150Z",
      "modified": "2025-09-02T07:57:19.058Z",
      "sizeFormatted": "1.21 MB",
      "deviceId": 284
    },
    {
      "name": "07-57-01-141731.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-01-141731.ts",
      "size": 3368396,
      "created": "2025-09-02T07:57:01.141Z",
      "modified": "2025-09-02T07:57:10.017Z",
      "sizeFormatted": "3.21 MB",
      "deviceId": 283
    },
    {
      "name": "07-57-01-141731.ts",
      "path": "/home/sparsh/VideoRecording/284_0/2025-09-02/07-57-01-141731.ts",
      "size": 3368396,
      "created": "2025-09-02T07:57:01.141Z",
      "modified": "2025-09-02T07:57:10.017Z",
      "sizeFormatted": "3.21 MB",
      "deviceId": 284
    }
  ],
  "total": 1034,
  "limit": 50,
  "offset": 0
}
''';

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // simulate network delay

      _allRecordingsFiles = AllRecordingsFiles.fromJson(mockJson);
      _recordingFileState = RecordingFileState.sucess;
      _recordingFileError = "";
      notifyListeners();
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
          dev.log("✅ Copied: ${res['message']} - ${recording.name}");
        } else {
          _copyingFileState = CopyingFileState.failed;
          _copyingFileSucess = "";
          _copyingFileError = "Failed to copy ${recording.name}";
          notifyListeners();
          dev.log("❌ Failed to copy ${recording.name}: ${response.body}");
        }
      } catch (e) {
        _copyingFileState = CopyingFileState.failed;
        _copyingFileSucess = "";
        _copyingFileError = "Failed to copy ${recording.name}";
        notifyListeners();
        dev.log("⚠️ Error copying ${recording.name}: $e");
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
