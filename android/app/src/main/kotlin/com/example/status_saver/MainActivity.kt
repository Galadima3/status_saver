package com.example.status_saver

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "status_saver/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "shareToWhatsApp") {
                    val args = call.arguments as Map<*, *>
                    val filePath = args["stream"] as String
                    val text = args["extra_text"] as String
                    val type = args["type"] as String

                    try {
                        val file = File(Uri.parse(filePath).path!!)
                        val uri: Uri = FileProvider.getUriForFile(
                            this,
                            "$packageName.fileprovider",
                            file
                        )

                        val intent = Intent(Intent.ACTION_SEND).apply {
                            this.type = type
                            setPackage("com.whatsapp")
                            putExtra(Intent.EXTRA_STREAM, uri)
                            putExtra(Intent.EXTRA_TEXT, text)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        startActivity(intent)
                        result.success(true)

                    } catch (e: ActivityNotFoundException) {
                        // WhatsApp not installed
                        result.error(
                            "WHATSAPP_NOT_INSTALLED",
                            "WhatsApp is not installed on this device",
                            null
                        )
                    } catch (e: Exception) {
                        result.error(
                            "WHATSAPP_SHARE_ERROR",
                            "Failed to share to WhatsApp",
                            e.localizedMessage
                        )
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
