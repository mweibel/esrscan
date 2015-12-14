//
//  Scans.swift
//  ESRScanner
//
//  Created by Michael on 23.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class Scans {
    var scans : [ESR] = []

    func addScan(scan : ESR) {
        self.scans.insert(scan, atIndex: 0)
    }

    func count() -> Int {
        return self.scans.count
    }

    func clear() {
        self.scans = []
    }

    func string() -> String {
        return scans.map{ $0.string() }.joinWithSeparator("\n----\n")
    }

    subscript(index: Int) -> ESR {
        get {
            return scans[index]
        }
    }
}