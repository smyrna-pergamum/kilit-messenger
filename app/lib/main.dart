import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/rust_core.dart';
import 'platform/files.dart';
import 'platform/tor.dart';
import 'state/prefs.dart';
import 'src/rust/frb_generated.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  // app-private storage: excluded from Android backup and device transfer
  // (res/xml/data_extraction_rules.xml); %APPDATA% on Windows
  final dir = await getApplicationSupportDirectory();
  final sep = Platform.pathSeparator;
  final core = await RustCore.open(
    '${dir.path}${sep}kilit',
    desktop: Platform.isWindows || Platform.isLinux || Platform.isMacOS,
  );
  final prefs = await Prefs.load(
    FilePrefsStore(File('${dir.path}${sep}prefs.json')),
  );
  runApp(
    KilitApp(
      core: core,
      // on Windows a .klt opened from Explorer arrives as an argument
      files: PlatformFileAccess(args),
      prefs: prefs,
      // the embedded Tor on Android; Windows gets tor.exe in stage 3
      tor: TorController(NativeTor.load() ?? const NoTor(), dir.path),
    ),
  );
}
