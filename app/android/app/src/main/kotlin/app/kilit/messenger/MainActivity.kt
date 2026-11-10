package app.kilit.messenger

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Screenshot blocking, which the user can turn off in Settings. */
private const val SCREEN_CHANNEL = "app.kilit.messenger/screen"

/**
 * Restarting Kilit: the embedded Tor runs once per process, so a Tor that
 * stopped comes back only in a new one.
 */
private const val APP_CHANNEL = "app.kilit.messenger/app"

class MainActivity : FlutterActivity() {
    private val main = Handler(Looper.getMainLooper())
    private var files: FilesChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        CrashLog.install(applicationContext)
        // no screenshots, no screen recording, a blank thumbnail in recents;
        // on from the first frame, until the settings say otherwise
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
        // a .klt or a KLT1: text handed to Kilit when it was not running
        if (savedInstanceState == null) files?.onIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        files?.onIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, HardwareKey.CHANNEL)
            .setMethodCallHandler { call, result -> HardwareKey.handle(call, result) { main.post(it) } }
        MethodChannel(messenger, SCREEN_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setSecure") {
                val on = call.arguments as? Boolean ?: true
                runOnUiThread {
                    if (on) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(messenger, APP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "lastExit") {
                result.success(CrashLog.lastExit(this))
            } else if (call.method == "restart") {
                val launch = packageManager.getLaunchIntentForPackage(packageName)
                val component = launch?.component
                if (component == null) {
                    result.success(false)
                } else {
                    result.success(true)
                    main.post {
                        startActivity(Intent.makeRestartActivityTask(component))
                        Runtime.getRuntime().exit(0)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
        val filesChannel = MethodChannel(messenger, FilesChannel.CHANNEL)
        files = FilesChannel(this, filesChannel).also { f ->
            filesChannel.setMethodCallHandler { call, result -> f.handle(call, result) }
        }
    }

    @Deprecated("FlutterActivity is not a ComponentActivity; the old API is the one it offers")
    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (files?.onActivityResult(requestCode, resultCode, data) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}

/**
 * Why Kilit closed last time, for the app to show: an uncaught Kotlin
 * exception is written to files/crash-android.log, and on Android 11 and
 * later the system says how the last process ended (a native crash, for
 * example, from the Rust core or the embedded Tor).
 */
object CrashLog {
    private const val FILE = "crash-android.log"
    private var installed = false

    fun install(context: Context) {
        if (installed) return
        installed = true
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, e ->
            try {
                val f = java.io.File(context.filesDir, FILE)
                if (f.length() > 64 * 1024) f.delete()
                f.appendText(
                    "android exception at ${System.currentTimeMillis() / 1000} on ${thread.name}: " +
                        android.util.Log.getStackTraceString(e).take(4000) + "\n",
                )
            } catch (_: Throwable) {
            }
            previous?.uncaughtException(thread, e)
        }
    }

    /** The last abnormal end of Kilit's process, or null. */
    fun lastExit(context: Context): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        val am = context.getSystemService(ActivityManager::class.java) ?: return null
        val info = am.getHistoricalProcessExitReasons(context.packageName, 0, 1).firstOrNull()
            ?: return null
        val reason = when (info.reason) {
            ApplicationExitInfo.REASON_CRASH -> "crash"
            ApplicationExitInfo.REASON_CRASH_NATIVE -> "native crash"
            ApplicationExitInfo.REASON_ANR -> "not responding"
            ApplicationExitInfo.REASON_INITIALIZATION_FAILURE -> "start failed"
            else -> return null
        }
        return "${info.timestamp / 1000} $reason: ${info.description ?: ""}"
    }
}
