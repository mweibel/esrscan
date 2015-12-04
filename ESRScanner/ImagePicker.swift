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
        // TODO: This was probably added for testing, not sure if it's still needed.
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        activityIndicator = ActivityIndicator.init(view: self.view)

        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
