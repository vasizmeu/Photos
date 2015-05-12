//
//  MasterViewController.swift
//  Photos
//
//  Created by Vasilica Costescu on 17/02/2015.
//  Copyright (c) 2015 Vasilica Costescu. All rights reserved.
//

import UIKit
import StoreKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = NSMutableArray()
    var footerView: RestoreFooterView? = nil
    let helper = IAPHelper()
    var noOfRestoreTransactions = 0
    var noOfDownloadCompleteorFailed = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
                        
        helper.requestProductsWithCompletionHandler({ (success, products) -> Void in
            if success {
                self.objects.addObjectsFromArray(products)
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Cannot retrieve products list right now.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
        let footerNib = UINib(nibName: "RestoreFooterView", bundle: nil)
        
        tableView.registerNib(footerNib, forHeaderFooterViewReuseIdentifier: "RestoreFooter")
        
        footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("RestoreFooter") as? RestoreFooterView
        
        tableView.tableFooterView = footerView
        
        signUpForNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let product = objects[indexPath.row] as! SKProduct
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = product
                controller.title = product.localizedTitle
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let product = objects[indexPath.row] as! SKProduct
        cell.textLabel!.text = product.localizedTitle
        return cell
    }
    
    //MARK: - Notifications methods
    
    func signUpForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedRestoreTransactionNotification:", name: IAPTransactionRestore, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadFinishedNotification:", name: IAPDownloadFinished, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadFailedNotification:", name: IAPDownloadFailed, object: nil)
    }
    
    func receivedRestoreTransactionNotification(notification: NSNotification) {
        noOfRestoreTransactions++
    }
    
    func receivedDownloadFinishedNotification(notification: NSNotification) {
        noOfDownloadCompleteorFailed++
        
        if (noOfDownloadCompleteorFailed == noOfRestoreTransactions) {
            restoreFinished()
        }
    }
    
    func receivedDownloadFailedNotification(notification: NSNotification) {
        
        showErrorMessage()
        receivedDownloadFinishedNotification(notification)
    }
    
    func restoreFinished(){
        footerView?.downloadFinished()
        noOfRestoreTransactions = 0
        noOfDownloadCompleteorFailed = 0
    }
    
    func showErrorMessage() {
        //show an alert view
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

