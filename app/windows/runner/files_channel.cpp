#include "files_channel.h"

// clang-format off
#include <windows.h>
#include <shellapi.h>
#include <shobjidl.h>
// clang-format on

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>
#include <string>

#include "utils.h"

// The Windows half of the files channel: only the dialogs. COM is already
// initialised (apartment-threaded) by main.cpp.

namespace {

template <typename T>
class ComPtr {
 public:
  ~ComPtr() {
    if (p_) p_->Release();
  }
  T** out() { return &p_; }
  T* operator->() const { return p_; }
  explicit operator bool() const { return p_ != nullptr; }

 private:
  T* p_ = nullptr;
};

std::optional<std::string> ResultPath(IFileDialog* dialog) {
  ComPtr<IShellItem> item;
  if (FAILED(dialog->GetResult(item.out()))) return std::nullopt;
  PWSTR path = nullptr;
  if (FAILED(item->GetDisplayName(SIGDN_FILESYSPATH, &path))) {
    return std::nullopt;
  }
  std::string utf8 = Utf8FromUtf16(path);
  CoTaskMemFree(path);
  return utf8;
}

// The chosen file's path, or nullopt when the user cancelled.
std::optional<std::string> PickPath() {
  ComPtr<IFileOpenDialog> dialog;
  if (FAILED(CoCreateInstance(CLSID_FileOpenDialog, nullptr,
                              CLSCTX_INPROC_SERVER,
                              IID_PPV_ARGS(dialog.out())))) {
    return std::nullopt;
  }
  DWORD options = 0;
  dialog->GetOptions(&options);
  dialog->SetOptions(options | FOS_FORCEFILESYSTEM | FOS_FILEMUSTEXIST);
  if (FAILED(dialog->Show(GetActiveWindow()))) return std::nullopt;
  return ResultPath(dialog.operator->());
}

std::optional<std::string> SavePath(const std::wstring& suggested) {
  ComPtr<IFileSaveDialog> dialog;
  if (FAILED(CoCreateInstance(CLSID_FileSaveDialog, nullptr,
                              CLSCTX_INPROC_SERVER,
                              IID_PPV_ARGS(dialog.out())))) {
    return std::nullopt;
  }
  DWORD options = 0;
  dialog->GetOptions(&options);
  dialog->SetOptions(options | FOS_FORCEFILESYSTEM | FOS_OVERWRITEPROMPT);
  dialog->SetFileName(suggested.c_str());
  if (FAILED(dialog->Show(GetActiveWindow()))) return std::nullopt;
  return ResultPath(dialog.operator->());
}

std::wstring Utf16FromUtf8(const std::string& s) {
  if (s.empty()) return std::wstring();
  int n = MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()),
                              nullptr, 0);
  std::wstring out(n, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()),
                      out.data(), n);
  return out;
}

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;

}  // namespace

void RegisterFilesChannel(flutter::BinaryMessenger* messenger) {
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "app.kilit.messenger/files",
      &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        if (call.method_name() == "openAppSettings") {
          // the privacy page, where camera and other app permissions live
          ShellExecuteW(nullptr, L"open", L"ms-settings:privacy", nullptr,
                        nullptr, SW_SHOWNORMAL);
          result->Success();
          return;
        }
        std::optional<std::string> path;
        if (call.method_name() == "pickPath") {
          path = PickPath();
        } else if (call.method_name() == "savePath") {
          const auto* name = std::get_if<std::string>(call.arguments());
          path = SavePath(Utf16FromUtf8(name ? *name : "kilit.klt"));
        } else {
          result->NotImplemented();
          return;
        }
        if (path) {
          result->Success(flutter::EncodableValue(*path));
        } else {
          result->Success();
        }
      });
}
