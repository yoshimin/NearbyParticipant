//
//  CaptureVideoPreview.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/22.
//

import SwiftUI
import AVFoundation

struct CaptureVideoPreview: UIViewControllerRepresentable {
    typealias UIViewControllerType = CaptureVideoPreviewController

    func makeUIViewController(context: Context) -> CaptureVideoPreviewController {
        return CaptureVideoPreviewController()
    }

    func updateUIViewController(_ uiViewController: CaptureVideoPreviewController, context: Context) {

    }
}

class CaptureVideoPreviewController: UIViewController {
    var preview: UIView?

    let shapeLayer = CAShapeLayer()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let mediaType: AVMediaType = .video

    var session: AVCaptureSession = AVCaptureSession()
    var devicePosition: AVCaptureDevice.Position = .back
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        preview = UIView()
        view.addSubview(preview!)

        setupSession()
        setupPreview()
        setupShapeLayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
        previewLayer?.frame = preview!.bounds
        shapeLayer.frame = view.bounds
    }

    func setupSession() {
        guard let device = findDevice(position: devicePosition),
            let input = try? AVCaptureDeviceInput(device: device) else {
                return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.startRunning()
    }

    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let previewLayer = previewLayer else {
            return
        }

        previewLayer.videoGravity = .resizeAspectFill
        preview?.layer.addSublayer(previewLayer)
    }

    func findDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: mediaType, position: position)
    }

    func setupShapeLayer() {
        view.layer.addSublayer(shapeLayer)
    }
}
