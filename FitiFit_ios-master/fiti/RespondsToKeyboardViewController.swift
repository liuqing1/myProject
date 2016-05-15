//
//  RespondsToKeyboard.swift
//  fiti
//
//  Created by Matthew Mayer on 22/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//
import UIKit

class RespondsToKeyboardViewController : BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func onKeyboardWillShow(notification : NSNotification) {
        if let dic = notification.userInfo {
            if let frameBeginObj = dic[UIKeyboardFrameBeginUserInfoKey], let frameEndObj = dic[UIKeyboardFrameEndUserInfoKey], let animDurObj = dic[UIKeyboardAnimationDurationUserInfoKey], let animCurveObj = dic[UIKeyboardAnimationCurveUserInfoKey] {
                
                let frameBegin = frameBeginObj.CGRectValue
                let bounds = UIScreen.mainScreen().bounds
                if frameBegin.origin.y == bounds.height {
                    let frameEnd = frameEndObj.CGRectValue
                    let duration = animDurObj.doubleValue
                    let animOpt = UIViewAnimationOptions(rawValue: animCurveObj.unsignedIntegerValue)
                    
                    UIView.animateWithDuration(duration, delay: 0, options: animOpt, animations: { () -> Void in
                        let f = self.view.frame
                        self.view.frame = CGRectMake(f.origin.x, f.origin.y, f.width, f.height - frameEnd.height)
                        }, completion: nil)
                }
                
            }
        }
    }
    
    func onKeyboardWillHide(notification : NSNotification) {
        if let dic = notification.userInfo {
            if let animDurObj = dic[UIKeyboardAnimationDurationUserInfoKey], let animCurveObj = dic[UIKeyboardAnimationCurveUserInfoKey] {
                
                let duration = animDurObj.doubleValue
                let animOpt = UIViewAnimationOptions(rawValue: animCurveObj.unsignedIntegerValue)
                let bounds = UIScreen.mainScreen().bounds
                
                UIView.animateWithDuration(duration, delay: 0, options: animOpt, animations: { () -> Void in
                    let f = self.view.frame
                    self.view.frame = CGRectMake(f.origin.x, f.origin.y, f.width, bounds.height)
                    }, completion: nil)
                
                
            }
        }
        
    }
    func onKeyboardDidShow(notification : NSNotification) {
    }
    func onKeyboardDidHide(notification : NSNotification) {
    }
    
}

