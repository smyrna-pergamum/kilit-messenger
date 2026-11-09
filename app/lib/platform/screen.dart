import 'package:flutter/services.dart';

/// Screenshot blocking: FLAG_SECURE on Android, capture exclusion on
/// Windows. It is on from the first frame; Settings may turn it off.
abstract final class ScreenGuard {
  static const _channel = MethodChannel('app.kilit.messenger/screen');

  static Future<void> set(bool on) async {
    try {
      await _channel.invokeMethod<void>('setSecure', on);
    } on MissingPluginException {
      // a platform without it (tests)
    }
  }
}
