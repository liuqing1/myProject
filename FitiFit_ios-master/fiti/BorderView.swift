//
//  BorderView.swift
//  fiti
//
//  Created by Matthew Mayer on 16/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit

@IBDesignable  class BorderView: UIView {
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
