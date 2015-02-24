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
    
    
    func showTransactionAsInProgress(deferred: Bool) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionInProgress, object: deferred)
    }
    
    func failedTransaction(transaction: SKPaymentTransaction) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionFailed, object: transaction.error)
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func completeTransaction(transaction: SKPaymentTransaction) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(IAPTransactionComplete, object: transaction)
        
        //will add code to start downloading photos
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction) {
        
    }
}