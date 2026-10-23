import 'package:flutter/services.dart';

/// Where the PIN's hardware key lives.
enum KeyLevel {
  /// A dedicated security chip (Android StrongBox).
  strongbox,

  /// The phone's trusted execution environment (Android TEE).
  tee,

  /// The computer's TPM 2.0 (Windows).
  tpm,

  /// Android Keystore without secure hardware (emulators, some old phones).
  osSoftware,

  /// No platform key at all; the Rust core falls back to a software key.
  none,
}

/// The device key that MACs the PIN (Android Keystore, Windows TPM).
abstract interface class PinKey {
  Future<KeyLevel> level();

  /// HMAC-like keyed function of [data], computed inside the hardware.
  Future<Uint8List> mac(Uint8List data);

  /// Deletes the key for good. The next [mac] makes a new one, so nothing
  /// sealed under the old key can be opened again, even from old copies of
  /// the files that flash storage may keep.
  Future<void> destroy();
}

/// [PinKey] over the platform channel that MainActivity.kt and
/// windows/runner/hardware_key.cpp register.
class PlatformPinKey implements PinKey {
  static const _channel = MethodChannel('app.kilit.messenger/hardware_key');

  @override
  Future<KeyLevel> level() async {
    try {
      return switch (await _channel.invokeMethod<String>('level')) {
        'strongbox' => KeyLevel.strongbox,
        'tee' => KeyLevel.tee,
        'tpm' => KeyLevel.tpm,
        'software' => KeyLevel.osSoftware,
        _ => KeyLevel.none,
      };
    } on MissingPluginException {
      return KeyLevel.none; // a platform without the channel (Linux, tests)
    } on PlatformException {
      return KeyLevel.none;
    }
  }

  @override
  Future<void> destroy() async {
    try {
      await _channel.invokeMethod<bool>('destroy');
    } on MissingPluginException {
      // no platform key to destroy
    }
  }

  @override
  Future<Uint8List> mac(Uint8List data) async {
    final mac = await _channel.invokeMethod<Uint8List>('mac', data);
    if (mac == null || mac.length != 32) {
      throw PlatformException(code: 'hardware_key', message: 'bad MAC');
    }
    return mac;
  }
}
