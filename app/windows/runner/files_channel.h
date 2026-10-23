#ifndef RUNNER_FILES_CHANNEL_H_
#define RUNNER_FILES_CHANNEL_H_

#include <flutter/binary_messenger.h>

// Registers "app.kilit.messenger/files" on Windows: the system open and save
// dialogs, returning paths. Dart reads and writes the files itself.
void RegisterFilesChannel(flutter::BinaryMessenger* messenger);

#endif  // RUNNER_FILES_CHANNEL_H_
