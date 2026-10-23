import 'package:flutter/material.dart';

import 'app.dart';
import 'core/dev_core.dart';

void main() {
  // DevCore encrypts nothing; it is replaced by the Rust bridge before any
  // release. The lock screen shows a warning banner while it is in use.
  runApp(KilitApp(core: DevCore()));
}
