//
//  Scans.swift
//  ESRScanner
//
//  Created by Michael on 23.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class Scans {
    var scans = [ESR]()

    func addScan(esr : ESR) {
        self.scans.append(esr)
    }
}