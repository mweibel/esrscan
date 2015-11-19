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

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Point : Hashable {
    var x : Int
    var y : Int

    var hashValue : Int {
        get {
            return "\(self.x),\(self.y)".hashValue
        }
    }

}

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

//    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: 85, y: 387))

    let first = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y2)
    let possiblyOrange = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: 0, y: y2)
    let rootDiff = getDifference(first, comp: possiblyOrange)

    var colorList = [Point : HSVColors]()

    print("rootdiff: \(rootDiff)")
    var greatestDiff = 0
    for var y = y2; y > 0; y = y-5 {
        let colors = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y)
//        print("1 -- pb: \(colors.perceivedBrightness()) b: \(colors.brightness()) -- hsv: \(colors.ToHSV())")
        let diff = getDifference(colors, comp: possiblyOrange)
//        print("1 -- \(x2):\(y) - \(colors) - \(diff)")
        if diff > greatestDiff {
            greatestDiff = diff
        }
        let hsv = colors.ToHSV()
        let point = Point(x: x2, y: y)
        print("\(point): \(hsv)")
        print("HSV2: \(colors.ToHSV2())")
        if hsv.hue >= 0 && hsv.hue <= 35 && hsv.val >= 150 && hsv.sat >= 0.25 {
            print("IN")
            if y1 == 0 {
                y1 = y - 10
            }
            //break
            colorList[point] = hsv
        }
    }

    print(greatestDiff)
    greatestDiff = 0

    for var x = x2; x > 0; x = x-5 {
        let colors = getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x, y: y2)
//        print("2 -- pb: \(colors.perceivedBrightness()) b: \(colors.brightness()) -- hsv: \(colors.ToHSV())")
        let diff = getDifference(colors, comp: possiblyOrange)
//        print("2 -- \(x):\(y2) - \(colors) - \(diff)")
        if diff > greatestDiff {
            greatestDiff = diff
        }
        let hsv = colors.ToHSV()
        let point = Point(x: x, y: y2)
        print("\(point): \(hsv)")
        print("HSV2: \(colors.ToHSV2())")
        if hsv.hue >= 0 && hsv.hue <= 35 && hsv.val >= 150 && hsv.sat >= 0.25 {
            print("IN")
            if x1 == 0 {
                x1 = x - 10
            }
            //break
            colorList[point] = hsv
        }
    }

    print(colorList)
    print(x1, y1, x2, y2)
    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x1, y: y1))
    print(getColors(rawData, bytesPerRow: bytesPerRow, bytesPerPixel: bytesPerPixel, x: x2, y: y2))

    rawData.destroy()

    let rect = CGRectMake(CGFloat(x1), CGFloat(y1), CGFloat(x2 - x1), CGFloat(y2 - y1))
    return rect
}

func getDifference(real : Colors, comp : Colors) -> Int {
    let red = max(real.red, comp.red) - min(real.red, comp.red)
    let green = max(real.green, comp.green) - min(real.green, comp.green)
    let blue = max(real.blue, comp.blue) - min(real.blue, comp.blue)
    return Int(red + green + blue)
}

func getDistance(real : Colors, comp : Colors) -> Double {
    let red = pow(Double(real.red) - Double(comp.red), 2)
    let green = pow(Double(real.green) - Double(comp.green), 2)
    let blue = pow(Double(real.blue) - Double(comp.blue), 2)
    return sqrt(red + green + blue)
}

func getBrightnessDiff(real : Colors, comp : Colors) -> Double {
    return real.brightness() - comp.brightness()
}

struct HSVColors {
    var hue: Double
    var sat: Double
    var val: Double
}

func min3(a: UInt16, _ b: UInt16, _ c: UInt16) -> UInt16 {
    var m = a
    if m > b {
        m = b
    }
    if m > c {
        m = c
    }
    return m
}

func max3(a: UInt16, _ b: UInt16, _ c: UInt16) -> UInt16 {
    var m = a
    if m < b {
        m = b
    }
    if m < c {
        m = c
    }
    return m
}


struct Colors{
    var red : UInt16
    var green: UInt16
    var blue: UInt16

