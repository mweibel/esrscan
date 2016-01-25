//
//  IntroScreen1.swift
//  ESRScan
//
//  Created by Michael on 25/01/16.
//  Copyright © 2016 Michael Weibel. All rights reserved.
//

import UIKit

class IntroScreen1: UIViewController {
    @IBAction func didTapAppLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://esrscan.openflex.net")!)
    }
}