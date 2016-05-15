//
//  SignInViewController.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/8/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

private let SegueToTrainerFTE = "LoginToTrainerFTE"
private let SegueToTraineeMain = "LoginToTraineeMain"

class LogInViewController: RespondsToKeyboardViewController {
    
    @IBOutlet var tfPhone : UITextFieldFiti!
    @IBOutlet var tfPassw : UITextFieldFiti!
    @IBOutlet var btForgot : UIButton!
    @IBOutlet var btDone : UIButton!
    @IBOutlet var lblCodeTitle : UILabel!
    @IBOutlet var btChangeCode : UIButton!
    
    let rows = ["China".localized, "Taiwan".localized, "Hong Kong".localized]
    let codes = ["+86", "+886", "+852"]
    let apiCodes = ["CN","TW","HK"]

    var countryIndex=0
    
    var trainee:Trainee?
    var trainer:Trainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        
        setLocalizedTitle("sign_in")
        
        tfPhone.placeholder = "phone".localized
        tfPhone.prefixString = codes[countryIndex]
        tfPassw.placeholder = "password".localized
        btForgot.setTitle("forgot password".localized, forState: .Normal)
        btDone.setTitle("done".localized.uppercaseString, forState: .Normal)
        lblCodeTitle.text = "not_in_china".localized
        btChangeCode.setTitle("change_country".localized, forState: .Normal)
        
       
        
    }
    
   
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar()
    }
    
    
    
   
    
    @IBAction func onForgotPassword(sender : UIButton) {
        guard let phone = tfPhone.text where !phone.isEmpty else {
            let alert = UIAlertController(title: nil, message: "forgot_password_alert".localized, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return;
        }
        self.view.endEditing(true)
        
        FitiLoadingHUD.showHUDForView(view, text: "loading".localized, animated: true)
        
        APIManager.shared.forgotPassword(apiCodes[countryIndex], phone: phone, success: { (success) -> Void in
            
            FitiLoadingHUD.hide()
            
            let alert = UIAlertController(title: nil, message: success, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            }) { message in
                FitiLoadingHUD.hide()
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                alert.addAction( UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func onDone(sender : UIButton?) {
        guard let phone = tfPhone.text,password = tfPassw.text else {
            return;
        }
        self.view.endEditing(true)
        
        FitiLoadingHUD.showHUDForView(view, text: "loading".localized, animated: true)
        
        APIManager.shared.login(apiCodes[countryIndex], phone: phone, password: password, success: { (trainer, trainee) -> Void in
            
            FitiLoadingHUD.hide()
            
            if let trainer = trainer {
                self.trainer = trainer
                self.performSegueWithIdentifier(SegueToTrainerFTE, sender: nil)
            }
            if let trainee = trainee {
                self.trainee = trainee
                let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
                if !launchedBefore {
                    self.presentViewController(R.storyboard.login.tutorialPageViewController()!, animated: true, completion: nil)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
                    NSUserDefaults.standardUserDefaults().synchronize()
                } else {
                    self.performSegueWithIdentifier(SegueToTraineeMain, sender: nil)
                }
            }
            }) { message in
                FitiLoadingHUD.hide()
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                alert.addAction( UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        }
     
    }
    
    @IBAction func onChangeCode(sender : UIButton) {
        // TODO: real data
        ActionSheetStringPicker.showPickerWithTitle("", rows: rows, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) -> Void in
            self.countryIndex = selectedIndex
            self.tfPhone.prefixString = self.codes[self.countryIndex]
            }, cancelBlock: { (picker) -> Void in
                
            }, origin: self.view)
    }
    
}

extension LogInViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == tfPhone {
            tfPassw.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            onDone(nil)
        }
        
        return true
    }
}