    func brightness() -> Double {
        return Double(self.red + self.green + self.blue) / 3.0
    }
    func perceivedBrightness() -> Double {
        let red = 0.299 * Double(self.red)
        let green = 0.587 * Double(self.green)
        let blue = 0.114 * Double(self.blue)
        return red + green + blue
    }
    func ToHSV() -> HSVColors {
        var hsv = HSVColors(hue: 0, sat: 0, val: 0)

        let red = Double(self.red)
        let green = Double(self.green)
        let blue = Double(self.blue)

        let rgbMin = min(red, min(green, blue))
        let rgbMax = max(red, max(green, blue))
        let diff = rgbMax - rgbMin

        if (rgbMax == rgbMin) {
            hsv.hue = 0;
        } else if (rgbMax == red) {
            hsv.hue = 60.0 * ((green - blue) / diff)
            hsv.hue = fmod(hsv.hue, 360.0);
            if hsv.hue < 0 {
                print("#########: \(green) \(blue) \(diff)")
            }
        } else if (rgbMax == green) {
            hsv.hue = 60.0 * ((blue - red) / diff) + 120.0
            if hsv.hue < 0 {
                print("*********: \(blue) \(red) \(diff)")
            }
        } else if (rgbMax == blue) {
            hsv.hue = 60.0 * ((red - green) / diff) + 240.0
            if hsv.hue < 0 {
                print("%%%%%%%%%: \(red) \(green) \(diff)")
            }
        }
        hsv.hue = abs(hsv.hue)
        hsv.val = rgbMax;
        if (rgbMax == 0) {
            hsv.sat = 0;
        } else {
            hsv.sat = 1.0 - (rgbMin / rgbMax);
        }
        return hsv
    }


    func ToHSV2() -> HSVColors {
        var hsv = HSVColors(hue: 0, sat: 0, val: 0)
        let rd: Double = Double(self.red)
        let gd: Double = Double(self.green)
        let bd: Double = Double(self.blue)

        let maxV: Double = max(rd, max(gd, bd))
        let minV: Double = min(rd, min(gd, bd))
        let diff: Double = maxV - minV

        hsv.val = maxV
        hsv.sat = maxV == 0 ? 0 : diff / minV;

        if (maxV == minV) {
            hsv.hue = 0
        } else {
            if (maxV == rd) {
                hsv.hue = (gd - bd) / diff + (gd < bd ? 6 : 0)
            } else if (maxV == gd) {
                hsv.hue = (bd - rd) / diff + 2
            } else if (maxV == bd) {
                hsv.hue = (rd - gd) / diff + 4
            }

            hsv.hue /= 6;
        }
        return hsv
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
    let filter = GPUImageSobelEdgeDetectionFilter.init()
    return filter.imageByFilteringImage(image)
}

func histogram(image: UIImage) -> UIImage {
    let filter = GPUImageHistogramFilter.init(histogramType: kGPUImageHistogramRGB)

    let gammaFilter = GPUImageGammaFilter.init()
    gammaFilter.addTarget(filter)

    let generator = GPUImageHistogramGenerator.init()
    generator.forceProcessingAtSize(CGSizeMake(256.0, 330.0))
    filter.addTarget(generator)

    let blendFilter = GPUImageAlphaBlendFilter.init()
    blendFilter.mix = 0.75
    blendFilter.forceProcessingAtSize(CGSizeMake(256.0, 330.0))
    generator.addTarget(blendFilter)

    return generator.imageByFilteringImage(image)
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
    let filter = GPUImageAdaptiveThresholdFilter.init()
    filter.blurRadiusInPixels = 5.0

    return filter.imageByFilteringImage(image)
}

func falseColor(image : UIImage) -> UIImage {
    let filter = GPUImageFalseColorFilter.init()
    return filter.imageByFilteringImage(image)
}

func highlightShadow(image : UIImage) -> UIImage {
    let filter = GPUImageHighlightShadowFilter.init()
    filter.highlights = 0.0
    filter.shadows = 1.0
    return filter.imageByFilteringImage(image)
}


func luminanceThreshold(image : UIImage) -> UIImage {
    let filter = GPUImageLuminanceThresholdFilter.init()
    filter.threshold = 0.1
    return filter.imageByFilteringImage(image)
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

func saturationZero(image: UIImage) -> UIImage {
    let filter = GPUImageSaturationFilter.init()
    filter.saturation = 0.0
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