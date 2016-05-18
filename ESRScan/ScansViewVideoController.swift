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
    override func viewDidLoad() {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium

        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = try? AVCaptureDeviceInput(device: device)
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
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

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = imageView.bounds
        imageView.layer.addSublayer(previewLayer)

        session.startRunning()
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let image = imageFromSampleBuffer(sampleBuffer)
        //imageView.image = image
        
    }
}
