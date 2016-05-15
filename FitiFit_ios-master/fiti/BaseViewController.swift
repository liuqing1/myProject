//
//  BaseViewController.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/8/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    enum Theme {
        case Blue
        case White
        case Dark
    }
    var theme:Theme = .Blue
    var statusBarStyle:UIStatusBarStyle = UIStatusBarStyle.Default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .Plain, target: nil, action: nil)
        
    }
    override func supportedInterfaceOrientations()->UIInterfaceOrientationMask {
        return .Portrait
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        if let bar = self.navigationController?.navigationBar {
            switch theme {
            case .Blue:
                //blue navbar with "Fiti Fitness" title
                bar.translucent = false
                bar.barStyle = .Default
                bar.barTintColor = UIColor.fitiBlue()
                bar.tintColor = UIColor.whiteColor()
                bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                bar.shadowImage = UIImage()
                statusBarStyle = .LightContent
                let attr1 = [
                    NSForegroundColorAttributeName: UIColor.whiteColor(),
                    NSFontAttributeName: UIFont(name: Constants.Fonts.MonsterratLight, size: 18)!
                ]
                bar.titleTextAttributes = attr1
                var isHome = false
                if let navigationController = navigationController, topViewController = navigationController.topViewController {
                        isHome = topViewController.navigationItem.title == "home".localized
                    
                }
                if isHome {
                    navigationItem.titleView = customTitleView();
                } else {
                    navigationItem.titleView = nil;
                }
            case .White:
                //white navbar with normal title
                bar.translucent = true
                bar.barStyle = .Default
                bar.barTintColor = UIColor.whiteColor()
                bar.tintColor = UIColor.blackColor()
                bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                bar.shadowImage = UIImage()
                statusBarStyle = .Default
                let attr1 = [
                    NSForegroundColorAttributeName: UIColor.blackColor(),
                    NSFontAttributeName: UIFont(name: Constants.Fonts.MonsterratLight, size: 18)!
                ]
                bar.titleTextAttributes = attr1
                
            case .Dark:
                bar.translucent = true
                bar.barStyle = .Default
                let attr1 = [
                    NSForegroundColorAttributeName: UIColor.whiteColor(),
                    NSFontAttributeName: UIFont(name: Constants.Fonts.MonsterratLight, size: 18)!
                ]
                bar.titleTextAttributes = attr1

                
            }
            
            

            
        }
        
    }
    func customTitleView()->UIView? {
        if let img = UIImage(named: "logo-white") {
            return UIImageView(image: img)
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setLocalizedTitle(titleKey:String) {
        if let navigationController = navigationController {
            if let topViewController = navigationController.topViewController {
                topViewController.navigationItem.title = NSLocalizedString(titleKey, comment: "")
            }
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }

    func setNavBarRightButton(imageName: String, action: Selector) {
        let rightButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: imageName), style: UIBarButtonItemStyle.Plain, target: self, action: action)
        if let navigationController = navigationController {
            if let topViewController = navigationController.topViewController {
                topViewController.navigationItem.rightBarButtonItem = rightButton
            }
        }
    }
    
    func setNavBarRightButtonWithTitle(title: String, action: Selector) {
        let rightButton : UIBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightButton
        themeRightButton()
    }
    func themeRightButton() {
        if theme == .Dark || theme == .Blue {
            let barBtnItemAttr = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont(name: Constants.Fonts.MonsterratRegular, size: 15)!
            ]
            navigationItem.rightBarButtonItem?.setTitleTextAttributes(barBtnItemAttr, forState: UIControlState.Normal)
        }
    }
    
    func hideBackButton() {
        navigationItem.hidesBackButton = true
    }
    
    func hideNavBar() {
        if let navigationController = navigationController {
            navigationController.navigationBarHidden = true
        }
        
    }
    
    func showNavBar() {
        if let navigationController = navigationController {
            navigationController.navigationBarHidden = false
        }
    }
    
    


}
