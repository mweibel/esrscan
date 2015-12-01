//
//  AccountNumber.swift
//  einzahlungsschein
//
//  Created by Michael on 06.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class AccountNumber {
    var num: String
    init(num: String) {
        self.num = num
    }

    func string() -> String {
        let prefix = String(num[num.startIndex.advancedBy(2)])
        let center = num.substringWithRange(Range(start: num.startIndex.advancedBy(2), end: num.endIndex.advancedBy(-1)))
        let postfix = String(num[num.endIndex.advancedBy(-1)])
        return prefix + "-" + center + "-" + postfix
    }
}