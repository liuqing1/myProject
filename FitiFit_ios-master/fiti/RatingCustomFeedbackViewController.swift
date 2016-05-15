//
//  RatingCustomFeedbackViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 28/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class RatingCustomFeedbackViewController: RespondsToKeyboardViewController {
    @IBOutlet weak var doneBtn:UIButton!
    @IBOutlet weak var textView:UITextView!
    var delegate:RatingCustomFeedbackViewControllerDelegate?
    override func viewDidLoad() {
        theme = .Blue
        super.viewDidLoad()
        setLocalizedTitle("give_feedback")
        themeRightButton()
        doneBtn.enabled = false
        doneBtn.setTitle("submit".localized, forState: .Normal)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onCancel(sender:AnyObject) {
        textView.resignFirstResponder()
        delegate?.ratingCustomFeedbackViewControllerDidCancel()
    }
    @IBAction func onDone(sender:AnyObject?) {
        textView.resignFirstResponder()
        delegate?.ratingCustomFeedbackViewControllerDidSubmitPrivateFeedback(textView.text)
    }

}
extension RatingCustomFeedbackViewController : UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        doneBtn.enabled = !textView.text.isEmpty
        if text=="\n" {
            if (!textView.text.isEmpty) {
                onDone(nil)
            }
            return false
        }
        return true
    }
}
protocol RatingCustomFeedbackViewControllerDelegate {
    func ratingCustomFeedbackViewControllerDidCancel()
    func ratingCustomFeedbackViewControllerDidSubmitPrivateFeedback(privateFeedback:String)
}
