package app.kilit.messenger

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.util.concurrent.Executors
import javax.crypto.KeyGenerator
import javax.crypto.Mac
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory

/**
 * The PIN's hardware key: an HMAC-SHA256 key generated inside StrongBox (or
 * the TEE when the phone has no StrongBox) that can be used but never read
 * out. The vault is sealed under HMAC(key, PIN) stretched by Argon2id, so a
 * copy of the app's files cannot be attacked anywhere but on this phone.
 *
 * Not set on purpose: setUnlockedDeviceRequired and user authentication.
 * Both can make Android invalidate the key (a changed or removed screen
 * lock), and a lost key is a lost vault.
 */
object HardwareKey {
    const val CHANNEL = "app.kilit.messenger/hardware_key"
    private const val ALIAS = "kilit-pin-hmac-v1"
    private const val STORE = "AndroidKeyStore"

    // Keystore calls can block for tens of milliseconds on StrongBox
    private val worker = Executors.newSingleThreadExecutor()

    private fun existing(): SecretKey? {
        val ks = KeyStore.getInstance(STORE).apply { load(null) }
        return (ks.getEntry(ALIAS, null) as? KeyStore.SecretKeyEntry)?.secretKey
    }

    private fun generate(strongBox: Boolean): SecretKey {
        val spec = KeyGenParameterSpec.Builder(ALIAS, KeyProperties.PURPOSE_SIGN)
        if (strongBox && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            spec.setIsStrongBoxBacked(true)
        }
        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_HMAC_SHA256, STORE)
            .apply { init(spec.build()) }
            .generateKey()
    }

    @Synchronized
    private fun key(): SecretKey = existing() ?: if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        // StrongBoxUnavailableException exists only from API 28, so it is
        // caught by its supertype
        try {
            generate(strongBox = true)
        } catch (e: java.security.ProviderException) {
            generate(strongBox = false)
        }
    } else {
        generate(strongBox = false)
    }

    /** Where the key lives: "strongbox", "tee" or "software". */
    private fun level(k: SecretKey): String {
        val info = SecretKeyFactory.getInstance(k.algorithm, STORE)
            .getKeySpec(k, KeyInfo::class.java) as KeyInfo
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return when (info.securityLevel) {
                KeyProperties.SECURITY_LEVEL_STRONGBOX -> "strongbox"
                KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT -> "tee"
                else -> "software"
            }
        }
        @Suppress("DEPRECATION")
        return if (info.isInsideSecureHardware) "tee" else "software"
    }

    private fun mac(data: ByteArray): ByteArray =
        Mac.getInstance("HmacSHA256").run {
            init(key())
            doFinal(data)
        }

    fun handle(call: MethodCall, result: MethodChannel.Result, post: (Runnable) -> Unit) {
        worker.execute {
            try {
                val reply: Any = when (call.method) {
                    "level" -> level(key())
                    "mac" -> mac(call.arguments as ByteArray)
                    else -> {
                        post { result.notImplemented() }
                        return@execute
                    }
                }
                post { result.success(reply) }
            } catch (e: Exception) {
                // the message names the failing call only, never key or PIN bytes
                post { result.error("hardware_key", e.javaClass.simpleName, null) }
            }
        }
    }
}
