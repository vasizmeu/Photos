//
//  RestoreFooterView.swift
//  Photos
//
//  Created by Vasilica Costescu on 09/03/2015.
//  Copyright (c) 2015 Vasilica Costescu. All rights reserved.
//

import UIKit
import StoreKit

class RestoreFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func restoreButtonPressed(sender: UIButton) {
        sender.hidden = true
        activityIndicator.startAnimating()
        
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func downloadFinished() {

        activityIndicator.stopAnimating()
        restoreButton.hidden = false
    }
}
