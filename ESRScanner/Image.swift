//
//  Image.swift
//  ESRScanner
//
//  Created by Michael on 08.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit
import GPUImage

func adaptiveThreshold(image : UIImage) -> UIImage {
    let stillFilter = GPUImageAdaptiveThresholdFilter.init()
    stillFilter.blurRadiusInPixels = 5.0

    return stillFilter.imageByFilteringImage(image)
}

func blackAndWhite(image: UIImage) -> UIImage {
    let filterGroup = GPUImageFilterGroup.init()
    let filter = GPUImageSaturationFilter.init()
    filter.saturation = 0
    filterGroup.addFilter(filter)

    let filter2 = GPUImageContrastFilter.init()
    filter2.contrast = 4.0
    filterGroup.addFilter(filter2)


/*    let filter3 = GPUImageExposureFilter.init()
    filter3.exposure = 1.0
    return filter3.imageByFilteringImage(newImage)*/

    return filterGroup.imageByFilteringImage(image)
}

func invert(image: UIImage) -> UIImage {
    let filter = GPUImageColorInvertFilter.init()
    return filter.imageByFilteringImage(image)
}

func sharpen(image: UIImage) -> UIImage {
    let filter = GPUImageSharpenFilter.init()
    filter.sharpness = 1.0
    return filter.imageByFilteringImage(image)
}


func grayscale(image: UIImage) -> UIImage {
    let filter = GPUImageGrayscaleFilter.init()
    return filter.imageByFilteringImage(image)
}