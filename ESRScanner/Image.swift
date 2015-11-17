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

    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: 85, y: 387))

    let first = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y2)
    var greatestDiff = 0
    for var y = y2; y > 0; y = y-50 {
        let colors = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y)
        let diff = getDifference(colors, comp: first)
        print("1 -- \(x2):\(y) - \(colors) - \(diff)")
        if diff > greatestDiff {
            greatestDiff = diff
        }
        if diff > 50 {
            // some border is needed
            y1 = y
            break
        }
    }

    print(greatestDiff)
    greatestDiff = 0

    for var x = x2; x > 0; x = x-50 {
        let colors = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x, y: y2)
        let diff = getDifference(colors, comp: first)
        print("2 -- \(x):\(y2) - \(colors) - \(diff)")
        if diff > greatestDiff {
            greatestDiff = diff
        }
        if diff > 50 {
            // some border is needed
            x1 = x
            break
        }
    }
    print(greatestDiff)
    print(x1, y1, x2, y2)
    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x1, y: y1))
    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y2))

    rawData.destroy()

    let rect = CGRectMake(CGFloat(x1), CGFloat(y1), CGFloat(x2 - x1), CGFloat(y2 - y1))
    return rect
}

func getDifference(real : Colors, comp : Colors) -> Int {
    let red = abs(Int(real.red) - Int(comp.red))
    let green = abs(Int(real.green) - Int(comp.green))
    let blue = abs(Int(real.blue) - Int(comp.blue))
    return red + green + blue
}

func getBrightnessDiff(real : Colors, comp : Colors) -> Double {
    return real.Brightness() - comp.Brightness()
}


struct Colors{
    var red : UInt16
    var green: UInt16
    var blue: UInt16

    func Brightness() -> Double {
        return Double(self.red + self.green + self.blue) / 3.0
    }
}
func getColors(rawData : UnsafeMutablePointer<UInt8>, bytesPerRow : Int, bytesPerPixel : Int, x: Int, y: Int) -> Colors {
    let byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    let red = UInt16(rawData[byteIndex])
    let green = UInt16(rawData[byteIndex + 1])
    let blue = UInt16(rawData[byteIndex + 2])
    return Colors(red: red, green: green, blue: blue)
}
func getAverageColorWithinDiameter(rawData : UnsafeMutablePointer<UInt8>, bytesPerRow : Int, bytesPerPixel : Int, x: Int, y: Int, diameter : Int, width: Int, height: Int) -> Colors {

    var startX = x - (diameter / 2)
    if startX < 0 {
        startX = 0
    }
    var startY = y - (diameter / 2)
    if startY < 0 {
        startY = 0
    }
    if (startY + diameter > height) || (startX + diameter > width) {
        let nextX = (startX + diameter > height) ? x - 1 : x
        let nextY = (startY + diameter > height) ? y - 1 : y
        return getAverageColorWithinDiameter(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: nextX, y: nextY, diameter: diameter, width: width, height: height)
    }

    var red = Int(0)
    var green = Int(0)
    var blue = Int(0)
    for var xx = 0; xx < diameter; xx++ {
        for var yy = 0; yy < diameter; yy++ {
            let byteIndex = (bytesPerRow * (startY + yy)) + (startX + xx) * bytesPerPixel
            red += Int(rawData[byteIndex])
            green += Int(rawData[byteIndex + 1])
            blue += Int(rawData[byteIndex + 2])
        }
    }
    let count = diameter * diameter
    return Colors(red: UInt16(red/count), green: UInt16(green/count), blue: UInt16(blue/count))
}

func crop(image: UIImage, cropRect: CGRect) -> UIImage {
    print("crop:", cropRect.width, cropRect.height, cropRect.minX, cropRect.minY)
    let filter = GPUImageCropFilter.init(cropRegion: cropRect)
    return filter.imageByFilteringImage(image)
}

func edgeDetection(image: UIImage) -> UIImage {
    let filter = GPUImageToonFilter.init()
    return filter.imageByFilteringImage(image)
}

func drawRect(image: UIImage, rect: CGRect) -> UIImage {
    UIGraphicsBeginImageContext(image.size)
    image.drawAtPoint(CGPointZero)
    let ctx = UIGraphicsGetCurrentContext()
    UIColor.redColor().setStroke()

    CGContextStrokeRect(ctx, rect)
    let retImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return retImage
}

func colorMask(image: UIImage) -> UIImage {
    let colorMasking:[CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 4.0]
    let maskImage = CGImageCreateWithMaskingColors(removeAlphaChannel(image).CGImage, colorMasking)
    return UIImage.init(CGImage: maskImage!)
}

func removeAlphaChannel(image: UIImage) -> UIImage {
    // Load the image and check if it still has an alpha channel
    let source = image.CGImage
    if CGImageGetAlphaInfo(source) == CGImageAlphaInfo.None {
        return image
    }

    // Remove the alpha channel
    let width = CGImageGetWidth(source)
    let height = CGImageGetHeight(source)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let rawData = UnsafeMutablePointer<UInt8>.alloc(height * width * 4)
    rawData.initialize(0)

    let context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGImageAlphaInfo.NoneSkipFirst.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
    CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), source)
    let retImage = CGBitmapContextCreateImage(context)!
    UIGraphicsEndImageContext()
    return UIImage.init(CGImage: retImage)
}

func adaptiveThreshold(image : UIImage) -> UIImage {
    let stillFilter = GPUImageAdaptiveThresholdFilter.init()
    stillFilter.blurRadiusInPixels = 5.0

    return stillFilter.imageByFilteringImage(image)
}

func gamma(image : UIImage) -> UIImage {
    let filter = GPUImageGammaFilter.init()
    filter.gamma = 0.1
    return filter.imageByFilteringImage(image)
}

func contrast(image : UIImage) -> UIImage {
    let filter = GPUImageContrastFilter.init()
    filter.contrast = 4.0
    return filter.imageByFilteringImage(image)
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