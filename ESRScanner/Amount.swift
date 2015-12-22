//
//  Amount model
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import Foundation

class Amount {
    var value: Double
    let currency = "CHF"
    init(value: Double) {
        self.value = value
    }

    func string() -> String {
        return String(format: "%.2f", self.value)
    }
}