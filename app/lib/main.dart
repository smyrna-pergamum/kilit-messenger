import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/rust_core.dart';
import 'src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  // app-private storage: excluded from Android backup and device transfer
  // (res/xml/data_extraction_rules.xml); %APPDATA% on Windows
  final dir = await getApplicationSupportDirectory();
  final core = await RustCore.open(
    '${dir.path}${Platform.pathSeparator}kilit',
    desktop: Platform.isWindows || Platform.isLinux || Platform.isMacOS,
  );
  runApp(KilitApp(core: core));
}
