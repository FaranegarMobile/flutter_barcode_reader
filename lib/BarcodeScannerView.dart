import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//typedef void TextViewCreatedCallback(BarcodeController controller);

class BarcodeScannerView extends StatefulWidget {
//  MainModel model;
  Function onBarcodeRead;

  _BarcodeScannerViewState viewState;

  BarcodeScannerView({Key key, this.onBarcodeRead}) : super(key: key);

//  TextViewCreatedCallback onWidgetCreated;

  Future<String> takePicture() {
    return viewState.controller.takePicture();
  }

  @override
  State<StatefulWidget> createState() {
    viewState = _BarcodeScannerViewState();
    return viewState;
  }
}

class _BarcodeScannerViewState extends State<BarcodeScannerView>
    with WidgetsBindingObserver {
  BarcodeController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.faranegar/androidbarcodescanner',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'com.faranegar/androidbarcodescanner',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Handle this case
        print("Flutter Life Cycle: resumed");
        controller.resumeCamera();
        break;
      case AppLifecycleState.inactive:
        // Handle this case
        print("Flutter Life Cycle: inactive");
        break;
      case AppLifecycleState.paused:
        // Handle this case
        print("Flutter Life Cycle: paused");
        controller.pauseCamera();
        break;
      default:
        break;
//      case AppLifecycleState.suspending:
//        print("Flutter Life Cycle: suspending");
//        // Handle this case
//        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    this.controller =
        new BarcodeController._(id, context, widget.onBarcodeRead);
    this.controller.initCamera();
//    widget.onWidgetCreated(controller);

    //controller.initCamera();
  }
}

class BarcodeController {
  BuildContext context;
  Function onBarcodeRead;

  BarcodeController._(int id, this.context, this.onBarcodeRead)
      : _channel = new MethodChannel('com.faranegar/androidbarcodescanner_$id');

  final MethodChannel _channel;

  Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    print("Flutter barcode read: " + methodCall.arguments);
    if (onBarcodeRead != null) onBarcodeRead(methodCall.arguments);
    return null;
  }

  void initCamera() async {
    _channel.setMethodCallHandler(myUtilsHandler);
    print("Flutter camera init successfully");
  }

  Future<String> takePicture() async {
     return _channel.invokeMethod('takePicture');
  }

  Future<void> resumeCamera() async {
    return _channel.invokeMethod('resumeCamera');
  }

  Future<void> pauseCamera() async {
    return _channel.invokeMethod('pauseCamera');
//    return Future(Future(computation);
  }


}
