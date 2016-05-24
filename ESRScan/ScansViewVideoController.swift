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
    @IBOutlet var previewView: UIImageView!

    var sessionQueue: dispatch_queue_t?
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var detector: CIDetector?

    override func viewDidLoad() {
        super.viewDidLoad()

        sessionQueue = dispatch_queue_create("SessionQueue", DISPATCH_QUEUE_SERIAL)
        session = AVCaptureSession()

        let options = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer!.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer!)

        dispatch_async(sessionQueue!, {
            self.setupSession()
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // http://stackoverflow.com/questions/5117770/avcapturevideopreviewlayer
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.bounds = previewView.bounds
        previewLayer!.position = CGPointMake(CGRectGetMidX(previewView.bounds), CGRectGetMidY(previewView.bounds))
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
        device.activeVideoMinFrameDuration = CMTimeMake(1, 10)
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

        //connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        let orientation = self.exifOrientation(connection.videoOrientation)
        let curOrientation = UIDevice.currentDevice().orientation

        let image = CIImageFromSampleBuffer(sampleBuffer)
        let options : [String: AnyObject]? = [CIDetectorImageOrientation: orientation]
        let features = self.detector?.featuresInImage(image, options: options)

        // get the clean aperture
        // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
        // that represents image data valid for display.
        let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false /*originIsTopLeft == false*/);

        dispatch_async(dispatch_get_main_queue(), {
            self.drawStuff(features, cleanAperture: cleanAperture, orientation: curOrientation)
        })
    }

    func videoPreviewBoxForGravity(gravity: String, frameSize: CGSize, apertureSize: CGSize) -> CGRect {
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height

        var size = CGSizeZero
        if (gravity == AVLayerVideoGravityResizeAspectFill) {
            if (viewRatio > apertureRatio) {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            } else {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            }
        } else if (gravity == AVLayerVideoGravityResizeAspect) {
            if (viewRatio > apertureRatio) {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            } else {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            }
        } else if (gravity == AVLayerVideoGravityResize) {
            size.width = frameSize.width
            size.height = frameSize.height
        }

        var videoBox = CGRect()
        videoBox.size = size
        if size.width < frameSize.width {
            videoBox.origin.x = (frameSize.width - size.width) / 2
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2
        }

        if size.height < frameSize.height {
            videoBox.origin.y = (frameSize.height - size.height) / 2
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2
        }
        
        return videoBox
    }

    func drawStuff(features: [CIFeature]?, cleanAperture: CGRect, orientation: UIDeviceOrientation) {
        guard let previewLayer = self.previewLayer else {
            return
        }
        let sublayers = previewLayer.sublayers

        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)

        for layer in sublayers! {
            if layer.name != nil && layer.name == "RectLayer" {
                layer.hidden = true
            }
        }

        guard let features = features else {
            return
        }
        guard features.count > 0 else {
            CATransaction.commit()
            return
        }

        let parentFrameSize = previewView.frame.size
        let gravity = previewLayer.videoGravity
        let isMirrored = previewLayer.connection.videoMirrored

        let previewBox = self.videoPreviewBoxForGravity(gravity, frameSize: parentFrameSize, apertureSize: cleanAperture.size)

        for feature in features {
            var rect = feature.bounds

            var temp = rect.size.width
            rect.size.width = rect.size.height;
            rect.size.height = temp;

            temp = rect.origin.x;
            rect.origin.x = rect.origin.y;
            rect.origin.y = temp;

            // scale coordinates so they fit in the preview box, which may be scaled
            let widthScaleBy = previewBox.size.width / cleanAperture.size.height;
            let heightScaleBy = previewBox.size.height / cleanAperture.size.width;

            rect.size.width *= widthScaleBy;
            rect.size.height *= heightScaleBy;
            rect.origin.x *= widthScaleBy;
            rect.origin.y *= heightScaleBy;

            if isMirrored {
                rect = CGRectOffset(rect, previewBox.origin.x + previewBox.size.width - rect.size.width - (rect.origin.x * 2), previewBox.origin.y)
            } else {
                rect = CGRectOffset(rect, previewBox.origin.x, previewBox.origin.y);
            }

            var featureLayer : CALayer?

            for layer in sublayers! {
                if layer.name == "RectLayer" {
                    featureLayer = layer
                    layer.hidden = false
                }
            }

            if featureLayer == nil {
                featureLayer = CALayer()
                featureLayer!.borderColor = UIColor.redColor().CGColor
                featureLayer!.borderWidth = 2
                featureLayer!.name = "RectLayer"
                previewLayer.addSublayer(featureLayer!)
            }
            featureLayer!.frame = rect

            switch(orientation) {
            case UIDeviceOrientation.Portrait:
                featureLayer!.setAffineTransform(CGAffineTransformMakeRotation(radians(0)))
                break
            case UIDeviceOrientation.PortraitUpsideDown:
                featureLayer!.setAffineTransform(CGAffineTransformMakeRotation(radians(180)))
                break
            case UIDeviceOrientation.LandscapeLeft:
                featureLayer!.setAffineTransform(CGAffineTransformMakeRotation(radians(90)))
                break
            case UIDeviceOrientation.LandscapeRight:
                featureLayer!.setAffineTransform(CGAffineTransformMakeRotation(radians(-90)))
                break
            default:
                break
            }
        }
        CATransaction.commit()
    }

    func exifOrientation(orientation: AVCaptureVideoOrientation) -> Int {
        switch orientation {
        case AVCaptureVideoOrientation.LandscapeLeft:
            return 1
        case AVCaptureVideoOrientation.LandscapeRight:
            return 3
        case AVCaptureVideoOrientation.Portrait:
            return 7
        case AVCaptureVideoOrientation.PortraitUpsideDown:
            return 8
        }
    }
}
