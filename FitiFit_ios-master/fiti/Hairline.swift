//
//  Hairline.swift
//  fiti
//
//  Created by Matthew Mayer on 22/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit

class Hairline: NSLayoutConstraint {
    override func awakeFromNib() {
        super.awakeFromNib()
        if ( constant == 1 ) {
            constant = 1/UIScreen.mainScreen().scale
        }
    }
}
