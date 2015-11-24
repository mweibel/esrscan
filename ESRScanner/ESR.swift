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
    var refNum: ReferenceNumber
    var refNumCheckDigit: Int
    var accNum: AccountNumber

    init(str: String) {
        let newStr = str.stringByReplacingOccurrencesOfString(" ", withString: "")
        self.fullStr = newStr

        let angleRange = newStr.rangeOfString(">")!
        let angleIndex = newStr.startIndex.distanceTo(angleRange.startIndex)
        self.amountCheckDigit = Int(newStr.substringWithRange(
            Range<String.Index>(
                start: newStr.startIndex.advancedBy(Int(angleIndex.value) - 1),
                end: newStr.startIndex.advancedBy(angleIndex)
            )
        ))!
        if Int(angleIndex.value) > 3 {
            let amount = Double(newStr.substringWithRange(
                Range<String.Index>(
                    start: newStr.startIndex.advancedBy(2),
                    end: newStr.startIndex.advancedBy(Int(angleIndex.value) - 1)
                )
                ))!
            self.amount = amount / 100.0
        }
        let afterAngle = Int(angleIndex.value) + 1

        let refNumStart = newStr.startIndex.advancedBy(afterAngle)
        var refNumLength = 27

        let plusRange = newStr.rangeOfString("+")
        if plusRange != nil {
            let plusIndex = refNumStart.distanceTo(plusRange!.startIndex)
            refNumLength = plusIndex
        }

        self.refNum = ReferenceNumber.init(num: newStr.substringWithRange(
            Range<String.Index>(
                start: refNumStart,
                end: refNumStart.advancedBy(refNumLength)
            )))

        let idx = self.refNum.num.endIndex.advancedBy(-1)
        self.refNumCheckDigit = Int(self.refNum.num.substringFromIndex(idx))!

        let accNum = newStr.substringWithRange(
            Range<String.Index>(
                start: newStr.endIndex.advancedBy(-10),
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
        let idx = self.refNum.num.endIndex.advancedBy(-1)
        let refNum = self.refNum.num.substringToIndex(idx)

        return self.refNumCheckDigit == calcControlDigit(refNum)
    }

    func string() -> String {
        var str = "RefNum: \(self.refNum.string())\nAccNum: \(self.accNum.string())"
        if self.amount != nil {
            str.appendContentsOf("\nAmount: \(self.amount)")
        }
        str.appendContentsOf("\nAmount Valid? \(self.amountCheckDigitValid())")
        str.appendContentsOf("\nRefNum Valid? \(self.refNumCheckDigitValid())")
        return str
    }

    func dictionary() -> [String : AnyObject] {
        var dict = [String : AnyObject]()
        dict["refNum"] = self.refNum.num
        dict["amount"] = self.amount
        dict["accNum"] = self.accNum.num

        return dict
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