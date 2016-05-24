//
//  Main navigation controller
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import UIKit

class MainNavigationController : UINavigationController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        trackView("MainNavigationController")
        setHideIntroView()
    }

    override func shouldAutorotate() -> Bool {
        guard let currentViewController = topViewController else {
            return true
        }
        return currentViewController.shouldAutorotate()
    }
}