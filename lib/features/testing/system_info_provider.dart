import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/models/sys_info_model.dart';


class SystemInfoProvider with ChangeNotifier {
  static const String _baseUrl = 'http://192.168.29.23:3000';
  static const int _maxHistorySize = 5;
  
  StreamSubscription<String>? _streamSubscription;
  final List<SystemInfoModel> _history = [];
  bool _isConnected = false;
  String? _error;
  
  // Getters
  List<SystemInfoModel> get history => List.unmodifiable(_history);
  SystemInfoModel? get currentData => _history.isNotEmpty ? _history.last : null;
  bool get isConnected => _isConnected;
  String? get error => _error;
  
  // Chart data getters
  List<double> get ramUsageHistory => _history.map((data) => data.ram?.usagePercentage ?? 0.0).toList();
  List<double> get cpuUsageHistory => _history.map((data) => data.cpu?.usagePercent?.toDouble() ?? 0.0).toList();
  List<double> get networkUploadHistory => _history.map((data) => data.network?.uploadSpeedKIB ?? 0.0).toList();
  List<double> get networkDownloadHistory => _history.map((data) => data.network?.downloadSpeedKib ?? 0.0).toList();
  
  Future<void> startListening() async {
    try {
      _error = null;
      notifyListeners();
      
      final client = http.Client();
      final request = http.Request('GET', Uri.parse('$_baseUrl/getAllDataStream'));
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      
      final response = await client.send(request);
      
      if (response.statusCode == 200) {
        _isConnected = true;
        notifyListeners();
        
        _streamSubscription = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              _handleStreamData,
              onError: _handleError,
              onDone: _handleDisconnect,
            );
      } else {
        throw Exception('Failed to connect: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
    }
  }
  
  void _handleStreamData(String line) {
    try {
      if (line.startsWith('data: ')) {
        final jsonData = line.substring(6); // Remove 'data: ' prefix
        if (jsonData.trim().isNotEmpty) {
          final data = SystemInfoModel.fromJson(jsonData);
          _addToHistory(data);
        }
      } else if (line.startsWith('event: error')) {
        // Handle server-side errors
        _error = 'Server error occurred';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error parsing stream data: $e');
    }
  }
  
  void _addToHistory(SystemInfoModel data) {
    _history.add(data);
    
    // Keep only the latest 5 entries
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
    
    notifyListeners();
  }
  
  void _handleError(dynamic error) {
    _error = error.toString();
    _isConnected = false;
    notifyListeners();
    debugPrint('Stream error: $error');
  }
  
  void _handleDisconnect() {
    _isConnected = false;
    notifyListeners();
    debugPrint('Stream disconnected');
  }
  
  void stopListening() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _isConnected = false;
    notifyListeners();
  }
  
  void reconnect() {
    stopListening();
    startListening();
  }
  
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}