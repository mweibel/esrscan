//
//  Image.swift
//  ESRScanner
//
//  Created by Michael on 08.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit
import GPUImage

func luminanceThreshold(image : UIImage) -> UIImage {
    let stillFilter = GPUImageLuminanceThresholdFilter.init()
    stillFilter.threshold = 0.3

    return stillFilter.imageByFilteringImage(image)
}

func adaptiveThreshold(image : UIImage) -> UIImage {
    let stillFilter = GPUImageAdaptiveThresholdFilter.init()
    stillFilter.blurRadiusInPixels = 4.0

    return stillFilter.imageByFilteringImage(image)
}

func grayscale(image: UIImage) -> UIImage {
    let filter = GPUImageGrayscaleFilter.init()
    return filter.imageByFilteringImage(image)
}