import 'package:flutter/services.dart';

/// Restarts Kilit in a new process. On Android the embedded Tor runs once
/// per process: a Tor that stopped comes back only this way.
abstract final class AppRestart {
  static const _channel = MethodChannel('app.kilit.messenger/app');

  /// False where Kilit cannot restart itself.
  static Future<bool> restart() async {
    try {
      return await _channel.invokeMethod<bool>('restart') ?? false;
    } on MissingPluginException {
      return false;
    }
  }
}
