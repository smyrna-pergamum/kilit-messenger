package app.kilit.messenger

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val main = Handler(Looper.getMainLooper())
    private var files: FilesChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // no screenshots, no screen recording, a blank thumbnail in recents
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
