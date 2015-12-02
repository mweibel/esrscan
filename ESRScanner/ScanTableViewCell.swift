//
//  TableCell.swift
//  ESRScanner
//
//  Created by Michael on 30.11.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

class ScanTableViewCell : UITableViewCell {
    @IBOutlet var referenceNumber: UILabel!
    @IBOutlet var accountNumber: UILabel!
    @IBOutlet var amount: UILabel!
    @IBOutlet var amountContainer: UIStackView!
}