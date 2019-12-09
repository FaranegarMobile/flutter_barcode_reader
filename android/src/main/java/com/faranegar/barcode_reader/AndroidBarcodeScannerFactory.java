package com.faranegar.barcode_reader;

import android.app.Activity;
import android.content.Context;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AndroidBarcodeScannerFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;
    private Activity activity;


    public AndroidBarcodeScannerFactory(BinaryMessenger messenger, Activity activity) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.activity = activity;
    }

    @Override
    public PlatformView create(Context context, int id, Object o) {
        return new AndroidBarcodeScannerView(activity, messenger, id);
    }
}
