//
//  TrainerTutorialView.swift
//  fiti
//
//  Created by Matthew Mayer on 21/03/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

//
//  FitiLoadingHUD.swift
//  fiti
//
//  Created by Juan Manuel Fluxa on 1/19/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TrainerTutorial : NSObject {
    
    private static var trainerTutorialView : TrainerTutorialView?
    
    class func showTutorial(view : UIView?) {
        
        let animated = true
        trainerTutorialView = nil
        
        if let v = NSBundle.mainBundle().loadNibNamed(R.nib.trainerTutorialView.name, owner: self, options: nil)[0] as? TrainerTutorialView {
            trainerTutorialView = v
            v.setup()
        }
       
        
        if let trainerTutorialView = trainerTutorialView {
            trainerTutorialView.translatesAutoresizingMaskIntoConstraints = false
            trainerTutorialView.removeFromSuperview()
            trainerTutorialView.alpha = 1
            view?.addSubview(trainerTutorialView)
            
            // constraints
            let views = ["v" : trainerTutorialView]
            var constraints = [NSLayoutConstraint]()
            let vCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v]-0-|", options: [], metrics: nil, views: views)
            constraints += vCons
            let hCons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics: nil, views: views)
            constraints += hCons
            NSLayoutConstraint.activateConstraints(constraints)
            
            if animated {
                trainerTutorialView.alpha = 0
                UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                    trainerTutorialView.alpha = 1
                })
            }
            trainerTutorialView.tut1X.constant = 0
            
        }
        
    }
    
    class func hide() {
        if let trainerTutorialView = trainerTutorialView {
            trainerTutorialView.hide()
        }
        trainerTutorialView = nil
    }
    
    
}

class TrainerTutorialView : UIView {
    @IBOutlet var tut2X:NSLayoutConstraint!
    @IBOutlet var tut1X:NSLayoutConstraint!
    @IBOutlet var button:UIButton!
    
    @IBOutlet var headline1:UILabel!
    @IBOutlet var headline2:UILabel!
    @IBOutlet var body1:UILabel!
    @IBOutlet var body2:UILabel!
    
    
    
    var page = 0
    func setup() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.insertSubview(blurEffectView, atIndex: 0)
        
        let left = UISwipeGestureRecognizer(target: self, action: "onLeft:")
        left.direction = .Left
        let right = UISwipeGestureRecognizer(target: self, action: "onRight:")
        right.direction = .Right
        self.addGestureRecognizer(left)
        self.addGestureRecognizer(right)
        tut1X.constant = 0
        tut2X.constant = self.frame.size.width
        
        headline1.text = "tut_headline_1".localized
        headline2.text = "tut_headline_2".localized
        body1.text = "tut_body_1".localized
        body2.text = "tut_body_2".localized
        
        button.setTitle("tut_btn".localized, forState: .Normal)
        
    }
    func onLeft(gr:UIGestureRecognizer) {
        if (page==0) {
            page = 1
            tut1X.constant = -self.frame.size.width
            tut2X.constant = 0
            UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                self.layoutIfNeeded()
            })
            
        }
    }
    @IBAction func onButton(sender:UIButton) {
        hide()
    }
    func onRight(gr:UIGestureRecognizer) {
        if (page==1) {
            page = 0
            tut1X.constant = 0
            tut2X.constant = self.frame.size.width
            UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                self.layoutIfNeeded()
            })
        }
    }
    func hide() {
        UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (completed) -> Void in
                self.removeFromSuperview()
        })
    }
    
    
}
