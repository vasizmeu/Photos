//
//  IAPHelper.swift
//  Photos
//
//  Created by Vasilica Costescu on 17/02/2015.
//  Copyright (c) 2015 Vasilica Costescu. All rights reserved.
//

import Foundation
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate {
    
    let productIdentifiers: NSSet
    var completionHandler: ((Bool, [SKProduct]!) -> Void)!
    
    override init() {
        
        productIdentifiers = NSSet(objects: "com.masteringios.Photos.WinterPhotos", "com.masteringios.Photos.CatPhotos", "com.masteringios.Photos.DogPhotos")
    }
    
    func requestProductsWithCompletionHandler(completionHandler:(Bool, [SKProduct]!) -> Void){
        self.completionHandler = completionHandler
        
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    //MARK: SKProductsRequestDelegate methods
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        println("product count \(response.products.count)")
        println("invalid product IDs \(response.invalidProductIdentifiers)")
        
        if response.products.count > 0 {
            var products: [SKProduct] = []
            
            for prod in response.products {
                if prod.isKindOfClass(SKProduct) {
                    products.append(prod as SKProduct)
                }
            }
            
            completionHandler(true, products)
        }
    }

    func request(request: SKRequest!, didFailWithError error: NSError!) {
        
        completionHandler(false, nil)
    }
}
