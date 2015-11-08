//
//  ESR.swift
//  einzahlungsschein
//
//  Created by Michael on 05.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

public class ESR {
    var fullStr: String
    var amountCheckDigit: Int
    var amount: Double?
    var userNumber: Int
    var refNum: String
    var accNum: AccountNumber

    init(str: String) {
        print("ESR.init:str: " + str)
        let newStr = str.stringByReplacingOccurrencesOfString(" ", withString: "")
        self.fullStr = newStr

        let hasAmount = str.hasPrefix("01")
        let angleRange = newStr.rangeOfString(">")!
        let angleIndex = newStr.startIndex.distanceTo(angleRange.startIndex)
        self.amountCheckDigit = Int(newStr.substringWithRange(
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
        let accNum = newStr.substringWithRange(
            Range<String.Index>(
                start: newStr.startIndex.advancedBy(Int(plusIndex.value) + 1),
                end: newStr.endIndex.advancedBy(-1)
            )
        )
        self.accNum = AccountNumber.init(num: accNum)
    }

    func amountCheckDigitValid() -> Bool {
        let angleRange = self.fullStr.rangeOfString(">")!
        let angleIndex = self.fullStr.startIndex.distanceTo(angleRange.startIndex)
        let str = self.fullStr.substringWithRange(
            Range<String.Index>(
                start: self.fullStr.startIndex,
                end: self.fullStr.startIndex.advancedBy(Int(angleIndex.value) - 1)
            )
        )
        return self.amountCheckDigit == calcControlDigit(str)
    }

    func refNumCheckDigitValid() -> Bool {
        let idx = self.refNum.endIndex.advancedBy(-1)
        let refNum = self.refNum.substringToIndex(idx)
        let checkDigit = Int(self.refNum.substringFromIndex(idx))!

        return checkDigit == calcControlDigit(refNum)
    }

    func string() -> String {
        var str = "RefNum: \(self.refNum)\nAccNum: \(self.accNum.string())"
        if self.amount != nil {
            str.appendContentsOf("\nAmount: \(self.amount)")
        }
        str.appendContentsOf("\nAmount Valid? \(self.amountCheckDigitValid())")
        str.appendContentsOf("\nRefNum Valid? \(self.refNumCheckDigitValid())")
        return str
    }

    private func calcControlDigit(str: String) -> Int {
        let table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
        var carry = 0
        for char in str.characters {
            let num = Int.init(String(char), radix: 10)!
            carry = table[(carry + num) % 10]
        }
        return (10 - carry) % 10
    }
}