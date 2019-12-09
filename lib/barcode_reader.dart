import 'dart:async';

import 'package:flutter/services.dart';

class BarcodeReader {
  static const MethodChannel _channel =
      const MethodChannel('barcode_reader');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
