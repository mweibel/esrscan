//
//  Analytics.swift
//  ESRScanner
//
//  Created by Michael on 05/01/16.
//  Copyright © 2016 Michael Weibel. All rights reserved.
//

import Foundation
import Google

func trackView(name: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: name)

    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
}

func trackCaughtException(description: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    let dict = GAIDictionaryBuilder.createExceptionWithDescription(description, withFatal: false).build() as [NSObject : AnyObject]
    tracker.send(dict)
}