import 'package:flutter/material.dart';

import 'tokens.dart';

/// The monospace family for keys, fingerprints and packet details. Bundled,
/// so no font is ever fetched over the network.
const monoFamily = 'JetBrains Mono';

ThemeData kilitTheme(Brightness brightness) {
  final t = brightness == Brightness.dark
      ? KilitTokens.dark
      : KilitTokens.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.accent,
    onPrimary: t.onAccent,
    secondary: t.safe,
    onSecondary: t.background,
    error: t.danger,
    onError: t.background,
    surface: t.surface,
    onSurface: t.text,
    onSurfaceVariant: t.textMuted,
    outline: t.outline,
    outlineVariant: t.outline,
    surfaceContainerHighest: t.surfaceRaised,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.background,
    extensions: [t],
    // body text uses the platform font (Roboto, Segoe UI): nothing to bundle
    appBarTheme: AppBarTheme(
      backgroundColor: t.background,
      foregroundColor: t.text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.outline),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      indicatorColor: t.accent.withValues(alpha: 0.18),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: t.surface,
      indicatorColor: t.accent.withValues(alpha: 0.18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: t.onAccent,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.surfaceRaised,
      contentTextStyle: TextStyle(color: t.text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
