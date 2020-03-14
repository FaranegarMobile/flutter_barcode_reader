import Flutter
import UIKit

@available(iOS 9.0, *)
public class SwiftBarcodeReaderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "barcode_reader", binaryMessenger: registrar.messenger())
    let instance = SwiftBarcodeReaderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    
    let nativeViewFactory = NativeViewFactory()
    
    
    registrar.register(nativeViewFactory, withId: "com.faranegar/androidbarcodescanner")
    
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
