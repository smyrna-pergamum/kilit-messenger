#include "hardware_key.h"

// clang-format off
#include <windows.h>
#include <bcrypt.h>
#include <ncrypt.h>
// clang-format on

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>
#include <vector>

// The PIN's hardware key on Windows: a non-exportable RSA-2048 key created
// by the TPM through the Microsoft Platform Crypto Provider, per user.
//
// The TPM provider offers no HMAC keys, so the keyed function is
//   mac(data) = SHA-256( RSA-PKCS#1-v1.5-sign( SHA-256(data) ) )
// PKCS#1 v1.5 signatures are deterministic, so the same PIN always gives the
// same 32 bytes, and only this TPM can produce them.
//
// The key carries no usage PIN of its own: a TPM PIN would bring the TPM's
// dictionary-attack lockout, which is shared with Windows Hello, and Kilit
// must not lock the user out of Windows.

namespace {

constexpr wchar_t kKeyName[] = L"Kilit PIN key v1";

class Handle {
 public:
  ~Handle() {
    if (h_) NCryptFreeObject(h_);
  }
  NCRYPT_HANDLE* out() { return &h_; }
  NCRYPT_HANDLE get() const { return h_; }

 private:
  NCRYPT_HANDLE h_ = 0;
};

std::optional<std::vector<uint8_t>> Sha256(const uint8_t* data, size_t len) {
  std::vector<uint8_t> out(32);
  NTSTATUS s = BCryptHash(BCRYPT_SHA256_ALG_HANDLE, nullptr, 0,
                          const_cast<PUCHAR>(data), static_cast<ULONG>(len),
                          out.data(), static_cast<ULONG>(out.size()));
  if (!BCRYPT_SUCCESS(s)) return std::nullopt;
  return out;
}

bool OpenOrCreateKey(Handle& provider, Handle& key) {
  if (NCryptOpenStorageProvider(
          reinterpret_cast<NCRYPT_PROV_HANDLE*>(provider.out()),
          MS_PLATFORM_CRYPTO_PROVIDER, 0) != ERROR_SUCCESS) {
    return false;  // no TPM, or TPM disabled
  }
  auto prov = static_cast<NCRYPT_PROV_HANDLE>(provider.get());
  auto* k = reinterpret_cast<NCRYPT_KEY_HANDLE*>(key.out());
  SECURITY_STATUS s = NCryptOpenKey(prov, k, kKeyName, 0, 0);
  if (s == ERROR_SUCCESS) return true;
  if (s != NTE_BAD_KEYSET) return false;
  if (NCryptCreatePersistedKey(prov, k, BCRYPT_RSA_ALGORITHM, kKeyName, 0,
                               0) != ERROR_SUCCESS) {
    return false;
  }
  DWORD bits = 2048;
  DWORD usage = NCRYPT_ALLOW_SIGNING_FLAG;
  if (NCryptSetProperty(*k, NCRYPT_LENGTH_PROPERTY,
                        reinterpret_cast<PBYTE>(&bits), sizeof(bits),
                        0) != ERROR_SUCCESS ||
      NCryptSetProperty(*k, NCRYPT_KEY_USAGE_PROPERTY,
                        reinterpret_cast<PBYTE>(&usage), sizeof(usage),
                        0) != ERROR_SUCCESS) {
    return false;
  }
  return NCryptFinalizeKey(*k, 0) == ERROR_SUCCESS;
}

std::optional<std::vector<uint8_t>> Mac(const std::vector<uint8_t>& data) {
  Handle provider, key;
  if (!OpenOrCreateKey(provider, key)) return std::nullopt;
  auto digest = Sha256(data.data(), data.size());
  if (!digest) return std::nullopt;

  auto k = static_cast<NCRYPT_KEY_HANDLE>(key.get());
  BCRYPT_PKCS1_PADDING_INFO pad{BCRYPT_SHA256_ALGORITHM};
  DWORD len = 0;
  if (NCryptSignHash(k, &pad, digest->data(), static_cast<DWORD>(digest->size()),
                     nullptr, 0, &len, BCRYPT_PAD_PKCS1) != ERROR_SUCCESS) {
    return std::nullopt;
  }
  std::vector<uint8_t> sig(len);
  if (NCryptSignHash(k, &pad, digest->data(), static_cast<DWORD>(digest->size()),
                     sig.data(), len, &len, BCRYPT_PAD_PKCS1) != ERROR_SUCCESS) {
    return std::nullopt;
  }
  sig.resize(len);
  return Sha256(sig.data(), sig.size());
}

// Deletes the key for good (the panic code). The next Mac call creates a
// new one, so vault files sealed under the old key stay closed forever.
bool DestroyKey() {
  Handle provider;
  if (NCryptOpenStorageProvider(
          reinterpret_cast<NCRYPT_PROV_HANDLE*>(provider.out()),
          MS_PLATFORM_CRYPTO_PROVIDER, 0) != ERROR_SUCCESS) {
    return true;  // no TPM: no key to delete
  }
  NCRYPT_KEY_HANDLE key = 0;
  SECURITY_STATUS s = NCryptOpenKey(
      static_cast<NCRYPT_PROV_HANDLE>(provider.get()), &key, kKeyName, 0, 0);
  if (s == NTE_BAD_KEYSET) return true;
  if (s != ERROR_SUCCESS) return false;
  // NCryptDeleteKey frees the handle when it succeeds
  if (NCryptDeleteKey(key, 0) == ERROR_SUCCESS) return true;
  NCryptFreeObject(key);
  return false;
}

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;

}  // namespace

void RegisterHardwareKeyChannel(flutter::BinaryMessenger* messenger) {
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "app.kilit.messenger/hardware_key",
      &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        if (call.method_name() == "level") {
          Handle provider, key;
          result->Success(flutter::EncodableValue(
              OpenOrCreateKey(provider, key) ? "tpm" : "none"));
        } else if (call.method_name() == "mac") {
          const auto* data =
              std::get_if<std::vector<uint8_t>>(call.arguments());
          if (data == nullptr) {
            result->Error("hardware_key", "bad arguments");
            return;
          }
          auto mac = Mac(*data);
          if (mac) {
            result->Success(flutter::EncodableValue(*mac));
          } else {
            result->Error("hardware_key", "TPM signing failed");
          }
        } else if (call.method_name() == "destroy") {
          if (DestroyKey()) {
            result->Success(flutter::EncodableValue(true));
          } else {
            result->Error("hardware_key", "TPM key deletion failed");
          }
        } else {
          result->NotImplemented();
        }
      });
}
