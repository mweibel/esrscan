//
//  ESR.swift
//  einzahlungsschein
//
//  Created by Michael on 05.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

public class ESR {
    var checkSum: Int
    var amount: Double?
    var userNumber: Int
    var refNum: String
    var accNum: AccountNumber

    init(str: String) {
        print("ESR.init:str: " + str)
        let newStr = str.stringByReplacingOccurrencesOfString(" ", withString: "")
        let hasAmount = str.hasPrefix("01")
        let angleRange = newStr.rangeOfString(">")!
        let angleIndex = newStr.startIndex.distanceTo(angleRange.startIndex)
        self.checkSum = Int(newStr.substringWithRange(
            Range<String.Index>(
                start: newStr.startIndex.advancedBy(Int(angleIndex.value) - 1),
                end: newStr.startIndex.advancedBy(angleIndex)
            )
        ))!
        if hasAmount {
            let amount = Double(newStr.substringWithRange(
                Range<String.Index>(
                    start: newStr.startIndex.advancedBy(2),
                    end: newStr.startIndex.advancedBy(Int(angleIndex.value) - 1)
                )
                ))!
            self.amount = amount / 100.0
        }
        let afterAngle = Int(angleIndex.value) + 1

        let plusRange = newStr.rangeOfString("+")!
        let plusIndex = newStr.startIndex.distanceTo(plusRange.startIndex)

        self.refNum = newStr.substringWithRange(
            Range<String.Index>(
                start: newStr.startIndex.advancedBy(afterAngle),
                end: newStr.startIndex.advancedBy(Int(plusIndex.value))
            ))

        //usernumber is a substring of the ref num
        self.userNumber = Int(refNum.substringWithRange(
            Range<String.Index>(
                start: refNum.startIndex,
                end: refNum.startIndex.advancedBy(6)
            )
        ))!
        let accNum = Int(newStr.substringWithRange(
            Range<String.Index>(
                start: newStr.startIndex.advancedBy(Int(plusIndex.value) + 2),
                end: newStr.endIndex.advancedBy(-1)
            )
        ))!
        self.accNum = AccountNumber.init(num: accNum)
    }

    func string() -> String {
        var str = "RefNum: \(self.refNum)\nAccNum: \(self.accNum.string())"
        if self.amount != nil {
            str.appendContentsOf("\nAmount: \(self.amount)")
        }
        return str
    }
}