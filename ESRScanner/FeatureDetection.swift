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
    let cimg = CIImage.init(CGImage: image.CGImage!)
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