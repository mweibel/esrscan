//
//  OCR.swift
//  ESRScanner
//
//  Created by Michael on 08.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation
import GPUImage
import TesseractOCR

class OCR : NSObject, G8TesseractDelegate {
    var tesseract : G8Tesseract

    override init() {
        self.tesseract = G8Tesseract.init(language: "eng")
        super.init()

        assert(self.tesseract.engineConfigured)
        self.tesseract.delegate = self;

        // not sure which one is correct to use.. ;)
        self.tesseract.charWhitelist = "0123456789<>+";
        self.tesseract.setVariableValue("0123456789<>+", forKey: "tessedit_char_whitelist")
        self.tesseract.setVariableValue("true", forKey: "tessedit_write_images")

        self.tesseract.engineMode = .TesseractOnly
        self.tesseract.pageSegmentationMode = .AutoOSD
    }

    func recognise(image : UIImage) {
        self.tesseract.image = grayscale(image)
        self.tesseract.recognize()
    }

    func recognisedText() -> String {
        return self.tesseract.recognizedText
    }

    func processedImage() -> UIImage {
        return self.tesseract.thresholdedImage
    }

    func progressImageRecognitionForTesseract(tesseract : G8Tesseract) {
        print(tesseract.progress)
    }

    func shouldCancelImageRecognitionForTesseract(tesseract : G8Tesseract) -> Bool {
        return false
    }

    func preprocessedImageForTesseract(tesseract: G8Tesseract!, sourceImage: UIImage!) -> UIImage! {
        print("preprocessing")
        return adaptiveThreshold(sourceImage)
    }
}