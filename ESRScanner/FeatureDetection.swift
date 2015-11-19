//
//  FeatureDetection.swift
//  ESRScanner
//
//  Created by Michael on 16.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation
import UIKit

func detectFeatures(image : UIImage, typ : String) -> [CIFeature] {
    var cimg : CIImage
    if image.CGImage != nil {
        cimg = CIImage.init(CGImage: image.CGImage!)
    } else {
        cimg = image.CIImage!
    }
    var dOptions = [String : AnyObject]()
//    dOptions[CIDetectorMinFeatureSize] = 0.02
    dOptions[CIDetectorAccuracyHigh] = true
    let detector = CIDetector.init(ofType: typ, context: nil, options: dOptions)
    var fOptions = [String : AnyObject]()
    if typ == CIDetectorTypeRectangle {
        fOptions[CIDetectorAspectRatio] = 5.89
    }
    let features = detector.featuresInImage(cimg, options: fOptions)
    print("\(typ): \(features.endIndex)")
    for feature in features {
        print("\(typ): \(feature.bounds)")
    }
    return features
}

func perspectiveCorrection(image: UIImage) -> UIImage {
    let cgImage    = image.CGImage!
    let width    = CGImageGetWidth(cgImage)
    let height   = CGImageGetHeight(cgImage)
    let cimg = CIImage.init(CGImage: cgImage)
    var options = [String : AnyObject]()
    options["inputBottomLeft"] = CIVector(CGPoint: CGPoint.init(x: 0, y: 0))
    options["inputBottomRight"] = CIVector(CGPoint: CGPoint.init(x: width, y: 0))
    options["inputTopLeft"] = CIVector(CGPoint: CGPoint.init(x: 0, y: height))
    options["inputTopRight"] = CIVector(CGPoint: CGPoint.init(x: width, y: height))
    let ciImage = cimg.imageByApplyingFilter("CIPerspectiveCorrection", withInputParameters: options)
    return UIImage.init(CIImage: ciImage)
}