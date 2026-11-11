import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../platform/desktop_camera.dart';
import 'camera_screen.dart' show CameraFailed;

/// Reads a QR code where the camera has no frame stream (Windows): a
/// picture now and then, through [DesktopCamera.shot], looked at in memory.
class DesktopScanner extends StatefulWidget {
  const DesktopScanner({super.key, required this.onScan});

  /// The code's text, once.
  final ValueChanged<String> onScan;

  @override
  State<DesktopScanner> createState() => _DesktopScannerState();
}

class _DesktopScannerState extends State<DesktopScanner> {
  CameraController? _cam;
  bool _failed = false;
  bool _done = false;
  bool _looking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw StateError('no camera');
      final c = CameraController(
        cams.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _cam = c);
      _timer = Timer.periodic(
        const Duration(milliseconds: 700),
        (_) => unawaited(_look()),
      );
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _look() async {
    final c = _cam;
    if (c == null || _looking || _done || !c.value.isInitialized) return;
    _looking = true;
    try {
      final bytes = await DesktopCamera.shot(c);
      final code = await zx.readBarcodeImagePath(
        XFile.fromData(bytes),
        DecodeParams(
          format: Format.qrCode,
          tryHarder: true,
          tryInverted: true,
          maxSize: 1280,
        ),
      );
      final text = code.text;
      if (!_done && mounted && code.isValid && text != null) {
        _done = true;
        _timer?.cancel();
        widget.onScan(text);
      }
    } on Object {
      // the next picture may do
    } finally {
      _looking = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    final c = _cam;
    _cam = null;
    if (c != null) unawaited(c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _cam;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: _failed
            ? const CameraFailed()
            : c == null
            ? const CircularProgressIndicator()
            : CameraPreview(c),
      ),
    );
  }
}
