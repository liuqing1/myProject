//
//  VerifyViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 09/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class VerifyViewController: RespondsToKeyboardViewController {
    @IBOutlet var tfCode : UITextFieldFiti!
    @IBOutlet var nextBtn : UIButton!
    var phone:String?
    var country:String?
    var password:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        setLocalizedTitle("Mobile Verification")
        showNavBar()
        tfCode.placeholder = "Enter verification code".localized
        nextBtn.setTitle("next".localized.uppercaseString, forState: .Normal)
    }
    @IBAction func onNext() {
        guard let country = country, phone=phone, code = tfCode.text else {
            return;
        }
        FitiLoadingHUD.showHUDForView(view, text: "")
        APIManager.shared.confirmTrainee(country, phone: phone, code:code, success: { trainee in
            print("Trainee is \(trainee)");
            self.patchPassword()
            }) { err in
            self.handleError(err);
        }
    }
    private func patchPassword() {
        print("verify success, now patch password");
        APIManager.shared.updateTrainee(["password":password!], success: {
            print("patch worked!");
            self.refreshProfile()
            }) { err in
            self.handleError(err);
        }
    }
    private func refreshProfile() {
        print("now refresh profile");
        APIManager.shared.refreshMe({
            FitiLoadingHUD.hide()
            self.performSegueWithIdentifier("Next", sender: nil)
            }) { err in
            self.handleError(err);
        }
    }
    private func handleError(err:String) {
        FitiLoadingHUD.hide()
        let alert = UIAlertController(title: err, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        print("err \(err)");
    }
}
