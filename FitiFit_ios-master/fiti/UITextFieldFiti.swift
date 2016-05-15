//
//  UITextFieldFiti.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/11/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import Foundation

class UITextFieldFiti: UITextField {
    
    let textPadding : CGFloat = 0.0
    var bottomBorder : CALayer?
    var placeholderText : String?
    var placeHolderViewS : UILabel?
    var placeHolderViewB : UILabel?
    var textBounds : CGRect?
    var prefixView : UILabel?
    
    var prefixString : String = "" {
        didSet {
            let paddedString = "\(prefixString)  "
            if prefixView == nil && prefixString != "" {
                if let font = UIFont(name: Constants.Fonts.MonsterratRegular, size: 15) {
                    let size = (paddedString as NSString).sizeWithAttributes([NSFontAttributeName: font])
                    prefixView = UILabel(frame: CGRectMake(0,0,size.width + textPadding,size.height))
                    prefixView!.font = font
                    prefixView!.textColor = UIColor.colorWithHexString(Constants.Colors.FitiGrayDark)
                    prefixView!.textAlignment = .Left
                    self.leftView = prefixView
                    self.leftViewMode = .Never
                }
            }
            if let prefixView = prefixView {
                prefixView.text = paddedString
                if let font = UIFont(name: Constants.Fonts.MonsterratRegular, size: 15) {
                    let size = (paddedString as NSString).sizeWithAttributes([NSFontAttributeName: font])
                    prefixView.frame = CGRectMake(0,0,size.width + textPadding,size.height)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
        
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if bottomBorder == nil {
            bottomBorder = CALayer()
            let width = CGFloat(1.0)
            bottomBorder!.borderColor = UIColor.colorWithHexString(Constants.Colors.FitiGraySuperLight).CGColor
            bottomBorder!.frame = CGRect(x: 0, y: frame.size.height - width, width:  frame.size.width, height: frame.size.height)
            bottomBorder!.borderWidth = width
            layer.addSublayer(bottomBorder!)
            layer.masksToBounds = true
        }
        
        
        if placeHolderViewS == nil {
            placeHolderViewS = UILabel()
            if let placeholder = placeholder {
                placeHolderViewS!.text = placeholder
            }
            placeHolderViewS!.textColor = UIColor.colorWithHexString(Constants.Colors.FitiBlue)
            placeHolderViewS!.font = UIFont(name: Constants.Fonts.MonsterratLight, size: 12)
            placeHolderViewS!.hidden = true
            addSubview(placeHolderViewS!)
        }
        
        if placeHolderViewB == nil {
            placeHolderViewB = UILabel()
            if let placeholder = placeholder {
                placeHolderViewB!.text = placeholder
            }
            placeHolderViewB!.textColor = UIColor.colorWithHexString(Constants.Colors.FitiGrayLight)
            placeHolderViewB!.font = UIFont(name: Constants.Fonts.MonsterratRegular, size: 15)
            addSubview(placeHolderViewB!)
        }
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var leftViewSize = CGSizeMake(0, 0)
        if let leftView = leftView {
            leftViewSize = CGSizeMake(leftView.frame.width - textPadding, leftView.frame.height)
        }
        let newBounds = CGRectMake(bounds.origin.x + textPadding + leftViewSize.width, bounds.origin.y, bounds.width - 2 * textPadding, bounds.height)
        return newBounds
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        let newBounds = CGRectMake(bounds.origin.x + textPadding, bounds.origin.y, bounds.width - 2 * textPadding, bounds.height)
        
        if let placeHolderViewB = placeHolderViewB {
            placeHolderViewB.frame = newBounds
        }
        
        if let placeHolderViewS = placeHolderViewS {
            placeHolderViewS.frame = CGRectMake(newBounds.origin.x, -5, frame.width - newBounds.origin.x, 20)
        }
        
        return CGRectMake(0, 0, 0, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var leftViewSize = CGSizeMake(0, 0)
        if let leftView = leftView {
            leftViewSize = CGSizeMake(leftView.frame.width - textPadding, leftView.frame.height)
        }
        let newBounds = CGRectMake(bounds.origin.x + textPadding + leftViewSize.width, bounds.origin.y, bounds.width - 2 * textPadding, bounds.height)
        return newBounds
    }
    
    override func becomeFirstResponder() -> Bool {
        
        if text == "" {
            let finalFrame = placeHolderViewS!.frame
            placeHolderViewS!.frame = placeHolderViewB!.frame
            placeHolderViewS!.hidden = false
            placeHolderViewB!.hidden = true
            self.leftViewMode = .Always
            
            UIView.animateWithDuration(Constants.Values.AnimationFast, animations: { () -> Void in
                self.placeHolderViewS!.frame = finalFrame
                }, completion: { (complete) -> Void in
                    
            })
        }
        
        let color = CABasicAnimation(keyPath: "borderColor");
        color.fromValue = UIColor.colorWithHexString(Constants.Colors.FitiGraySuperLight).CGColor;
        color.toValue = UIColor.colorWithHexString(Constants.Colors.FitiBlue).CGColor;
        color.duration = 0.3;
        color.repeatCount = 1;
        bottomBorder!.addAnimation(color, forKey: "borderColor")
        bottomBorder!.borderColor = UIColor.colorWithHexString(Constants.Colors.FitiBlue).CGColor;
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        
        if text == "" {
            placeHolderViewS!.hidden = true
            placeHolderViewB!.hidden = false
            self.leftViewMode = .Never
        }
        
        bottomBorder!.borderColor = UIColor.colorWithHexString(Constants.Colors.FitiGraySuperLight).CGColor
        
        return super.resignFirstResponder()
    }
    

}
