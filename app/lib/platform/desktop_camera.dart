import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

/// The camera where its preview frames cannot be watched in memory.
///
/// On Windows the camera plugin has no frame stream: a photo, or a frame to
/// look for a QR code in, comes only from takePicture, which writes a file.
/// Kilit's copy of the plugin writes it to the temp folder
/// (third_party/README.md); [shot] reads it into memory, overwrites it with
/// zeros and deletes it before returning.
abstract final class DesktopCamera {
  /// True where preview frames come as a stream (Android): nothing is
  /// written at all.
  static bool get streams => !Platform.isWindows;

  /// Takes a picture and returns its bytes; the file is gone by then.
  static Future<Uint8List> shot(CameraController c) async {
    final x = await c.takePicture();
    final f = File(x.path);
    try {
      return await f.readAsBytes();
    } finally {
      await _wipe(f);
    }
  }

  static Future<void> _wipe(File f) async {
    try {
      final n = await f.length();
      await f.writeAsBytes(Uint8List(n), flush: true);
    } on Object {
      // deleting anyway
    }
    try {
      await f.delete();
    } on Object {
      // already gone
    }
  }

  static const _app = MethodChannel('app.kilit.messenger/app');

  /// Opens where the user lets Kilit use the camera, or with [microphone]
  /// the microphone: Windows' privacy page for it, or Kilit's page in
  /// Android's settings. False where there is none.
  static Future<bool> openSettings({bool microphone = false}) async {
    try {
      if (Platform.isWindows) {
        await Process.start('explorer.exe', [
          microphone
              ? 'ms-settings:privacy-microphone'
              : 'ms-settings:privacy-webcam',
        ]);
        return true;
      }
      if (Platform.isAndroid) {
        return await _app.invokeMethod<bool>('openSettings') ?? false;
      }
    } on Object {
      // nothing to open
    }
    return false;
  }
}
