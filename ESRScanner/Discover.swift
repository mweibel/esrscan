//
//  Discover.swift
//  ESRScanner
//
//  Created by Michael on 11.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class Discover : NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    let afpType : String
    var afpBrowser : NSNetServiceBrowser
    var connection : Connection?
    var netService: NSNetService?

    override init() {
        self.afpType = "_esrhttp._tcp."
        self.afpBrowser = NSNetServiceBrowser()
        self.afpBrowser.includesPeerToPeer = true

        super.init()
        
        self.afpBrowser.delegate = self
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        if !moreComing {
            self.connection = Connection.init(netService: aNetService)
            self.netService = aNetService
            aNetService.delegate = self.connection
            aNetService.startMonitoring()
            aNetService.resolveWithTimeout(NSTimeInterval.init(100))
        }
    }

    func startSearch() {
        afpBrowser.searchForServicesOfType(afpType, inDomain: "local.")
    }

    func stop() {
        afpBrowser.stop()
    }
}