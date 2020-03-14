package com.faranegar.barcode_reader;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.hardware.Camera;
import android.util.Base64;
import android.view.View;

import com.google.zxing.Result;

import java.util.ArrayList;

import helperwix.BarcodeScanner2;
import helperwix.CameraView2;
import helperwix.CameraViewManager2;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;

class AndroidBarcodeScannerView implements PlatformView, MethodCallHandler, Camera.PictureCallback {
    private final CameraView2 view;
    private final CameraViewManager2 cameraManager;
    private final MethodChannel methodChannel;
    private ArrayList<Integer> mSelectedIndices;
    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Do your stuff here

            methodChannel.invokeMethod("barcodeRead", intent.getExtras().getString("Barcode"));
        }
    };
    private MethodChannel.Result result;


    AndroidBarcodeScannerView(Activity activity, BinaryMessenger messenger, int id) {
        cameraManager = new CameraViewManager2();
        view = cameraManager.createViewInstance(activity, new BarcodeScanner2.ResultHandler() {
            @Override
            public void handleResult(Result result) {
                methodChannel.invokeMethod("barcodeRead", result.getText());
            }
        });

        methodChannel = new MethodChannel(messenger, "com.faranegar/androidbarcodescanner_" + id);
        methodChannel.setMethodCallHandler(this);
    }


    @Override
    public View getView() {
        return view;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        switch (methodCall.method) {
            case "initCamera":
                initCamera(methodCall, result);
                break;
            case "pauseCamera":
                pauseCamera(methodCall, result);
                break;
            case "resumeCamera":
                resumeCamera(methodCall, result);
                break;
            case "takePicture":
                takePicture(methodCall, result);
                break;
            default:
                result.notImplemented();
        }

    }

    private void takePicture(MethodCall methodCall, MethodChannel.Result result) {
        this.result = result;
        view.takePicture(this);
    }

    private void resumeCamera(MethodCall methodCall, MethodChannel.Result result) {
//        view.resumeScanning();
        CameraViewManager2.setCameraView(view);
    }

    private void pauseCamera(MethodCall methodCall, MethodChannel.Result result) {
        CameraViewManager2.removeCameraView();
        result.success(null);
    }

    private void initCamera(MethodCall methodCall, MethodChannel.Result result) {

//        view.setId(R.id.zxing_view);

//        fullScannerFragment = new AndroidViewScannerFragment();
//        fullScannerFragment.setResultHandlerListener(new ZXingScannerView.ResultHandler() {
//            @Override
//            public void handleResult(Result rawResult) {
//                activity.runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        methodChannel.invokeMethod("barcodeRead", rawResult.getText());
//                    }
//                });
//
//            }
//        });
//
////        fullScannerFragment.show(activity.getFragmentManager(), "");
//        FragmentTransaction transaction = activity.getFragmentManager().beginTransaction();
//        transaction.add(android.R.id.content, fullScannerFragment, "FragmentBarcode");
//        transaction.commit();


//        Intent intent = new Intent(activity, SimpleScannerActivity.class);
//        activity.startActivity(intent);


//        view.setFlash(false);
//        view.setAutoFocus(true);
//
//        view.setResultHandler(new ZXingScannerViewCustom.ResultHandler() {
//            @Override
//            public void handleResult(Result rawResult) {
//                activity.runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        methodChannel.invokeMethod("barcodeRead", rawResult.getText());
//                    }
//                });
//            }
//        });
//        view.startCamera();


        result.success(null);

    }


    @Override
    public void dispose() {
    }


    @Override
    public void onPictureTaken(byte[] data, Camera camera) {
        result.success(Base64.encodeToString(data, Base64.DEFAULT));
    }
}
