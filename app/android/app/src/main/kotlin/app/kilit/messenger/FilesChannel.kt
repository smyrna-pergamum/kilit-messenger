package app.kilit.messenger

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

/**
 * Files in and out through Android's Storage Access Framework, read and
 * written as streams. Unlike a picker plugin it never copies the chosen
 * file into the app's cache, so no plaintext copy is left on disk.
 *
 * Also takes what other apps hand Kilit: a `.klt` opened from a file
 * manager (ACTION_VIEW), or a file or text shared to it (ACTION_SEND), such
 * as a `KLT1:` message shared from WhatsApp.
 */
class FilesChannel(private val activity: Activity, private val channel: MethodChannel) {
    companion object {
        const val CHANNEL = "app.kilit.messenger/files"
        private const val PICK = 4101
        private const val SAVE = 4102

        /** The vault's file limit (kilit-ffi MAX_FILE_BYTES) plus room for a header. */
        const val MAX_BYTES = 64L * 1024 * 1024 + 64 * 1024
    }

    private val main = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private var pending: MethodChannel.Result? = null
    private var toSave: ByteArray? = null
    private var incoming: Map<String, Any>? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pick" -> {
                if (!begin(result)) return
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
                    .addCategory(Intent.CATEGORY_OPENABLE)
                    .setType("*/*")
                activity.startActivityForResult(intent, PICK)
            }
            "save" -> {
                if (!begin(result)) return
                toSave = call.argument<ByteArray>("bytes")
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
                    .addCategory(Intent.CATEGORY_OPENABLE)
                    .setType(call.argument<String>("mime") ?: "application/octet-stream")
                    .putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: "kilit.klt")
                activity.startActivityForResult(intent, SAVE)
            }
            "shareText" -> {
                // the system share sheet: WhatsApp, Telegram, Signal, mail...
                // Only the KLT1: ciphertext ever comes here.
                val send = Intent(Intent.ACTION_SEND)
                    .setType("text/plain")
                    .putExtra(Intent.EXTRA_TEXT, call.arguments as String)
                activity.startActivity(Intent.createChooser(send, null))
                result.success(null)
            }
            "openAppSettings" -> {
                // Kilit's page in Android settings, where the user grants or
                // revokes its permissions
                activity.startActivity(
                    Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        .setData(Uri.fromParts("package", activity.packageName, null)),
                )
                result.success(null)
            }
            "takeIncoming" -> {
                result.success(incoming)
                incoming = null
            }
            else -> result.notImplemented()
        }
    }

    private fun begin(result: MethodChannel.Result): Boolean {
        if (pending != null) {
            result.error("files", "busy", null)
            return false
        }
        pending = result
        return true
    }

    private fun finish(block: (MethodChannel.Result) -> Unit) {
        val r = pending ?: return
        pending = null
        main.post { block(r) }
    }

    /** Returns true when the result was one of ours. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK && requestCode != SAVE) return false
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            toSave = null
            finish { it.success(null) }
            return true
        }
        worker.execute {
            try {
                if (requestCode == PICK) {
                    val file = read(uri)
                    finish { it.success(file) }
                } else {
                    val bytes = toSave ?: ByteArray(0)
                    toSave = null
                    activity.contentResolver.openOutputStream(uri, "wt").use { out ->
                        requireNotNull(out).write(bytes)
                    }
                    finish { it.success(true) }
                }
            } catch (e: TooLarge) {
                finish { it.error("files", "too_large", null) }
            } catch (e: Exception) {
                finish { it.error("files", e.javaClass.simpleName, null) }
            }
        }
        return true
    }

    private class TooLarge : Exception()

    /** Name, media type and bytes of a content URI, refusing anything over [MAX_BYTES]. */
    private fun read(uri: Uri): Map<String, Any> {
        var name = "dosya"
        activity.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE), null, null, null)
            ?.use { c ->
                if (c.moveToFirst()) {
                    c.getString(0)?.let { name = it }
                    if (!c.isNull(1) && c.getLong(1) > MAX_BYTES) throw TooLarge()
                }
            }
        val mime = activity.contentResolver.getType(uri) ?: "application/octet-stream"
        val out = ByteArrayOutputStream()
        activity.contentResolver.openInputStream(uri).use { input ->
            val buf = ByteArray(64 * 1024)
            var total = 0L
            while (true) {
                val n = requireNotNull(input).read(buf)
                if (n < 0) break
                total += n
                if (total > MAX_BYTES) throw TooLarge()
                out.write(buf, 0, n)
            }
        }
        return mapOf("name" to name, "mime" to mime, "bytes" to out.toByteArray())
    }

    /** Takes a VIEW or SEND intent from another app, then tells Dart. */
    fun onIntent(intent: Intent?) {
        intent ?: return
        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(Intent.EXTRA_STREAM)
            }
            else -> null
        }
        val text = if (intent.action == Intent.ACTION_SEND) intent.getStringExtra(Intent.EXTRA_TEXT) else null
        if (uri == null && text == null) return
        worker.execute {
            val got: Map<String, Any>? = try {
                if (uri != null) read(uri) else mapOf("text" to requireNotNull(text))
            } catch (e: Exception) {
                null
            }
            main.post {
                incoming = got
                if (got != null) channel.invokeMethod("incomingReady", null)
            }
        }
    }
}
