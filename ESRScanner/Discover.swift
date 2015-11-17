//
//  Discover.swift
//  ESRScanner
//
//  Created by Michael on 11.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import Foundation

class Discover : NSObject, NSNetServiceBrowserDelegate {
    let afpType : String
    var afpBrowser : NSNetServiceBrowser
    var serviceList : [NSNetService]

    override init() {
        self.afpType = "_esr._tcp."
        self.afpBrowser = NSNetServiceBrowser()
        self.afpBrowser.includesPeerToPeer = true
        self.serviceList = [NSNetService]()

        super.init()
        
        self.afpBrowser.delegate = self
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        serviceList.append(aNetService)
        print("Found: \(aNetService)")
        if !moreComing {
            print("no more coming")
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