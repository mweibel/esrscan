//
//  Util.swift
//  ESRScanner
//
//  Created by Michael on 08.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation
import UIKit

func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {

    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    var scaleFactor: CGFloat

    if image.size.width > image.size.height {
        scaleFactor = image.size.height / image.size.width
        scaledSize.width = maxDimension
        scaledSize.height = scaledSize.width * scaleFactor
    } else {
        scaleFactor = image.size.width / image.size.height
        scaledSize.height = maxDimension
        scaledSize.width = scaledSize.height * scaleFactor
    }

    UIGraphicsBeginImageContext(scaledSize)
    image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return scaledImage
}