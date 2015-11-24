//
//  ReferenceNumber.swift
//  ESRScanner
//
//  Created by Michael on 23.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class ReferenceNumber {
    var num: String
    init(num: String) {
        self.num = num
    }

    func string() -> String {
        // TODO: split into different parts.
        return "\(self.num)"
    }
}