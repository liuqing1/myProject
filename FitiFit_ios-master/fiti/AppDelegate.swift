//
//  AppDelegate.swift
//  fiti
//
//  Created by Matthew Mayer on 14/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        APIManager.shared

        let originalImage = UIImage(named: "nav-back")
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.backIndicatorImage = originalImage
        navigationBarAppearace.backIndicatorTransitionMaskImage = originalImage
        navigationBarAppearace.setTitleVerticalPositionAdjustment(0.4, forBarMetrics: .Default)

        let barBtnItemAttr = [
            NSForegroundColorAttributeName: UIColor.fitiGray(),
            NSFontAttributeName: UIFont(name: Constants.Fonts.MonsterratRegular, size: 15)!
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(barBtnItemAttr, forState: UIControlState.Normal)
//        UIBarButtonItem.appearance().setTitlePositionAdjustment(UIOffset.init(horizontal: 0, vertical: -10), forBarMetrics: UIBarMetrics.Default)
        
        if !WXApi.registerApp("wx9e2948a012457d46") {
            print("Failed to register with Weixin")
        }

        R.assertValid()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        print("Alipay returned with url \(url)");
        
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback:nil)
            return true;
        } else if url.absoluteString == "fiti:dummyacceptpayment" {
            print("post note dummyacceptpayment")
            NSNotificationCenter.defaultCenter().postNotificationName("dummyacceptpayment", object: nil)
            return true
        } else if url.absoluteString == "fiti:dummyrejectpayment" {
            print("post note dummyrejectpayment")
            NSNotificationCenter.defaultCenter().postNotificationName("dummyrejectpayment", object: nil)
            return true
        }
        return false
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    
    func onReq(req: BaseReq!) {
        
    }
    
    func onResp(resp: BaseResp!) {
        
    }
}

