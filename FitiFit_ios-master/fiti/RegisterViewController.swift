//
//  RegisterViewController.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/8/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import TTTAttributedLabel
class RegisterViewController: RespondsToKeyboardViewController {

    @IBOutlet var tfPhone : UITextFieldFiti!
    @IBOutlet var tfPassw : UITextFieldFiti!
    @IBOutlet var btDone : UIButton!
    @IBOutlet var lblCodeTitle : UILabel!
    @IBOutlet var btChangeCode : UIButton!
    
    @IBOutlet weak var btVerify: UIButton!
    @IBOutlet var lblTrainerSignUp : TTTAttributedLabel!
    
    var countryIndex=0
    
    
    let rows = ["China", "Taiwan", "Hong Kong"]
    let codes = ["+86", "+886", "+852"]
    let apiCodes = ["CN","TW","HK"]
    let fitiLink = "letsfiti.com"
    let fitiURL = "http://www.letsfiti.com/"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        setLocalizedTitle("Create an account")
        showNavBar()
        tfPhone.placeholder = "phone".localized
        tfPhone.prefixString = codes[countryIndex]
        tfPassw.placeholder = "password".localized
        btDone.setTitle("done".localized.uppercaseString, forState: .Normal)
        lblCodeTitle.text = "not_in_china".localized
        btChangeCode.setTitle("change_country".localized, forState: .Normal)
        
        lblTrainerSignUp.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        lblTrainerSignUp.delegate = self
        lblTrainerSignUp.linkAttributes = [kCTForegroundColorAttributeName : UIColor.fitiBlue().CGColor, kCTUnderlineStyleAttributeName : NSNumber(bool:false)]
        lblTrainerSignUp.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor.fitiBlue().CGColor, kCTUnderlineStyleAttributeName : NSNumber(bool:false)]
        
        let nsString = "trainer_sign_up".localized as NSString
        let range = nsString.rangeOfString(fitiLink)
        let url = NSURL(string: fitiURL)!
        lblTrainerSignUp.text = nsString as String
        lblTrainerSignUp.addLinkToURL(url, withRange: range)
    }
    

    @IBAction func onVerify(sender: AnyObject) {
        guard let phone = tfPhone.text, _ = tfPassw.text else {
            return;
        }
        FitiLoadingHUD.showHUDForView(view, text: "")
        APIManager.shared.signupTrainee(apiCodes[countryIndex], phone: phone, success: {
            FitiLoadingHUD.hide()
            self.didSignupWithTrainee()
            }) { err  in
                FitiLoadingHUD.hide()
                let alert = UIAlertController(title: err, message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
                
                
                self.presentViewController(alert, animated: true, completion: nil)
                print("err \(err)");
        }
    }
    func didSignupWithTrainee() {
        self.performSegueWithIdentifier("Next", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let phone = tfPhone.text else {
            return;
        }
        if (segue.identifier=="Next") {
            if let vc = segue.destinationViewController as? VerifyViewController {
                vc.phone = phone
                vc.country = apiCodes[countryIndex]
                vc.password = tfPassw.text
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == tfPhone) {
            tfPassw.becomeFirstResponder()
        } else if (textField == tfPassw) {
            tfPassw.resignFirstResponder()
            onVerify(btDone)
        }
        return false
    }
}

extension RegisterViewController : TTTAttributedLabelDelegate {
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }
}
