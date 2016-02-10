//
//  Discover utility for bonjour/zeroconf
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import Foundation

class Discover : NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    var afpBrowser : NSNetServiceBrowser
    var connection : Connection?
    var netService: NSNetService?
    var searching : Bool = false

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

    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("didnotresolve")
    }

    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        print("didnotpublish")
    }

    func netServiceWillResolve(sender: NSNetService) {
        print("will resolve")
    }

    func netServiceDidResolveAddress(sender: NSNetService) {
        print("didresolveaddress")
    }

    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("didstopsearch")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("didremoveservice")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        print("didremovedomain")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("didnotsearch")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print("didfinddomain")
    }

    func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
        print("didacceptconnectionwithinputstream")
    }

    func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {
        print("didupdatetxtrecorddata")
    }

    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("willsearch")
    }

    func netServiceDidPublish(sender: NSNetService) {
        print("didpublish")
    }

    func netServiceDidStop(sender: NSNetService) {
        print("didstop")
    }

    func netServiceWillPublish(sender: NSNetService) {
        print("willpublish")
    }

    func startSearch() {
        if !searching {
            afpBrowser.searchForServicesOfType("_esrhttp._tcp.", inDomain: "local.")
            searching = true
        }
    }

    func stop() {
        afpBrowser.stop()
        searching = false
    }
}