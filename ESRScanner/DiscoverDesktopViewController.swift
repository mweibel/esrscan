//
//  DiscoverDesktopViewController.swift
//  ESRScanner
//
//  Created by Michael on 02.12.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

class DiscoverDesktopViewController : UIViewController {
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionEstablished:", name: "AppConnectionEstablished", object: nil)
        Discover.sharedInstance.startSearch()
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func connectionEstablished(notification : NSNotification) {

    }
}
