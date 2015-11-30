//
//  ImageTest.swift
//  ESRScanner
//
//  Created by Michael on 14.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import XCTest
@testable import ESRScanner

class ImageTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let img = UIImage.init(named: "IMG_1009.JPG")!
        let rect = getWhiteRectangle(img)

        XCTAssertEqual(29.0, rect.origin.x)
        XCTAssertEqual(149.0, rect.origin.y)
        XCTAssertEqual(610.0, rect.width)
        XCTAssertEqual(330.0, rect.height)
    }
}
