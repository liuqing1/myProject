//
//  EditEducationViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 22/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class EditEducationViewController: RespondsToKeyboardViewController {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var schoolTF: UITextField!
    @IBOutlet weak var admissionTF: UITextField!
    @IBOutlet weak var deptTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedTitle("education")
        theme = .White

        nextBtn.setTitle("next".localized.uppercaseString, forState: .Normal)
       
        schoolTF.placeholder = "school".localized
        admissionTF.placeholder = "admission".localized
        deptTF.placeholder = "department".localized
        
        schoolTF.delegate = self
        admissionTF.delegate = self
        deptTF.delegate = self
        
        let trainer = APIManager.shared.meTrainer
        
        schoolTF.text = trainer?.school
        admissionTF.text = trainer?.admission
        deptTF.text = trainer?.department
        
    }
   
    
    @IBAction func onNext() {
        view.endEditing(true)
        
        let school = schoolTF.text ?? ""
        let dept = deptTF.text ?? ""
        let admission = admissionTF.text ?? ""
        
        let fields = ["school":school, "department":dept, "admission":admission]
        
        if let me = APIManager.shared.meTrainer {
            APIManager.shared.applyRealmTransaction {
                me.school = school
                me.department = dept
                me.admission = admission
            }
            APIManager.shared.updateTrainer(fields, success: {
                print("updated education")
                }) { message in
                    print(message);
            }
            
            self.performSegueWithIdentifier("Next", sender: nil)
        }
    }
}
extension EditEducationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == schoolTF) {
            admissionTF.becomeFirstResponder()
        }
        if (textField == admissionTF) {
            deptTF.becomeFirstResponder()
        }
        if (textField == deptTF) {
            onNext()
        }
        return false
    }
}
