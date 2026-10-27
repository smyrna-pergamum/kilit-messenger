import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';

/// Takes a photo without writing anything to disk: the camera's preview
/// stream is watched in memory, and the shutter keeps the latest frame,
/// which the Rust core turns into a JPEG with no metadata. Returns the JPEG,
/// or null.
///
/// (The camera plugin's takePicture would write the full-size picture, with
/// everything the sensor knows, to a file first.)
class CameraCapture extends StatefulWidget {
  const CameraCapture({super.key, required this.core});

  final KilitCore core;

  @override
  State<CameraCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  CameraController? _cam;
  CameraImage? _latest;
  Uint8List? _shot;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await c.initialize();
      await c.startImageStream((img) => _latest = img);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _cam = c);
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    final c = _cam;
    _cam = null;
    _latest = null;
    if (c != null) unawaited(_close(c));
    super.dispose();
  }

  static Future<void> _close(CameraController c) async {
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } on Object {
      // closing anyway
    }
    await c.dispose();
  }

  Future<void> _shutter() async {
    final c = _cam;
    final img = _latest;
    if (c == null || img == null || _busy || img.planes.length < 3) return;
    setState(() => _busy = true);
    try {
      final (y, u, v) = (img.planes[0], img.planes[1], img.planes[2]);
      final jpeg = await widget.core.cameraJpeg(
        CameraFrame(
          width: img.width,
          height: img.height,
          y: Uint8List.fromList(y.bytes),
          u: Uint8List.fromList(u.bytes),
          v: Uint8List.fromList(v.bytes),
          yRow: y.bytesPerRow,
          uvRow: u.bytesPerRow,
          uvPixel: u.bytesPerPixel ?? 1,
          // the back camera's sensor lies sideways; held upright, this turns
          // the picture to match
          rotation: c.description.sensorOrientation % 360,
        ),
      );
      if (mounted) setState(() => _shot = jpeg);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final c = _cam;
    final shot = _shot;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.navCamera),
      ),
      body: SafeArea(
        child: _failed
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l.cameraNoCamera,
                    key: const ValueKey('camera-failed'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: shot != null
                          ? Image.memory(
                              shot,
                              key: const ValueKey('camera-shot'),
                            )
                          : c == null
                          ? const CircularProgressIndicator()
                          : CameraPreview(c),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: shot == null
                        ? IconButton.filled(
                            key: const ValueKey('camera-shutter'),
                            tooltip: l.cameraShutter,
                            iconSize: 40,
                            style: IconButton.styleFrom(
                              backgroundColor: t.accent,
                            ),
                            onPressed: _busy ? null : _shutter,
                            icon: _busy
                                ? const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Icon(Icons.camera_alt),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const ValueKey('camera-retake'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => setState(() => _shot = null),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(l.cameraRetake),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  key: const ValueKey('camera-use'),
                                  onPressed: () => Navigator.pop(context, shot),
                                  icon: const Icon(Icons.check),
                                  label: Text(l.cameraUse),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The Camera tab: a photo straight into the vault, or to a contact.
class CameraTab extends StatelessWidget {
  const CameraTab({super.key, required this.core, required this.onSend});

  final KilitCore core;

  /// Sends a photo to a contact the user picks.
  final Future<void> Function(BuildContext context, Uint8List jpeg) onSend;

  String _name() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'kilit-${n.year}${two(n.month)}${two(n.day)}-${two(n.hour)}${two(n.minute)}${two(n.second)}.jpg';
  }

  Future<void> _take(BuildContext context, {required bool toVault}) async {
    final l = L.of(context);
    final jpeg = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => CameraCapture(core: core)),
    );
    if (jpeg == null || !context.mounted) return;
    if (toVault) {
      await core.addFile(_name(), 'image/jpeg', jpeg);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l.cameraSavedVault)));
      }
    } else {
      await onSend(context, jpeg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined, size: 48, color: t.accent),
            const SizedBox(height: 12),
            Text(
              l.cameraIntro,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('camera-to-chat'),
              onPressed: () => _take(context, toVault: false),
              icon: const Icon(Icons.send_rounded),
              label: Text(l.cameraSendTo),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('camera-to-vault'),
              onPressed: () => _take(context, toVault: true),
              icon: const Icon(Icons.lock_outline),
              label: Text(l.cameraToVault),
            ),
          ],
        ),
      ),
    );
  }
}
