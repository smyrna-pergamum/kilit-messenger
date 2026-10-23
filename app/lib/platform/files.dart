import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// The largest file the vault takes (kilit-ffi `MAX_FILE_BYTES`).
const maxFileBytes = 64 * 1024 * 1024;

class PickedFile {
  const PickedFile(this.name, this.mime, this.bytes);
  final String name;
  final String mime;
  final Uint8List bytes;
}

/// Something another app handed Kilit: a file, or shared text.
class Incoming {
  const Incoming.file(PickedFile this.file) : text = null;
  const Incoming.text(String this.text) : file = null;
  final PickedFile? file;
  final String? text;
}

class FileTooLarge implements Exception {
  const FileTooLarge();
}

/// Choosing, saving and receiving files, without the plaintext copies a
/// picker plugin would leave in the app's cache.
abstract interface class FileAccess {
  /// The chosen file, or null when the user cancelled.
  Future<PickedFile?> pick();

  /// Whether the user chose where to save, and it was written.
  Future<bool> save(String name, String mime, Uint8List bytes);

  /// What another app handed Kilit since last asked, if anything.
  Future<Incoming?> takeIncoming();

  /// Fires when something arrives while Kilit is running.
  Stream<void> get incomingReady;
}

/// A media type from a file name, for platforms that give no type.
String guessMime(String name) {
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  return switch (ext) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'heic' => 'image/heic',
    'mp4' => 'video/mp4',
    'mov' => 'video/quicktime',
    'pdf' => 'application/pdf',
    'txt' => 'text/plain',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'klt' => 'application/x-kilit',
    _ => 'application/octet-stream',
  };
}

/// [FileAccess] over the channel in FilesChannel.kt (Android, streams via
/// the Storage Access Framework) and files_channel.cpp (Windows dialogs,
/// with Dart reading and writing the chosen path).
class PlatformFileAccess implements FileAccess {
  /// [args] are the app's command-line arguments: on Windows, a `.klt` file
  /// opened from Explorer arrives as one.
  PlatformFileAccess([List<String> args = const []]) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'incomingReady') _ready.add(null);
    });
    final path = args
        .where((a) => a.toLowerCase().endsWith('.klt'))
        .firstOrNull;
    if (path != null) _fromArgs = _readPath(path);
  }

  static const _channel = MethodChannel('app.kilit.messenger/files');
  final _ready = StreamController<void>.broadcast();
  Future<PickedFile?>? _fromArgs;

  bool get _usesPaths =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  Future<PickedFile?> _readPath(String path) async {
    final f = File(path);
    if (await f.length() > maxFileBytes + 64 * 1024) throw const FileTooLarge();
    final name = f.uri.pathSegments.isEmpty ? 'dosya' : f.uri.pathSegments.last;
    return PickedFile(name, guessMime(name), await f.readAsBytes());
  }

  @override
  Future<PickedFile?> pick() async {
    try {
      if (_usesPaths) {
        final path = await _channel.invokeMethod<String>('pickPath');
        return path == null ? null : await _readPath(path);
      }
      final m = await _channel.invokeMapMethod<String, Object?>('pick');
      if (m == null) return null;
      return PickedFile(
        m['name']! as String,
        m['mime']! as String,
        m['bytes']! as Uint8List,
      );
    } on PlatformException catch (e) {
      if (e.message == 'too_large') throw const FileTooLarge();
      rethrow;
    }
  }

  @override
  Future<bool> save(String name, String mime, Uint8List bytes) async {
    if (_usesPaths) {
      final path = await _channel.invokeMethod<String>('savePath', name);
      if (path == null) return false;
      await File(path).writeAsBytes(bytes, flush: true);
      return true;
    }
    return await _channel.invokeMethod<bool>('save', {
          'name': name,
          'mime': mime,
          'bytes': bytes,
        }) ??
        false;
  }

  @override
  Future<Incoming?> takeIncoming() async {
    final fromArgs = _fromArgs;
    if (fromArgs != null) {
      _fromArgs = null;
      final f = await fromArgs;
      return f == null ? null : Incoming.file(f);
    }
    if (_usesPaths) return null;
    try {
      final m = await _channel.invokeMapMethod<String, Object?>('takeIncoming');
      if (m == null) return null;
      final text = m['text'];
      if (text is String) return Incoming.text(text);
      return Incoming.file(
        PickedFile(
          m['name']! as String,
          m['mime']! as String,
          m['bytes']! as Uint8List,
        ),
      );
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Stream<void> get incomingReady => _ready.stream;
}
