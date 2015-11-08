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
        // TODO: split into different parts.
        return "\(self.num)"
    }
}