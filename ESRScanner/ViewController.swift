//
//  ViewController.swift
//  einzahlungsschein
//
//  Created by Michael on 30.10.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR
import GPUImage

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, G8TesseractDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    var activityIndicator: UIActivityIndicatorView!

    func performImageRecognition(image: UIImage) {
        print("PROCESSING")
        let tesseract = G8Tesseract.init(language: "eng")
        assert(tesseract.engineConfigured)
        tesseract.delegate = self;
        tesseract.charWhitelist = "0123456789<>+";
        tesseract.engineMode = .TesseractOnly
        tesseract.pageSegmentationMode = .AutoOSD
        tesseract.image = image
        tesseract.setVariableValue("0123456789<>+", forKey: "tessedit_char_whitelist")

        tesseract.recognize()
        imageView.image = tesseract.thresholdedImage

        let text = tesseract.recognizedText
        print(text)
        let textArr = text.componentsSeparatedByString("\n").filter{ $0.containsString(">") }
        if textArr.count > 0 {
            let esrCode = ESR.init(str: textArr[0])
            textView.text.appendContentsOf(esrCode.string())
            textView.text.appendContentsOf("\n\n----\n\n")
        }

        removeActivityIndicator()
    }

    func progressImageRecognitionForTesseract(tesseract : G8Tesseract) {
        print(tesseract.progress)
    }

    func shouldCancelImageRecognitionForTesseract(tesseract : G8Tesseract) -> Bool {
        return false
    }

    func preprocessedImageForTesseract(tesseract: G8Tesseract!, sourceImage: UIImage!) -> UIImage! {
        print("preprocessing")
        let stillFilter = GPUImageAdaptiveThresholdFilter.init()
        stillFilter.blurRadiusInPixels = 4.0

        let filteredImage = stillFilter.imageByFilteringImage(sourceImage)

        return filteredImage
    }

    @IBAction func takePhoto(sender: AnyObject) {
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
            message: nil, preferredStyle: .ActionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }

        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)

        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }

    @IBAction func clearTextView(sender: AnyObject) {
        let alertCtrl = UIAlertController.init(
            title: "Clear text",
            message: "Are you sure you want to remove the scanned text",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alertCtrl.addAction(UIAlertAction(
            title: "Ok",
            style: .Default,
            handler: {
                (action: UIAlertAction!) in
                    self.textView.text = ""
            }
        ))

        alertCtrl.addAction(UIAlertAction(
            title: "Cancel",
            style: .Default,
            handler: nil
        ))

        presentViewController(alertCtrl, animated: true, completion: nil)
    }

    @IBAction func shareTextView(sender: AnyObject) {
        let activtyCtrl = UIActivityViewController.init(activityItems: [self.textView.text], applicationActivities: nil)
        self.presentViewController(activtyCtrl, animated: true, completion: nil)
    }

    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {

        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat

        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }

        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }

    // Activity Indicator methods
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }

    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }

}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
            addActivityIndicator()

            dismissViewControllerAnimated(true, completion: {
                self.performImageRecognition(scaledImage)
            })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

