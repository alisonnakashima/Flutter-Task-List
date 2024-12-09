import 'package:flutter/services.dart';

class BatteryChannel {
  static const MethodChannel _channel = MethodChannel("battery");

  static Future<int> getBatteryLevel() async {
    // print("to no batteryChannel");
    try {
      final int batteryLevel = await _channel.invokeMethod('getBatteryLevel');
      print('Battery level: $batteryLevel%');
      return batteryLevel;
    } on PlatformException catch (e) {
      throw 'Failed to get battery level: ${e.message}';
    }
  }
}
