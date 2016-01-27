//
//  ESR parsing tests
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import XCTest

class ESRTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testESRParsing() {
        let code = "042>000006506727328000000001102+ 010322486>"
        do {
            let esr = try ESR.parseText(code)
            XCTAssertEqual(2, esr.amountCheckDigit)
            XCTAssertNil(esr.amount)
            XCTAssertEqual("000006506727328000000001102", esr.refNum.num)
            XCTAssertEqual("00 00065 06727 32800 00000 01102", esr.refNum.string())
            XCTAssertEqual("010322486", esr.accNum.num)
            XCTAssertEqual(true, esr.amountCheckDigitValid())
            XCTAssertEqual(true, esr.refNumCheckDigitValid())
        } catch {
            XCTFail("should not throw")
        }

        let code2 = "0100000583903>000000000000030000605614712+ 010089006>"
        do {
            let esr2 = try ESR.parseText(code2)
            XCTAssertEqual(3, esr2.amountCheckDigit)
            XCTAssertEqual(583.90, esr2.amount?.value)
            XCTAssertEqual("000000000000030000605614712", esr2.refNum.num)
            XCTAssertEqual("010089006", esr2.accNum.num)
            XCTAssertEqual(true, esr2.amountCheckDigitValid())
            XCTAssertEqual(true, esr2.refNumCheckDigitValid())
        } catch {
            XCTFail("should not throw")
        }
    }

    func testESRParsingWithoutPlusSign() {
        let code = "042>000006506727328000000001102 010322486>"
        do {
            let esr = try ESR.parseText(code)
            XCTAssertEqual(2, esr.amountCheckDigit)
            XCTAssertNil(esr.amount)
            XCTAssertEqual("000006506727328000000001102", esr.refNum.num)
            XCTAssertEqual("010322486", esr.accNum.num)
            XCTAssertEqual(true, esr.amountCheckDigitValid())
            XCTAssertEqual(true, esr.refNumCheckDigitValid())
        } catch {
            XCTFail("should not throw")
        }

        let code2 = "0100000583903>000000000000030000605614712 010089006>"
        do {
            let esr2 = try ESR.parseText(code2)
            XCTAssertEqual(3, esr2.amountCheckDigit)
            XCTAssertEqual(583.90, esr2.amount?.value)
            XCTAssertEqual("000000000000030000605614712", esr2.refNum.num)
            XCTAssertEqual("010089006", esr2.accNum.num)
            XCTAssertEqual(true, esr2.amountCheckDigitValid())
            XCTAssertEqual(true, esr2.refNumCheckDigitValid())
        } catch {
            XCTFail("should not throw")
        }
    }

    func testESRParsingWithoutAngleBracketThrows() {
        let code = "042000006506727328000000001102 010322486"
        do {
            try ESR.parseText(code)
            XCTFail("Should throw")
        } catch {
        }
    }
}
