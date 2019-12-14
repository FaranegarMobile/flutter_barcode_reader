package com.faranegar.barcode_reader;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * BarcodeReaderPlugin
 */
public class BarcodeReaderPlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        if (registrar.activity() != null)
            registrar
                    .platformViewRegistry()
                    .registerViewFactory(
                            "com.faranegar/androidbarcodescanner"
                            , new AndroidBarcodeScannerFactory(registrar.messenger(), registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }
}
