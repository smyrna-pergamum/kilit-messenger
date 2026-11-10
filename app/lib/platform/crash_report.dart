import 'dart:io';

import 'package:flutter/services.dart';

/// Why Kilit closed on its own last time: what the Rust core, the embedded
/// Tor and Android wrote down. Reports hold no messages or keys, only where
/// something failed.
abstract final class CrashReport {
  static const _channel = MethodChannel('app.kilit.messenger/app');

  /// A report found at this start, waiting to be shown once.
  static String? pending;

  /// Gathers the reports in the app's support folder [dir], keeps them in
  /// `last-crash.txt` and clears them, so each is shown once.
  static Future<String?> take(String dir) async {
    final sep = Platform.pathSeparator;
    final files = [
      File('$dir${sep}kilit${sep}crash.log'),
      File('$dir${sep}tor${sep}crash.log'),
      File('$dir${sep}crash-android.log'),
    ];
    final parts = <String>[];
    for (final f in files) {
      try {
        if (!f.existsSync() || f.lengthSync() == 0) continue;
        var text = f.readAsStringSync();
        if (text.length > 8000) text = text.substring(text.length - 8000);
        parts.add(text.trim());
        f.deleteSync();
      } on FileSystemException {
        // unreadable: nothing to show
      }
    }
    String? exit;
    try {
      exit = await _channel.invokeMethod<String>('lastExit');
    } on MissingPluginException {
      // not Android
    } on PlatformException {
      // the system would not say
    }
    if (exit != null && exit.isNotEmpty) {
      final seen = File('$dir${sep}crash-seen');
      try {
        if (!seen.existsSync() || seen.readAsStringSync() != exit) {
          seen.writeAsStringSync(exit);
          parts.add('android exit: $exit');
        }
      } on FileSystemException {
        // shown again next time
      }
    }
    if (parts.isEmpty) return null;
    final report = parts.join('\n\n');
    try {
      File('$dir${sep}last-crash.txt').writeAsStringSync(report);
    } on FileSystemException {
      // only shown now
    }
    return pending = report;
  }
}
