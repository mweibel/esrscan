//
//  Camera.swift
//  ESRScan
//
//  Created by Michael on 17/05/16.
//  Copyright © 2016 Michael Weibel. All rights reserved.
//

import UIKit
import AVFoundation

// Translated to Swift from:
// https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW4
func imageFromSampleBuffer(buf: CMSampleBufferRef) -> UIImage {
    let imageBuffer = CMSampleBufferGetImageBuffer(buf)
    CVPixelBufferLockBaseAddress(imageBuffer!, 0) // FIXME: exclamation mark

    let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer!, 0)
    let width = CVPixelBufferGetWidth(imageBuffer!)
    let height = CVPixelBufferGetHeight(imageBuffer!)
    // bytesPerRow is better manually calculated, instead of using CVPixelBufferGetBytesPerRow()
    let bytesPerPixel = 4
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)

    // Create a device-dependent RGB color space
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    // Create a bitmap graphics context with the sample buffer data
    let bitmapInfo = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue
    let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)

    // Create a Quartz image from the pixel data in the bitmap graphics context
    let quartzImage = CGBitmapContextCreateImage(context)

    CVPixelBufferUnlockBaseAddress(imageBuffer!, 0);

    return UIImage(CGImage: quartzImage!)
}

func CIImageFromSampleBuffer(buf: CMSampleBufferRef) -> CIImage {
    let imageBuffer = CMSampleBufferGetImageBuffer(buf)
    CVPixelBufferLockBaseAddress(imageBuffer!, 0) // FIXME: exclamation mark

    let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, buf, kCMAttachmentMode_ShouldPropagate) as? [String: AnyObject]

    return CIImage(CVImageBuffer: imageBuffer!, options: attachments)
}