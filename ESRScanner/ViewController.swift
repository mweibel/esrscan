//
//  ViewController.swift
//  einzahlungsschein
//
//  Created by Michael on 30.10.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!

    var activityIndicator: UIActivityIndicatorView!

    func performImageRecognition(image: UIImage) {
        print("PROCESSING \(image.size)")
        let rImage = rotate(image)
        
        let ocr = OCR.init()
        ocr.recognise(rImage)
        imageView.image = invert(ocr.processedImage())

        detectFeatures(perspectiveCorrection(rImage), typ: CIDetectorTypeRectangle)
        detectFeatures(rImage, typ: CIDetectorTypeText)

        let coords = getWhiteRectangle(rImage)
//        imageView2.image = adaptiveThreshold(sharpen(crop(rImage, cropRect: coords)))
//        let coords = CGRectMake(CGFloat(85), CGFloat(388), CGFloat(50), CGFloat(50))
        print(coords)
//        imageView2.image = edgeDetection(rImage)
//        imageView2.image = histogram(rImage)
        imageView2.image = drawRect(rImage, rect: coords)

        let text = ocr.recognisedText()
        print(text)
        let textArr = text.componentsSeparatedByString("\n").filter{
            // count checking is already some preprocessing to fix some possibly wrong detections
            $0.containsString(">") && $0.characters.count > 35 && $0.characters.count <= 53 && ($0.hasPrefix("01") || $0.hasPrefix("04"))
        }
        if textArr.count > 0 {
            let esrCode = ESR.init(str: textArr[textArr.count-1])
            textView.text.appendContentsOf(esrCode.string())
            textView.text.appendContentsOf("\n\n----\n\n")
        }

        removeActivityIndicator()
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

