//
//  IAPManager.swift
//  Secure Kit VPN
//
//  Created by Mairambek on 4/19/20.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
    let inAppPurchasesSharedSecret = "031953b8679a473d8507877144b1f442"
 
    static let productNotificationIdentifire = "IAPManagerIdentifire"
    static let purchaseErrorNotificationIdentifire = "PurchaseErrorNotificationIdentifire"
    static let purchaseSuccessNotificationIdentifire = "PurchaseSuccessNotificationIdentifire"
    static let subscriptionExpiredNotificationIdentifire = "SubscriptionExpiredNotificationIdentifire"

    static let shared = IAPManager()
    
    private var isRenewSubscription: Bool = false

    private override init() {}
    
    var products: [SKProduct] = []
    let paymentQueue = SKPaymentQueue.default()
    
    public func setupPurchases(callback: @escaping(Bool) -> ()) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            callback(true)
            return
        }
        callback(false)
   }
    
    public func getProducts() {
        let identifire: Set = [
            IAPProducts.LiteVPN.rawValue,
            IAPProducts.StandardVPN.rawValue,
            IAPProducts.DoubleVPN.rawValue,
            IAPProducts.PerfectVPN.rawValue
        ]
        
        let productRequest = SKProductsRequest(productIdentifiers: identifire)
        productRequest.delegate = self
        productRequest.start()
    }
    
    public func priceOf(productWith identifire: String) -> String {
        guard let product = products.filter({ $0.productIdentifier == identifire}).first else { return "" }
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price)!
    }

    public func purchase(productWith identifire: String, isRenewed: Bool) {
        guard let product = products.filter({ $0.productIdentifier == identifire}).first else { return }
        isRenewSubscription = isRenewed
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func restoreCompleteTransaction() {
        paymentQueue.restoreCompletedTransactions()
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred: break
            case .purchasing: break
            case .failed: failed(transaction: transaction)
            case .purchased: completed(transaction: transaction)
            case .restored: restored(transaction: transaction)
            @unknown default:
                print("Switch not full data")
            }
        }
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction error: \(transaction.error!.localizedDescription)")
            }
        }
        paymentQueue.finishTransaction(transaction)
        NotificationCenter.default.post(name: NSNotification.Name(IAPManager.purchaseErrorNotificationIdentifire), object: nil)
    }
    
    private func completed(transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
        self.receiptValidation()
    }
    
    private func restored(transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if (queue.transactions.count == 0)
        {
            NotificationCenter.default.post(name: NSNotification.Name(IAPManager.purchaseErrorNotificationIdentifire), object: nil)
            print("Nothing to restore...")
        }
    }
    
    func receiptValidation() {
        let receiptFileURL = Bundle.main.appStoreReceiptURL
        let receiptData = try? Data(contentsOf: receiptFileURL!)
        guard let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) else {
            return
        }
        if isRenewSubscription {
            DataManager.renewSubscription(recieptString,
                                          secretKey: inAppPurchasesSharedSecret)
            { (success) in
                if success {
                    NotificationCenter.default.post(name: NSNotification.Name(IAPManager.purchaseSuccessNotificationIdentifire), object: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(IAPManager.purchaseErrorNotificationIdentifire), object: nil)
                }
            }
        } else {
            DataManager.buySubscription(recieptString, secretKey: inAppPurchasesSharedSecret) { (success) in
                if success {
                    NotificationCenter.default.post(name: NSNotification.Name(IAPManager.purchaseSuccessNotificationIdentifire), object: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(IAPManager.purchaseErrorNotificationIdentifire), object: nil)
                }
            }
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            self.products = response.products
        }
    }
}
