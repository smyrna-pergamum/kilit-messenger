# third_party

## camera_windows

A copy of [camera_windows](https://pub.dev/packages/camera_windows) 0.3.0+1
(BSD-3-Clause, see `camera_windows/LICENSE`). The only change is in
`windows/camera_plugin.cpp`, `GetFilePathForPicture`: `takePicture` writes
to the user's temp folder instead of the Pictures folder, which OneDrive or
the Photos app may pick up.

Kilit uses `takePicture` only on Windows, where the plugin has no frame
stream. It reads the file into memory at once, overwrites it with zeros and
deletes it (`lib/platform/desktop_camera.dart`). The example and the tests
of the original package are left out.
