//
//  Defaults.swift
//  ESRScan
//
//  Created by Michael on 05/01/16.
//  Copyright © 2016 Michael Weibel. All rights reserved.
//

import Foundation

func shouldHideIntroView() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey("hideIntroView")
}

func setHideIntroView() {
    if !shouldHideIntroView() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hideIntroView")
    }
}
