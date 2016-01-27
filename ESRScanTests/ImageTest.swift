//
//  Image utilities tests
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import XCTest

class ImageTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("esr", ofType: "png")

        let img = UIImage.init(named: path!)
        XCTAssertNotNil(img)
        let rect = getWhiteRectangle(img!)

        XCTAssertEqual(458.0, rect.origin.x)
        XCTAssertEqual(531.0, rect.origin.y)
        XCTAssertEqual(1187.0, rect.width)
        XCTAssertEqual(280.0, rect.height)
    }
}
