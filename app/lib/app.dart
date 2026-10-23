import 'package:flutter/material.dart';

import 'core/kilit_core.dart';
import 'l10n/app_localizations.dart';
import 'platform/files.dart';
import 'screens/lock_screen.dart';
import 'screens/shell.dart';
import 'state/prefs.dart';
import 'state/session.dart';
import 'theme/theme.dart';

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

class _KilitAppState extends State<KilitApp> {
  late final Session _session = Session(widget.core)..start();

  // leaving the app locks it: switching apps, the recents screen, a
  // minimised window. Losing focus alone (a dialog on top) does not.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onHide: _session.lock,
  );

  @override
  void dispose() {
    _lifecycle.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.prefs,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => L.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: kilitTheme(Brightness.light),
        darkTheme: kilitTheme(Brightness.dark),
        themeMode: widget.prefs.themeMode,
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
    );
  }
}
