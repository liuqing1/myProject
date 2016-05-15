//
//  FitiLoadingHUD.swift
//  fiti
//
//  Created by Juan Manuel Fluxa on 1/19/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class FitiLoadingHUD : NSObject {
    
    private static var fitiLoadingView : FitiLoadingHUDView?
    
    class func showHUDForView(view : UIView, text : String, animated: Bool = false) {
        
        if fitiLoadingView == nil {
            if let v = NSBundle.mainBundle().loadNibNamed("FitiLoadingHUDView", owner: self, options: nil)[0] as? FitiLoadingHUDView {
                fitiLoadingView = v
            }
        }
        
        if let fitiLoadingView = fitiLoadingView {
            fitiLoadingView.randomize()
            fitiLoadingView.translatesAutoresizingMaskIntoConstraints = false
            fitiLoadingView.removeFromSuperview()
            fitiLoadingView.alpha = 1
            fitiLoadingView.lblText.text = text
            view.addSubview(fitiLoadingView)
            
            // constraints
            let views = ["fitiLoadingView" : fitiLoadingView]
            var constraints = [NSLayoutConstraint]()
            let vCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[fitiLoadingView]-0-|", options: [], metrics: nil, views: views)
            constraints += vCons
            let hCons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[fitiLoadingView]-0-|", options: [], metrics: nil, views: views)
            constraints += hCons
            NSLayoutConstraint.activateConstraints(constraints)
            
            if animated {
                fitiLoadingView.alpha = 0
                UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                    fitiLoadingView.alpha = 1
                })
            }
            
        }
        
    }
    
    class func hide() {
        if let fitiLoadingView = fitiLoadingView {
            UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                fitiLoadingView.alpha = 0
                }, completion: { (completed) -> Void in
                    fitiLoadingView.removeFromSuperview()
                    fitiLoadingView.stopTimer()
            })
        }
    }
    
    
}

class FitiLoadingHUDView : UIView {
    
    @IBOutlet var lblText : UILabel!
    @IBOutlet var icon : UIImageView!
    var timer:NSTimer?;
    func randomize() {
        let skill = Skill.allSkills().randomItem()
        let iconname = skill.icon!.stringByAppendingString("-active")
        icon.image = UIImage(named:iconname)
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("randomize"), userInfo: nil, repeats: false)
    }
    func stopTimer() {
        timer?.invalidate()
    }

}
