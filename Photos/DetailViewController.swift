//
//  DetailViewController.swift
//  Photos
//
//  Created by Vasilica Costescu on 17/02/2015.
//  Copyright (c) 2015 Vasilica Costescu. All rights reserved.
//

import UIKit
import StoreKit
import QuartzCore

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var detailItem: SKProduct? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    //MARK: Action methods
    
    @IBAction func buyPressed(sender: UIButton) {
        
        if let product = self.detailItem {
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.defaultQueue().addPayment(payment)
            
            updateUIForPurchaseInProgress(true)
        }
    }
    
    //MARK: Updating UI methods
    
    func configureView() {
        // Update the user interface for the detail item.
        if let product: SKProduct = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = product.localizedDescription
            }
            if let button = self.buyButton {
                configureBuyButton(product)
            }
            
        }
    }

    func configureBuyButton(product: SKProduct){
    
        let numberFormatter = NSNumberFormatter()
        
        numberFormatter.formatterBehavior = .Behavior10_4
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = product.priceLocale
        
        let formattedPrice = numberFormatter.stringFromNumber(product.price)
        
        let buttonTitle = String(format: " Buy for %@ ", formattedPrice!)
        
        buyButton.setTitle(buttonTitle, forState: .Normal)
        
        buyButton.layer.borderWidth = 1.0
        buyButton.layer.cornerRadius = 4.0
        buyButton.layer.borderColor = buyButton.tintColor?.CGColor
        
    }
    
    func updateUIForPurchaseInProgress(inProgress: Bool){
        
        buyButton.hidden = inProgress
        
        if inProgress {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func updateUIForDownloadInProgress(inProgress: Bool) {
        statusLabel.hidden = !inProgress
        progressView.hidden = !inProgress
    }
    
    func displayErrorAlert(error: NSError) {
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription , preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Purchase Notification methods
    
    func receivedPurchaseInProgressNotification(notification: NSNotification) {
        
        updateUIForPurchaseInProgress(true)
    }
    
    func receivedPurchaseFailedNotification(notification: NSNotification) {
        
        updateUIForPurchaseInProgress(false)
        
        let error = notification.object as! NSError
        
        displayErrorAlert(error)
    }
    
    func receivedPurchaseCompletedNotification(notification: NSNotification){
        
        updateUIForPurchaseInProgress(false)
    }
    
    
    //MARK: Download Notification methods
    
    func receivedDownloadWaitingNotification(notification: NSNotification) {
        
        statusLabel.text = "waiting"
        progressView.progress = 0.0
        
        updateUIForDownloadInProgress(true)
    }
    
    func receivedDownloadActiveNotification(notification: NSNotification) {
        
        let download = notification.object as! SKDownload
        
        statusLabel.text = "downloading content"
        progressView.progress = download.progress
        
        updateUIForDownloadInProgress(true)
    }
    
    func receivedDownloadFinishedNotification(notification: NSNotification) {
        
        statusLabel.text = "download complete"
        progressView.progress = 1.0
        
        buyButton.setTitle(" Purchased ", forState: .Normal)
        buyButton.enabled = false
        updateUIForPurchaseInProgress(false)
    }
    
    func receivedDownloadFailedNotification(notification: NSNotification) {
        
        let download = notification.object as? SKDownload
        let error = download?.error
        
        displayErrorAlert(error!)
    }
    
    //MARK: Notifications methods
    
    func signUpForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPurchaseInProgressNotification:", name: IAPTransactionInProgress, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPurchaseFailedNotification:", name: IAPTransactionFailed, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPurchaseCompletedNotification:", name: IAPTransactionComplete, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadWaitingNotification:", name: IAPDownloadWaiting, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadActiveNotification:", name: IAPDownloadActive, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadFinishedNotification:", name: IAPDownloadFinished, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadFailedNotification:", name: IAPDownloadFailed, object: nil)
    }
    
    //MARK: ViewController Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        signUpForNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

