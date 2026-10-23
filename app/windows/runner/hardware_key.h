#ifndef RUNNER_HARDWARE_KEY_H_
#define RUNNER_HARDWARE_KEY_H_

#include <flutter/binary_messenger.h>

// Registers "app.kilit.messenger/hardware_key": the PIN's TPM-bound keyed
// function, the Windows side of the Android Keystore channel.
void RegisterHardwareKeyChannel(flutter::BinaryMessenger* messenger);

#endif  // RUNNER_HARDWARE_KEY_H_
