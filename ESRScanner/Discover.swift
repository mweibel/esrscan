//
//  Discover.swift
//  ESRScanner
//
//  Created by Michael on 11.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class Discover : NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    var afpBrowser : NSNetServiceBrowser
    var connection : Connection?
    var netService: NSNetService?

    static let sharedInstance = Discover.init()

    override init() {
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
        afpBrowser.searchForServicesOfType("_esrhttp._tcp.", inDomain: "local.")
    }

    func stop() {
        afpBrowser.stop()
    }
}