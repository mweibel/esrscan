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
    stillFilter.blurRadiusInPixels = 2.0

    return stillFilter.imageByFilteringImage(image)
}

func blackAndWhite(image: UIImage) -> UIImage {
    let filter = GPUImageSaturationFilter.init()
    filter.saturation = 0
    var newImage = filter.imageByFilteringImage(image)

    let filter2 = GPUImageContrastFilter.init()
    filter2.contrast = 4.0
    newImage = filter2.imageByFilteringImage(newImage)

/*    let filter3 = GPUImageExposureFilter.init()
    filter3.exposure = 1.0
    return filter3.imageByFilteringImage(newImage)*/
    return newImage
}


func grayscale(image: UIImage) -> UIImage {
    let filter = GPUImageGrayscaleFilter.init()
    return filter.imageByFilteringImage(image)
}