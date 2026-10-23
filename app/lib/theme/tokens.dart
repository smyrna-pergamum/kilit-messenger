import 'package:flutter/material.dart';

/// Kilit's colour tokens: night blue and brass (docs: "Arayüz ve tasarım").
/// Every colour in the app comes from here, in both themes.
@immutable
class KilitTokens extends ThemeExtension<KilitTokens> {
  const KilitTokens({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.accent,
    required this.onAccent,
    required this.safe,
    required this.danger,
    required this.text,
    required this.textMuted,
    required this.outline,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;

  /// Brass: primary buttons and your own messages.
  final Color accent;
  final Color onAccent;

  /// Verified contact, Tor connected, signature valid.
  final Color safe;

  /// Key changed, wipe PIN, bad signature.
  final Color danger;
  final Color text;
  final Color textMuted;
  final Color outline;

  static const dark = KilitTokens(
    background: Color(0xFF0D1117),
    surface: Color(0xFF161C26),
    surfaceRaised: Color(0xFF1E2633),
    accent: Color(0xFFE0A84A),
    onAccent: Color(0xFF1A1305),
    safe: Color(0xFF3FB68B),
    danger: Color(0xFFE5534B),
    text: Color(0xFFE8EAED),
    textMuted: Color(0xFF8B949E),
    outline: Color(0xFF2D3644),
  );

  static const light = KilitTokens(
    background: Color(0xFFF7F5F0),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF0EDE6),
    accent: Color(0xFFB07A1E),
    onAccent: Color(0xFFFFFFFF),
    safe: Color(0xFF1F8A63),
    danger: Color(0xFFC2362F),
    text: Color(0xFF1B1F24),
    textMuted: Color(0xFF5C6470),
    outline: Color(0xFFDAD5CB),
  );

  @override
  KilitTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? accent,
    Color? onAccent,
    Color? safe,
    Color? danger,
    Color? text,
    Color? textMuted,
    Color? outline,
  }) {
    return KilitTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      safe: safe ?? this.safe,
      danger: danger ?? this.danger,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      outline: outline ?? this.outline,
    );
  }

  @override
  KilitTokens lerp(KilitTokens? other, double t) {
    if (other == null) return this;
    return KilitTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      safe: Color.lerp(safe, other.safe, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}

extension KilitTokensContext on BuildContext {
  KilitTokens get tokens => Theme.of(this).extension<KilitTokens>()!;
}
