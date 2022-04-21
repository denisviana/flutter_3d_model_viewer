package com.example.flutter_3d_model_viewer

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

internal abstract class FlutterMethodCallHandler :
    MethodCallHandler {

    companion object {

        fun <T : Any> getOptionalArgument(
            call: MethodCall?,
            name: String?,
        ): T? {
            return getOptionalArgument(call, name, null as T?)
        }

        private fun <T> getOptionalArgument(
            call: MethodCall?,
            name: String?,
            defaultValue: T?,
        ): T? {
            assert(call != null)
            assert(name != null)
            return if (call!!.hasArgument(name) && call.argument<Any?>(name) != null) call.argument<Any>(
                name) as T? else defaultValue
        }
    }
}