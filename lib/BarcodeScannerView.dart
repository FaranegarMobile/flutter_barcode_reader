import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//typedef void TextViewCreatedCallback(BarcodeController controller);

class BarcodeScannerView extends StatefulWidget {
//  MainModel model;
  Function onBarcodeRead;
  BarcodeScannerView({
    Key key,
    this.onBarcodeRead
  }) : super(key: key);

//  TextViewCreatedCallback onWidgetCreated;

  @override
  State<StatefulWidget> createState() => _BarcodeScannerViewState();
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
        //controller.initCamera();
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
    this.controller = new BarcodeController._(id, context, widget.onBarcodeRead);
//    widget.onWidgetCreated(controller);

  controller.initCamera();
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
    if(onBarcodeRead != null)
      onBarcodeRead(methodCall.arguments);
    return null;
  }

  Future<void> initCamera() async {
    _channel.setMethodCallHandler(myUtilsHandler);
    return _channel.invokeMethod('initCamera');
  }

  Future<void> resumeCamera() async {
    _channel.setMethodCallHandler(myUtilsHandler);
    return _channel.invokeMethod('resumeCamera');
  }

  Future<void> pauseCamera() async {
    return _channel.invokeMethod('pauseCamera');
//    return Future(Future(computation);
  }
}
