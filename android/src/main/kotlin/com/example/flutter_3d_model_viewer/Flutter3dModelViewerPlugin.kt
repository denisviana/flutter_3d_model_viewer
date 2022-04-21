package com.example.flutter_3d_model_viewer

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import com.example.flutter_3d_model_viewer.FlutterMethodCallHandler.Companion.getOptionalArgument

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.Serializable

/** Flutter3dModelViewerPlugin */
class Flutter3dModelViewerPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext;
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_android/Intent")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        assert(call.method != null)
        when (call.method) {
            "startActivity" -> {
                val action: String? = getOptionalArgument(call, "action")
                val data: String? = getOptionalArgument(call, "data")
                val categories: List<String>? = getOptionalArgument(call, "categories")
                val type: String? = getOptionalArgument(call, "type")
                val component: String? = getOptionalArgument(call, "component")
                val extras: Map<String?, Any?>? = getOptionalArgument(call, "extras")
                val flags: Int? = getOptionalArgument(call, "flags")
                val packageName: String? = getOptionalArgument(call, "package")
                val intent = Intent()
                if (action?.isNotEmpty() == true) {
                    intent.action = action
                }
                intent.setDataAndTypeAndNormalize(Uri.parse(data), type)
                if (categories != null) {
                    for (category in categories) {
                        if (category.isNotEmpty()) {
                            intent.addCategory(category)
                        }
                    }
                }
                if (component?.isNotEmpty() == true) {
                    intent.component = component.let { ComponentName.unflattenFromString(it) }
                }
                if (extras != null) {
                    for ((key, value) in extras) {
                        if (value is Serializable) {
                            intent.putExtra(key, value as Serializable?)
                        }
                    }
                }
                if (flags != null) {
                    intent.addFlags(flags)
                }
                if (packageName?.isNotEmpty() == true) {
                    intent.setPackage(packageName)
                }
                try {
                    context.startActivity(intent)
                    result.success(true)
                } catch (error: ActivityNotFoundException) {
                    result.success(false)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
