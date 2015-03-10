//
//  PaymentTransactionObserver.swift
//  Photos
//
//  Created by Vasilica Costescu on 23/02/2015.
//  Copyright (c) 2015 Vasilica Costescu. All rights reserved.
//

import Foundation
import StoreKit

let IAPTransactionInProgress = "IAPTransactionInProgress"
let IAPTransactionFailed = "IAPTransactionFailed"
let IAPTransactionComplete = "IAPTransactionComplete"
let IAPTransactionRestore = "IAPTransactionRestore"

let IAPDownloadWaiting = "IAPDownloadWaiting"
let IAPDownloadActive = "IAPDownloadActive"
let IAPDownloadFinished = "IAPDownloadFinished"
let IAPDownloadFailed = "IAPDownloadFailed"

class PaymentTransactionObserver : NSObject, SKPaymentTransactionObserver {
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
     
        for transaction in transactions {
            
            if let trans = transaction as? SKPaymentTransaction {
                switch (trans.transactionState) {
                case .Purchasing:
                    showTransactionAsInProgress(false)
                case .Deferred:
                    showTransactionAsInProgress(true)
                case .Failed:
                    failedTransaction(trans)
                case .Purchased:
                    completeTransaction(trans)
                case .Restored:
                    restoreTransaction(trans)
                }
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedDownloads downloads: [AnyObject]!) {
        
        for d in downloads {
            
            if let download = d as? SKDownload {
                switch (download.downloadState) {
                case .Waiting:
                    waitingDownload(download)
                case .Active:
                    activeDownload(download)
                case .Finished:
                    finishedDownload(download)
                case .Failed:
                    failedDownload(download)
                case .Cancelled:
                    cancelledDownload(download)
                case .Paused:
                    pausedDownload(download)
                }
            }
        }        
    }
    
    //MARK: Payment transaction related methods
    func showTransactionAsInProgress(deferred: Bool) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionInProgress, object: deferred)
    }
    
    func failedTransaction(transaction: SKPaymentTransaction) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionFailed, object: transaction.error)
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func completeTransaction(transaction: SKPaymentTransaction) {
        
        print("id \(transaction.transactionIdentifier)")
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionComplete, object: transaction)
        
        
        if let downloads = transaction.downloads {
            SKPaymentQueue.defaultQueue().startDownloads(downloads)
        }
        
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction) {
        
        let productId = "com.masteringios.Photos.CatPhotos" //hard coded the restore product instead of reading it from user defaults
        
        if productId == transaction.payment.productIdentifier {
            
            NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionRestore, object: transaction)
            
            if let downloads = transaction.downloads {
                SKPaymentQueue.defaultQueue().startDownloads(downloads)
            }
        }                
    }
    
    //MARK: Download related methods
    
    func waitingDownload(download: SKDownload) {
        NSNotificationCenter.defaultCenter().postNotificationName(IAPDownloadWaiting, object: download)
    }
    
    func activeDownload(download: SKDownload) {
        NSNotificationCenter.defaultCenter().postNotificationName(IAPDownloadActive, object: download)
    }
    
    func finishedDownload(download: SKDownload) {
        
        moveDownloadedFiles(download)
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPDownloadFinished, object: nil)
        
        SKPaymentQueue.defaultQueue().finishTransaction(download.transaction)
    }
    
    func failedDownload(download: SKDownload) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPDownloadFailed, object: download)
        
        SKPaymentQueue.defaultQueue().finishTransaction(download.transaction) 
    }
    
    func cancelledDownload(download: SKDownload) {
        
        //nothing to do right now
    }
    
    func pausedDownload(download: SKDownload) {
        //won't implement at this time
    }
    
    //MARK: Helper method to move files
    
    func moveDownloadedFiles(download: SKDownload) {
        //move files to Documents folder
    }
    
}