import 'dart:async';
import 'package:flutter/services.dart';

class TetheringService {
  static const EventChannel _eventChannel = EventChannel('com.example.usbdataftptest/networkEvents');

  static Stream<String?> get tetheringIpStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return event as String?;
    });
  }
}
