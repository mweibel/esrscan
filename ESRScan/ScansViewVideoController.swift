//
//  ScansViewVideoController.swift
//  ESRScan
//
//  Created by Michael on 17/05/16.
//  Copyright © 2016 Michael Weibel. All rights reserved.
//


import UIKit
import AVFoundation

class ScansViewVideoController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var previewView: UIImageView!

    var sessionQueue: dispatch_queue_t?
    var session: AVCaptureSession?

    override func viewDidLoad() {
        sessionQueue = dispatch_queue_create("SessionQueue", DISPATCH_QUEUE_SERIAL)
        session = AVCaptureSession()

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)

        super.viewDidLoad()

        dispatch_async(sessionQueue!, {
            self.setupSession()
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        dispatch_async(sessionQueue!, {
            self.session!.startRunning()
        })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        dispatch_async(sessionQueue!, {
            self.session!.stopRunning()
        })
    }

    func setupSession() {
        guard let session = session else {
            return
        }
        session.beginConfiguration()

        session.sessionPreset = AVCaptureSessionPresetMedium

        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        try? device.lockForConfiguration()
        device.activeVideoMinFrameDuration = CMTimeMake(1, 15)
        device.unlockForConfiguration()

        let input = try? AVCaptureDeviceInput(device: device)
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
        session.addOutput(output)

        let queue = dispatch_queue_create("VideoOutput", nil)
        output.setSampleBufferDelegate(self, queue: queue)

        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { granted in
            if !granted {
                dispatch_async(dispatch_get_main_queue(), {
                    UIAlertView(title: "Video", message: "ESRScan doesn't have permission to use Camera, please change privacy settings", delegate: self, cancelButtonTitle: "OK").show()
                })
            }
        })

        session.commitConfiguration()
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        dispatch_sync(dispatch_get_main_queue(), {
            let image = imageFromSampleBuffer(sampleBuffer)
            self.imageView.image = adaptiveThreshold(image)
        })
    }
}
