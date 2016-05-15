//
//  TrainerWelcomeController.swift
//  fiti
//
//  Created by Tuo on 1/19/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import UIKit

class TrainerWelcomeController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var tipLabel: UILabel!
    
    
    
    @IBOutlet weak var nextBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        titleLabel.text = String(format:"hello".localized, APIManager.shared.meTrainer?.name ?? "")
        
        let attrs = Constants.Attributes.getFitiSpacedStyle()
        
        tipLabel.attributedText = NSAttributedString(string: "please_complete".localized, attributes:attrs)
        //skipBtn.setTitle("skip_for".localized, forState: .Normal)
        nextBtn.setTitle("lets_go".localized.uppercaseString, forState: .Normal)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
    }
}