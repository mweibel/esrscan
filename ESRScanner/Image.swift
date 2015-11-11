//
//  Image.swift
//  ESRScanner
//
//  Created by Michael on 08.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit
import GPUImage
import Foundation

func getWhiteRectangle(image: UIImage) -> CGRect {
    let img = image.CGImage
    let width = CGImageGetWidth(img)
    let height = CGImageGetHeight(img)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let rawData = UnsafeMutablePointer<UInt8>.alloc(height * width * 4)
    rawData.initialize(0)

    let context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
    CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), img)

    var y1 = 0
    let y2 = height-1
    var x1 = 0
    let x2 = width-1

    for var y = y1; y > 0; y-- {
        let colors = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y)
        if colors.isWhite() {
            y1 = y
        } else {
            break
        }
    }
    for var x = x2; x > 0; x-- {
        let colors = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x, y: y2)
        if colors.isWhite() {
            x1 = x
        } else {
            break
        }
    }
    print(y1, y2, x1, x2)
    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x1, y: y1))
    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y2))

    rawData.destroy()

    return CGRect.init(x: x1, y: x2, width: width, height: height)
}

struct Colors{
    var red : UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8

    func isWhite() -> Bool {
        return red > 250 && green > 250 && blue > 250 && alpha > 250
    }
}
func getColors(rawData : UnsafeMutablePointer<UInt8>, bytesPerRow : Int, bytesPerPixel : Int, x: Int, y: Int) -> Colors {
    let byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    let red = rawData[byteIndex];
    let green = rawData[byteIndex + 1];
    let blue = rawData[byteIndex + 2];
    let alpha = rawData[byteIndex + 3];
    return Colors(red: red, green: green, blue: blue, alpha: alpha)
}

func crop(image: UIImage, cropRect: CGRect) -> UIImage {
    let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    return UIImage.init(CGImage: imageRef!)
}

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

func radians (degrees : Double) -> CGFloat {
    return CGFloat(degrees * M_PI/180);
}

func rotate(src : UIImage) -> UIImage {
    if src.size.height > src.size.width {
        return src.imageRotatedByDegrees(-90, flip: false)
    }

    return src
}