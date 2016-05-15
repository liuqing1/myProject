//
//  EditSummaryViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 20/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class EditSummaryViewController: RespondsToKeyboardViewController {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var bioTv: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        setLocalizedTitle("bio")
        nextBtn.setTitle("next".localized.uppercaseString, forState: .Normal)
        if let bio = APIManager.shared.meTrainer?.bio where !bio.isEmpty {
            bioTv.text = bio
            bioTv.textColor = UIColor.fitiGray()
        } else {
            bioTv.text = "tell_us".localized
            bioTv.textColor = UIColor.lightGrayColor()
        }
        bioTv.delegate = self;
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //bioTv.becomeFirstResponder()
    }
   
    @IBAction func onNext() {
        view.endEditing(true)
        let bio = bioTv.text ?? ""
        if bio != "tell_us".localized {
            if let me = APIManager.shared.meTrainer {
                APIManager.shared.applyRealmTransaction {
                    me.bio = bio
                }
                APIManager.shared.updateTrainer(["bio":bio], success: {
                    print("updated bio")
                    }) { message in
                        print(message);
                }
            }
        }
        self.performSegueWithIdentifier("Next", sender: nil)
    }
}
extension EditSummaryViewController : UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "tell_us".localized {
            textView.text = nil
            textView.textColor = UIColor.fitiGray()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "tell_us".localized
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text=="\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
