//
//  NativeViewFactory.swift
//  barcode_reader
//
//  Created by faranegar on 12/15/19.
//

import Foundation
import UIKit
import AVFoundation

@available(iOS 9.0, *)
class NativeViewFactory : NSObject, FlutterPlatformViewFactory {
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeView(frame, viewId:viewId, args:args)
    }
}

@available(iOS 9.0, *)
public class NativeView : NSObject, FlutterPlatformView, AVCaptureMetadataOutputObjectsDelegate, QRScannerViewDelegate {
    
    let frame : CGRect
    let viewId : Int64
    
    let scannerView = QRScannerView()
    let scanButton = UIButton()
    let barcodeLabel = UILabel()

    init(_ frame:CGRect, viewId:Int64, args: Any?){
        self.frame = frame
        self.viewId = viewId
    }
    
    public func view() -> UIView {
        let view = UIView()
        setupViews(view: view)
        return view
    }
    
    func setupViews(view: UIView) {
        scannerView.delegate = self
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scannerView)
        scannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scannerView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        scannerView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0.1).isActive = true
        scannerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scannerView.layer.connection?.videoOrientation = .portrait
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
        
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanButton)
        scanButton.backgroundColor = .black
        scanButton.setTitle("Stop", for: .normal)
        scanButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        scanButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        scanButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scanButton.addTarget(self, action: #selector(scanButtonAction(_:)), for: .touchUpInside)
        
        barcodeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barcodeLabel)
        barcodeLabel.text = "_________"
        barcodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        barcodeLabel.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20).isActive = true
        barcodeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        barcodeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        barcodeLabel.textAlignment = .center
        barcodeLabel.numberOfLines = 0
    }
    
    @objc func scanButtonAction(_ sender: UIButton){
        scannerView.isRunning ? scannerView.stopScanning() : scannerView.startScanning()
        let buttonTitle = scannerView.isRunning ? "Stop" : "Scan"
        sender.setTitle(buttonTitle, for: .normal)
        barcodeLabel.text = ""
    }
    
    func qrScanningDidStop() {
        barcodeLabel.text = "stop"
    }
    
    func qrScanningDidFail() {
        barcodeLabel.text = "Failed to scan"
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        //ToDo shokouhi
        barcodeLabel.text = str
    }
}









protocol QRScannerViewDelegate: class {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

class QRScannerView: UIView {
    
    weak var delegate: QRScannerViewDelegate?
    
    /// capture settion which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?
    
    // Init methods..
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitialSetup()
    }
    
    //MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.
    override class var layerClass: AnyClass  {
        return AVCaptureVideoPreviewLayer.self
    }
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
}

extension QRScannerView {
    
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }
    
    func startScanning() {
       captureSession?.startRunning()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.qrScanningDidStop()
    }
    
    /// Does the initial setup for captureSession
    private func doInitialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.aztec, .code128, .code39, .code39Mod43, .code93, .dataMatrix, .ean13, .ean13, .ean8 , .interleaved2of5, .itf14, .pdf417, .qr, .upce]
        } else {
            scanningDidFail()
            return
        }
        
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        
        captureSession?.startRunning()
    }
    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }
    
    func found(code: String) {
        delegate?.qrScanningSucceededWithCode(code)
    }
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
       // stopScanning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
}
