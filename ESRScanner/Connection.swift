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

    func sendRequest(parameters: [String : AnyObject], callback: Bool -> Void) {
        let uri = self.baseUri! + "/scan"
        Alamofire.request(.POST, uri, parameters: parameters, encoding: .JSON).responseData { response in
            callback(response.result.isSuccess)
        }
    }

    func netServiceDidResolveAddress(sender: NSNetService) {
        self.netService = sender
        var fqdn = sender.hostName!.substringToIndex(sender.hostName!.endIndex.advancedBy(-1))

        // most likely the server is running on the local machine in this case. 
        // connecting via internal ip or local domain name doesn't work due to
        // unknown reasons. Force it to localhost in this case.
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
}