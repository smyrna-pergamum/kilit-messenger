import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../l10n/app_localizations.dart';
import '../platform/desktop_camera.dart';
import '../theme/tokens.dart';

/// The type a voice message is sent with: AAC with ADTS headers, as the
/// recorder streams it on Android and Windows.
const voiceMime = 'audio/aac';

/// A voice message stops by itself after this long. At [_bitRate] that is
/// about 1.8 MB, well under the 5 MiB a chat file may be.
const voiceLimit = Duration(minutes: 5);

const _bitRate = 48000;

/// The name a voice message is sent under.
String voiceName() {
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return 'kilit-voice-${n.year}${two(n.month)}${two(n.day)}-'
      '${two(n.hour)}${two(n.minute)}${two(n.second)}.aac';
}

/// The microphone, recording into memory: the recorder streams the encoded
/// sound, and nothing is written to a file.
abstract class VoiceInput {
  /// Asks for the microphone where it must be asked for; false when it is
  /// not allowed.
  Future<bool> allowed();

  /// Starts; the encoded sound comes on the stream.
  Future<Stream<Uint8List>> start();

  Future<void> stop();

  Future<void> dispose();

  /// What [VoiceRecordSheet] records with; tests put a stand-in here.
  static VoiceInput Function() make = _RecordInput.new;
}

class _RecordInput implements VoiceInput {
  final _rec = AudioRecorder();

  @override
  Future<bool> allowed() => _rec.hasPermission();

  @override
  Future<Stream<Uint8List>> start() => _rec.startStream(
    const RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: _bitRate,
      sampleRate: 44100,
      numChannels: 1,
    ),
  );

  @override
  Future<void> stop() async {
    await _rec.stop();
  }

  @override
  Future<void> dispose() => _rec.dispose();
}

/// Records a voice message at once; returns its bytes when the user sends
/// it, null when they cancel.
Future<Uint8List?> recordVoice(BuildContext context) =>
    showModalBottomSheet<Uint8List>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const VoiceRecordSheet(),
    );

class VoiceRecordSheet extends StatefulWidget {
  const VoiceRecordSheet({super.key});

  @override
  State<VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends State<VoiceRecordSheet> {
  final VoiceInput _in = VoiceInput.make();
  final _bytes = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _sub;
  final _clock = Stopwatch();
  Timer? _tick;
  bool _failed = false;
  bool _recording = false;
  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      if (!await _in.allowed()) throw StateError('no microphone');
      final s = await _in.start();
      _sub = s.listen(_bytes.add);
      _clock.start();
      _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!mounted) return;
        if (_clock.elapsed >= voiceLimit) unawaited(_stop());
        setState(() {});
      });
      if (mounted) setState(() => _recording = true);
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Stops recording; what was said stays, to send.
  Future<void> _stop() async {
    if (_stopped) return;
    _stopped = true;
    _clock.stop();
    _tick?.cancel();
    try {
      await _in.stop();
    } on Object {
      // what came so far is kept
    }
    // the last pieces come before the stream closes; it is done by then,
    // so cancelling need not be waited for
    await Future<void>.delayed(const Duration(milliseconds: 100));
    unawaited(_sub?.cancel());
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _send() async {
    await _stop();
    if (!mounted) return;
    final b = _bytes.takeBytes();
    Navigator.pop(context, b.isEmpty ? null : b);
  }

  Future<void> _cancel() async {
    await _stop();
    _bytes.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_sub?.cancel());
    unawaited(_in.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    if (_failed) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.voiceNoMic,
                key: const ValueKey('voice-failed'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('voice-settings'),
                    onPressed: () =>
                        DesktopCamera.openSettings(microphone: true),
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(l.voiceOpenSettings),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.close),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    final at = _clock.elapsed;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _recording ? Icons.mic : Icons.mic_none,
                  color: _recording ? t.danger : t.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  _clockText(at),
                  key: const ValueKey('voice-time'),
                  style: TextStyle(
                    color: t.text,
                    fontSize: 24,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _recording ? l.voiceRecording : l.voiceStopped,
              style: TextStyle(color: t.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              l.voiceLimitHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('voice-cancel'),
                    onPressed: _cancel,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('voice-send'),
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    label: Text(l.chatSend),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _clockText(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// A voice message in a bubble: play, pause, how far. The sound is opened
/// in memory and played from there.
class VoicePlayer extends StatefulWidget {
  const VoicePlayer({super.key, required this.load, required this.mime});

  /// The message's bytes, read when it is first played.
  final Future<Uint8List> Function() load;
  final String mime;

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  AudioPlayer? _p;
  final _subs = <StreamSubscription<Object?>>[];
  Duration _at = Duration.zero;
  Duration _length = Duration.zero;
  bool _playing = false;
  bool _loading = false;
  bool _failed = false;

  Future<void> _toggle() async {
    if (_loading) return;
    final p = _p;
    if (p != null) {
      if (_playing) {
        await p.pause();
      } else {
        await p.resume();
      }
      return;
    }
    setState(() => _loading = true);
    try {
      final bytes = await widget.load();
      final p = AudioPlayer();
      _subs
        ..add(
          p.onPositionChanged.listen((d) {
            if (mounted) setState(() => _at = d);
          }),
        )
        ..add(
          p.onDurationChanged.listen((d) {
            if (mounted) setState(() => _length = d);
          }),
        )
        ..add(
          p.onPlayerStateChanged.listen((s) {
            if (mounted) setState(() => _playing = s == PlayerState.playing);
          }),
        )
        ..add(
          p.onPlayerComplete.listen((_) {
            if (mounted) setState(() => _at = Duration.zero);
          }),
        );
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setSourceBytes(bytes, mimeType: widget.mime);
      _p = p;
      await p.resume();
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    final p = _p;
    _p = null;
    if (p != null) unawaited(p.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final whole = _length.inMilliseconds;
    return Row(
      key: const ValueKey('voice-message'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const ValueKey('voice-play'),
          tooltip: _playing ? l.voicePause : l.voicePlay,
          onPressed: _failed ? null : _toggle,
          icon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _failed
                      ? Icons.error_outline
                      : _playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: t.accent,
                ),
        ),
        SizedBox(
          width: 120,
          child: LinearProgressIndicator(
            value: whole > 0 ? _at.inMilliseconds / whole : 0,
            minHeight: 3,
            backgroundColor: t.textMuted.withValues(alpha: 0.25),
            color: t.accent,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _failed
              ? l.voiceCannotPlay
              : _clockText(_playing || _at > Duration.zero ? _at : _length),
          style: TextStyle(color: t.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
