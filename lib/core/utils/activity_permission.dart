import 'package:flutter/services.dart';

class ActivityPermission {
  static const _channel = MethodChannel('fittrack/activity_permission');

  static Future<bool> isGranted() async {
    try {
      return await _channel.invokeMethod<bool>('check') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> request() async {
    try {
      return await _channel.invokeMethod<bool>('request') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}