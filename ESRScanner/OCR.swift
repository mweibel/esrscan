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
        self.tesseract = G8Tesseract.init(language: "ocrbv2")
        super.init()

        assert(self.tesseract.engineConfigured)
        self.tesseract.delegate = self;

        // not sure which one is correct to use.. ;)
        self.tesseract.charWhitelist = "0123456789<>+";
        self.tesseract.setVariableValue("0123456789<>+", forKey: "tessedit_char_whitelist")
        self.tesseract.setVariablesFromDictionary([
            "tessedit_char_whitelist": "0123456789<>+",
            "load_system_dawg": "F",
            "load_freq_dawg": "F",
            "load_unambig_dawg": "F",
            "load_punc_dawg": "F",
            "load_number_dawg": "F",
            "load_fixed_length_dawgs": "F",
            "load_bigram_dawg": "F",
            "wordrec_enable_assoc": "F",
        ])

        self.tesseract.engineMode = .TesseractOnly
        self.tesseract.pageSegmentationMode = .AutoOSD
    }

    func recognise(image : UIImage) {
        self.tesseract.image = image
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
        return preprocessImage(sourceImage)
    }
}