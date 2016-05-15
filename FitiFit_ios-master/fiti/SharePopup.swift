//
//  SharePopup.swift
//  fiti
//
//  Created by Daniel Contreras on 3/18/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import Social

class SharePopup: NSObject {
    
    static var sharePopupView : SharePopupView?
    
    class func showPopupForView(view : UIView, animated: Bool = false) {
        
        if sharePopupView == nil {
            if let v = NSBundle.mainBundle().loadNibNamed("SharePopupView", owner: self, options: nil)[0] as? SharePopupView {
                sharePopupView = v
            }
        }
        
        if let sharePopupView = sharePopupView {
            sharePopupView.popupView.layer.cornerRadius = 4
            sharePopupView.lblShareExperience.roundCorners([.TopLeft, .TopRight], radius: 4)
            sharePopupView.translatesAutoresizingMaskIntoConstraints = false
            sharePopupView.removeFromSuperview()
            sharePopupView.alpha = 1
            view.addSubview(sharePopupView)
            
            // constraints
            let views = ["sharePopupView" : sharePopupView]
            var constraints = [NSLayoutConstraint]()
            let vCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sharePopupView]-0-|", options: [], metrics: nil, views: views)
            constraints += vCons
            let hCons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[sharePopupView]-0-|", options: [], metrics: nil, views: views)
            constraints += hCons
            NSLayoutConstraint.activateConstraints(constraints)
            
            if animated {
                sharePopupView.alpha = 0
                UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                    sharePopupView.alpha = 1
                })
            }
        }
    }
    
    class func hide() {
        if let sharePopupView = sharePopupView {
            UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                sharePopupView.alpha = 0
                }, completion: { (completed) -> Void in
                    sharePopupView.removeFromSuperview()
            })
        }
    }
}

class SharePopupView: UIView {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblShareExperience: UILabel!
    @IBOutlet weak var lblWeibo: UILabel!
    @IBOutlet weak var lblWechat: UILabel!
    @IBOutlet weak var lblFacebook: UILabel!
    @IBOutlet weak var btnNoThanks: UIButton!
    
    var delegate:SharePopupViewDelegate!
    
    override func awakeFromNib() {
        lblShareExperience.text = "share_experience".localized
        lblWeibo.text = "share_weibo".localized
        lblWechat.text = "share_wechat".localized
        lblFacebook.text = "share_facebook".localized
        btnNoThanks.setTitle("share_no".localized, forState: .Normal)
    }
    
    @IBAction func onWeibo(sender: AnyObject) {
        self.delegate.shareOnWeibo()
    }
    
    @IBAction func onWeChat(sender: AnyObject) {
        self.delegate.shareOnWeChat()
    }
    
    @IBAction func onFacebook(sender: AnyObject) {
        self.delegate.shareOnFacebook()
    }
    
    @IBAction func onNoThanks(sender: AnyObject) {
        self.delegate.skipShare()
    }
    
}

protocol SharePopupViewDelegate {
    func shareOnWeibo()
    func shareOnWeChat()
    func shareOnFacebook()
    func skipShare()
}