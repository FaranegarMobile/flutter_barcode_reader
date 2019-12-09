package com.faranegar.barcode_reader;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** BarcodeReaderPlugin */
public class BarcodeReaderPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
//    final MethodChannel channel = new MethodChannel(registrar.messenger(), "barcode_reader");
//    channel.setMethodCallHandler(new BarcodeReaderPlugin());


//    PluginRegistry.Registrar registrar = register.registrarFor("com.faranegar/androidbarcodescanner");

    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "com.faranegar/androidbarcodescanner"
                    , new AndroidBarcodeScannerFactory(registrar.messenger(),  registrar.activity()));
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
