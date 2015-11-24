//
//  Connection.swift
//  ESRScanner
//
//  Created by Michael on 20.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
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

    func sendRequest(parameters: [String : AnyObject]) {
        print(parameters)
        let uri = self.baseUri! + "/scan"
        Alamofire.request(.POST, uri, parameters: parameters, encoding: .JSON).responseData { response in
            print(response.request)
            print(response.response)
            print(response.result)
        }
    }

    func netServiceDidResolveAddress(sender: NSNetService) {
        self.netService = sender
        var fqdn = sender.hostName!.substringToIndex(sender.hostName!.endIndex.advancedBy(-1))

        // most likely the server is running on the local machine in this case. 
        // connecting via internal ip or local domain name doesn't work due to
        // unknown reasons. Force it to localhost in this case.
        if TARGET_OS_SIMULATOR == 1 {
            fqdn = "localhost"
        }

        self.baseUri = "http://\(fqdn):\(sender.port)"
    }

    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("DID NOT RESOLVE \(sender) \(errorDict)")
    }

    func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
        print("YAY CONNECTED")
    }

    func netServiceWillResolve(sender: NSNetService) {
        print("will resolve")
    }

    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        print("did not publish")
    }

    func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {
        print("did update txt record data")
    }

    func netServiceDidPublish(sender: NSNetService) {
        print("did publish")
    }

    func netServiceDidStop(sender: NSNetService) {
        print("did stop")
    }

    func netServiceWillPublish(sender: NSNetService) {
        print("will publish")
    }
}