import 'package:flutter/material.dart';

import 'core/kilit_core.dart';
import 'screens/lock_screen.dart';
import 'screens/shell.dart';
import 'state/session.dart';
import 'theme/theme.dart';

class KilitApp extends StatefulWidget {
  const KilitApp({super.key, required this.core});

  final KilitCore core;

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
    return MaterialApp(
      title: 'Kilit',
      debugShowCheckedModeBanner: false,
      theme: kilitTheme(Brightness.light),
      darkTheme: kilitTheme(Brightness.dark),
      themeMode: ThemeMode.system,
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
          SessionPhase.unlocked => Shell(session: _session),
        },
      ),
    );
  }
}
