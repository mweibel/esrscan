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
        print("Found: \(aNetService.name) \(aNetService.hostName) \(aNetService.port) \(aNetService.addresses) \(aNetService.domain)")
        if !moreComing {
            print("no more coming")
            self.connection = Connection.init(netService: aNetService)
            self.netService = aNetService
            aNetService.delegate = self.connection
            aNetService.startMonitoring()
            aNetService.resolveWithTimeout(NSTimeInterval.init(100))
        }
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print("Found domain")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("removed service")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("did not search")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        print("did remove domain")
    }

    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("stop search")
    }

    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("will search")
    }

    func startSearch() {
        afpBrowser.searchForServicesOfType(afpType, inDomain: "local.")
    }

    func stop() {
        print("STOPPING SCAN")
        afpBrowser.stop()
    }
}