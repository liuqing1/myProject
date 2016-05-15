//
//  FitiButton.swift
//  fiti
//
//  Created by Matthew Mayer on 29/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class FitiButton: UIButton {
    override var enabled:Bool {
        didSet {
            self.backgroundColor = enabled ? UIColor.fitiBlue() : UIColor.fitiLightGray()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    required override init(frame:CGRect) {
        super.init(frame:frame)
    }


}
