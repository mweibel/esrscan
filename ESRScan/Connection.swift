//
//  Connection represents a connection to a desktop running ESRReceiver
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import Foundation
import Alamofire

class Connection : NSObject, NSNetServiceDelegate {
    var netService : NSNetService
    var baseUri : String?

    init(netService : NSNetService) {
        self.netService = netService
        super.init()
    }

    func sendConnectionInfo(parameters: [String: AnyObject]) {
        sendRequest("/connect", parameters: parameters)
    }

    func sendScan(parameters: [String: AnyObject], callback: Bool -> Void) {
        sendRequest("/scan", parameters: parameters, callback: callback)
    }

    func sendRequest(path: String, parameters: [String : AnyObject]) -> Alamofire.Request {
        let uri = self.baseUri! + path
        return Alamofire.request(.POST, uri, parameters: parameters, encoding: .JSON)
    }

    func sendRequest(path: String, parameters: [String : AnyObject], callback: Bool -> Void) {
        sendRequest(path, parameters: parameters).responseData { response in
            callback(response.result.isSuccess)
        }
    }

    func netServiceDidResolveAddress(sender: NSNetService) {
        self.netService = sender
        var fqdn = sender.hostName!.substringToIndex(sender.hostName!.endIndex.advancedBy(-1))

        // most likely the server is running on the local machine in this case. 
        // connecting via internal ip or local domain name doesn't work due to
        // unknown reasons. Force it to localhost in this case.
        // also using a preprocessor doesn't seem to work for unknown reasons.
        if TARGET_IPHONE_SIMULATOR == 1 {
            fqdn = "localhost"
        }

        self.baseUri = "http://\(fqdn):\(sender.port)"

        NSNotificationCenter.defaultCenter().postNotificationName(
            "AppConnectionEstablished",
            object: self,
            userInfo: [
                "hostName": sender.hostName!,
                "name": sender.name
            ]
        )
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
}