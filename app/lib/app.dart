import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/kilit_core.dart';
import 'l10n/app_localizations.dart';
import 'platform/files.dart';
import 'screens/lock_screen.dart';
import 'screens/shell.dart';
import 'state/prefs.dart';
import 'state/session.dart';
import 'theme/theme.dart';

/// How long the screen takes to fade out before a theme change, and back in.
const themeFadeOut = Duration(milliseconds: 220);
const themeFadeIn = Duration(milliseconds: 320);

class KilitApp extends StatefulWidget {
  const KilitApp({
    super.key,
    required this.core,
    required this.files,
    required this.prefs,
  });

  final KilitCore core;
  final FileAccess files;
  final Prefs prefs;

  @override
  State<KilitApp> createState() => _KilitAppState();
}

class _KilitAppState extends State<KilitApp>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Session _session = Session(widget.core)..start();

  // leaving the app locks it: switching apps, the recents screen, a
  // minimised window. Losing focus alone (a dialog on top) does not.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onHide: _session.lock,
  );

  /// 1 shows the app, 0 shows the black behind it.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    value: 1,
  );

  /// The brightness on screen. It changes only while the app is faded out,
  /// so a theme change is a fade through black instead of a hard switch.
  late Brightness _shown = _wanted();

  @override
  void initState() {
    super.initState();
    widget.prefs.addListener(_prefsChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    widget.prefs.removeListener(_prefsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _fade.dispose();
    _lifecycle.dispose();
    _session.dispose();
    super.dispose();
  }

  Brightness _wanted() => switch (widget.prefs.themeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => PlatformDispatcher.instance.platformBrightness,
  };

  void _prefsChanged() {
    setState(() {}); // a language change shows at once
    _crossFade();
  }

  // the system theme changed while following it
  @override
  void didChangePlatformBrightness() => _crossFade();

  Future<void> _crossFade() async {
    final target = _wanted();
    if (target == _shown) return;
    if (PlatformDispatcher.instance.accessibilityFeatures.disableAnimations) {
      setState(() => _shown = target);
      return;
    }
    await _fade.animateTo(0, duration: themeFadeOut, curve: Curves.easeOut);
    if (!mounted) return;
    setState(() => _shown = _wanted());
    await _fade.animateTo(1, duration: themeFadeIn, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF000000),
      child: FadeTransition(
        opacity: _fade,
        child: MaterialApp(
          onGenerateTitle: (context) => L.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: kilitTheme(Brightness.light),
          darkTheme: kilitTheme(Brightness.dark),
          themeMode: _shown == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          // the fade does the transition; no colour blending on top of it
          themeAnimationDuration: Duration.zero,
          // null follows the system; English is the fallback for a system
          // language Kilit does not ship
          locale: widget.prefs.locale,
          supportedLocales: L.supportedLocales,
          localizationsDelegates: L.localizationsDelegates,
          home: ListenableBuilder(
            listenable: _session,
            builder: (context, _) => switch (_session.phase) {
              SessionPhase.starting => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              SessionPhase.needsSetup || SessionPhase.locked => LockScreen(
                // a new key per phase change resets the PIN pad and its shuffle
                key: ValueKey(_session.phase),
                session: _session,
              ),
              SessionPhase.unlocked => Shell(
                session: _session,
                files: widget.files,
                prefs: widget.prefs,
              ),
            },
          ),
        ),
      ),
    );
  }
}
