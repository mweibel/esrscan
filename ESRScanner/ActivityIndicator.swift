//
//  ActivityIndicator.swift
//  ESRScanner
//
//  Created by Michael on 04.12.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

class ActivityIndicator {
    var activityIndicator: UIActivityIndicatorView?

    init(view : UIView) {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator!.activityIndicatorViewStyle = .Gray
        activityIndicator!.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator!.startAnimating()
        view.addSubview(activityIndicator!)
    }

    func hide() {
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
}