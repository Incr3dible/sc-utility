package com.tamedia.sc_utility

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.BufferedReader

class MainActivity: FlutterActivity() {
    private val CHANNEL = "supercell.util.command"
    private val asyncWork: AsyncWork? = AsyncWork()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
                    // Note: this method is invoked on the main thread.
                    if (call!!.method == "executeRootCommand") {
                        executeRootCommandAsync(call.argument("args"), object : CommandCallback {
                            val activity = getActivity()
                            override fun onCommandResultAvailable(cr: String?) {
                                if (!activity.isFinishing) {
                                    activity.runOnUiThread { result?.success(cr) }
                                }
                            }
                        })
                    }
                    else if (call.method == "executeCommand") {
                        val commandResult: String? = executeCommand(call.argument("args"))
                        if (commandResult != null) {
                            result!!.success(commandResult)
                        } else {
                            result!!.error("ERROR", "Command " + call.argument("args") + " hasn't been executed", null)
                        }
                    }
                }
    }

    private fun executeRootCommandAsync(command: String?, callback: CommandCallback?) {
        asyncWork?.run(Runnable {
            val commandResult: String? = executeRootCommand(command)
            if (callback != null) {
                callback.onCommandResultAvailable(commandResult)
            }
        })
    }

    private fun executeRootCommand(command: String?) : String? {
        return try {
            val p = Runtime.getRuntime().exec("su -c $command")
            p.inputStream.bufferedReader().use(BufferedReader::readText)
        }
        catch(e: Exception){
            //e.message
            "Failed to execute root command."
        }
    }

    private fun executeCommand(command: String?) : String? {
        return try {
            val p = Runtime.getRuntime().exec(command)
            p.inputStream.bufferedReader().use(BufferedReader::readText)
        }
        catch(e: Exception){
            e.message
        }
    }
}
