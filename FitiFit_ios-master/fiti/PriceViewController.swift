//
//  PriceViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 02/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class PriceViewController: RespondsToKeyboardViewController {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var upperLbl: UILabel!
    @IBOutlet weak var lowerLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedTitle("price")
        theme = .White
        guard let me = APIManager.shared.meTrainer else {
            return
        }
        priceTxt.text = "\(me.price)"
        nextBtn.setTitle("next".localized.uppercaseString, forState: .Normal)
        nextBtn.addTarget(self, action: Selector("onNext"), forControlEvents: .TouchUpInside)
        upperLbl.text = "set_a_price".localized
        lowerLbl.text = "you_alone".localized
    }
    func onNext() {
        self.view.endEditing(true)
        
        let price:Int = Int(priceTxt.text ?? "0") ?? 0
        
        if price<=0 {
            return;
        }
        
        
        if let me = APIManager.shared.meTrainer {
            APIManager.shared.applyRealmTransaction {
                me.price = price
            }
            APIManager.shared.updateTrainer(["price":price], success: {
                print("updated price")
                }) { message in
                    print(message);
            }
            self.performSegueWithIdentifier("Next", sender: nil)
        }
    }
}
extension PriceViewController : UITextFieldDelegate {
    
}
