//
//  Amount.swift
//  ESRScanner
//
//  Created by Michael on 02.12.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class Amount {
    var value: Double
    init(value: Double) {
        self.value = value
    }

    func string() -> String {
        return String(format: "%.2f", self.value)
    }
}