//
//  ESRTest.swift
//  einzahlungsschein
//
//  Created by Michael on 06.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import XCTest
@testable import ESRScanner

class ESRTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testESRParsing() {
        let code = "042>000006506727328000000001102+ 010322486>"
        let esr = ESR.init(str: code)
        XCTAssertEqual(2, esr.amountCheckDigit)
        XCTAssertEqual(nil, esr.amount)
        XCTAssertEqual("000006506727328000000001102", esr.refNum)
        XCTAssertEqual("010322486", esr.accNum.num)
        XCTAssertEqual(true, esr.amountCheckDigitValid())
        XCTAssertEqual(true, esr.refNumCheckDigitValid())

        let code2 = "0100000583903>000000000000030000605614712+ 010089006>"
        let esr2 = ESR.init(str: code2)
        XCTAssertEqual(3, esr2.amountCheckDigit)
        XCTAssertEqual(583.90, esr2.amount)
        XCTAssertEqual("000000000000030000605614712", esr2.refNum)
        XCTAssertEqual("010089006", esr2.accNum.num)
        XCTAssertEqual(true, esr2.amountCheckDigitValid())
        XCTAssertEqual(true, esr2.refNumCheckDigitValid())
    }

    func testESRParsingWithoutPlusSign() {
        let code = "042>000006506727328000000001102 010322486>"
        let esr = ESR.init(str: code)
        XCTAssertEqual(2, esr.amountCheckDigit)
        XCTAssertEqual(nil, esr.amount)
        XCTAssertEqual("000006506727328000000001102", esr.refNum)
        XCTAssertEqual("010322486", esr.accNum.num)
        XCTAssertEqual(true, esr.amountCheckDigitValid())
        XCTAssertEqual(true, esr.refNumCheckDigitValid())

        let code2 = "0100000583903>000000000000030000605614712 010089006>"
        let esr2 = ESR.init(str: code2)
        XCTAssertEqual(3, esr2.amountCheckDigit)
        XCTAssertEqual(583.90, esr2.amount)
        XCTAssertEqual("000000000000030000605614712", esr2.refNum)
        XCTAssertEqual("010089006", esr2.accNum.num)
        XCTAssertEqual(true, esr2.amountCheckDigitValid())
        XCTAssertEqual(true, esr2.refNumCheckDigitValid())
    }
    
}
