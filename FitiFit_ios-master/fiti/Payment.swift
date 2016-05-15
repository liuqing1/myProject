//
//  Payment.swift
//  fiti
//
//  Created by Matthew Mayer on 05/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
struct Payment {
    enum PaymentStatus: Int {
        case PaySuccess = 9000
        case Processing = 8000
        case PayFailure = 4000
        case Cancel = 6001
        case NetworkError = 6002
        case Unknown = -1
    }
    static func isAlipayInstalled()->Bool {
        let url = NSURL(string: "alipay://")!
        return UIApplication.sharedApplication().canOpenURL(url)
    }
    static func pay(amount:Double, name:String, desc:String, callback:(PaymentStatus -> Void)) {
        print("pay \(amount)");
        
        let partner = "2088121683663493";
        let seller = "payment@letsfiti.com";
        let privateKey = NSBundle.mainBundle().infoDictionary!["AliPayPrivateKey"] as! String
        let appScheme = "fiti"
        
        
        let order = Order()
        order.partner = partner
        order.seller = seller
        order.tradeNO = randomAlphaNumericString(15)
        order.productName = name;
        order.productDescription = desc;
        order.amount = String(format:"%.2f",amount)
        
        //order.notifyURL =  "http://letsfiti.com/alipaynotify"; //回调URL
        
        order.service = "mobile.securitypay.pay";
        order.paymentType = "1";
        order.inputCharset = "utf-8";
        order.itBPay = "30m";
        order.showUrl = "m.alipay.com";
        
        let orderSpec = order.description;
        print(orderSpec);
        
        let signer = RSADataSigner(privateKey: privateKey)
        
        if let signedString = signer.signString(orderSpec) {
            let orderString = String(format:"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, "RSA")
            AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme) { resultDict  in
                print("hit callback");
                if let r = resultDict["resultStatus"] as? String, i = Int(r), status = PaymentStatus(rawValue: i) {
                    callback(status)
                    return;
                }
                callback(.Unknown)
            }
        } else {
            callback(.Unknown)
        }
        
    }
    static func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}