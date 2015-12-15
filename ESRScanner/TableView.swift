//
//  TableView source & delegate for scans view
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import UIKit

extension ScansViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scans.count()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! ScanTableViewCell

        let scan = scans[indexPath.row]
        cell.referenceNumber.text = scan.refNum.string()
        cell.accountNumber.text = scan.accNum.string()

        if scan.amount != nil {
            cell.amount.hidden = false
            cell.amount.text = scan.amount!.string()
        } else {
            cell.amount.hidden = true
        }

        if !scan.amountCheckDigitValid() || !scan.refNumCheckDigitValid() {
            cell.statusIcon.text = "⚠︎"
            cell.statusIcon.textColor = UIColor.orangeColor()
            cell.statusIcon.hidden = false
        } else if scan.transmitted {
            cell.statusIcon.text = "✓"
            cell.statusIcon.textColor = UIColor.greenColor()
            cell.statusIcon.hidden = false
        } else {
            cell.statusIcon.hidden = true
        }

        return cell
    }
    

}
