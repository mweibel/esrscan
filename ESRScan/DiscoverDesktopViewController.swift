//
//  Discovery view controller
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import UIKit

class DiscoverDesktopViewController : UIViewController {
    @IBOutlet var statusIndicator: UILabel!
    @IBOutlet var skipButton: UIBarButtonItem!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        trackView("DiscoverDesktopViewController")
        setHideIntroView()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionEstablished:", name: "AppConnectionEstablished", object: nil)
        Discover.sharedInstance.startSearch()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func connectionEstablished(notification : NSNotification) {
        trackEvent("Connection", action: "Established", label: nil, value: nil)

        skipButton.enabled = false
        let name = String(notification.userInfo!["name"]!)
        statusIndicator.text = String(
            format: NSLocalizedString("Found %@",
                comment: "When a desktop computer has been found, this text is displayed on screen."),
            locale: NSLocale.currentLocale(),
            arguments: [name as CVarArgType]
        )
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: "showScansView:", userInfo: nil, repeats: false)
    }

    func showScansView(sender: DiscoverDesktopViewController) {
        performSegueWithIdentifier("showScansView", sender: self)
    }
}
