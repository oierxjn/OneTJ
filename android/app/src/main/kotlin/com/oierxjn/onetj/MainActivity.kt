package com.oierxjn.onetj

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_UPDATE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CAN_INSTALL_PACKAGES -> {
                    result.success(canInstallPackages())
                }

                METHOD_INSTALL_APK -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error(
                            "INVALID_ARGUMENT",
                            "APK file path is required",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    installApk(filePath, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun installApk(
        filePath: String,
        result: MethodChannel.Result,
    ) {
        val apkFile = File(filePath)
        if (!apkFile.exists()) {
            result.error(
                "FILE_NOT_FOUND",
                "Downloaded APK does not exist",
                filePath,
            )
            return
        }

        if (!canInstallPackages()) {
            val settingsIntent = Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:$packageName"),
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(settingsIntent)
            result.success(
                mapOf(
                    "status" to "permission_required",
                ),
            )
            return
        }

        val contentUri = FileProvider.getUriForFile(
            this,
            "$packageName.appupdate.fileprovider",
            apkFile,
        )
        val installIntent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            setData(contentUri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra(Intent.EXTRA_RETURN_RESULT, false)
        }

        try {
            startActivity(installIntent)
            result.success(
                mapOf(
                    "status" to "installer_started",
                ),
            )
        } catch (error: ActivityNotFoundException) {
            result.error(
                "INSTALLER_NOT_FOUND",
                "No package installer found on this device",
                error.message,
            )
        } catch (error: Exception) {
            result.error(
                "INSTALLER_START_FAILED",
                "Failed to start Android package installer",
                error.message,
            )
        }
    }

    companion object {
        private const val APP_UPDATE_CHANNEL = "onetj/app_update"
        private const val METHOD_CAN_INSTALL_PACKAGES = "canInstallPackages"
        private const val METHOD_INSTALL_APK = "installApk"
    }

    private fun canInstallPackages(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            packageManager.canRequestPackageInstalls()
    }
}
