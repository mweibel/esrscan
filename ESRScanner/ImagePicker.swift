//
//  ImagePickerExtension.swift
//  ESRScanner
//
//  Created by Michael on 04.12.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

extension ScansViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        // TODO: This was added for testing but tesseract seems to work better & faster on a smaller
        // image.. might need to double-check.
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 1000)
        activityIndicator = ActivityIndicator.init(view: self.view)

        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(scaledImage, autoCrop: true)
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
