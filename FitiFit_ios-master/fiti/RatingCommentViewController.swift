//
//  RatingCommentViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 28/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class RatingCommentViewController: RespondsToKeyboardViewController {
    @IBOutlet weak var doneBtn:UIButton!
    @IBOutlet weak var textView:UITextView!
    var comment:String?
    var delegate:RatingCommentViewControllerDelegate?
    override func viewDidLoad() {
        theme = .Blue
        super.viewDidLoad()
        setLocalizedTitle("share_comment")
        themeRightButton()
        doneBtn.setTitle("submit".localized, forState: .Normal)
        textView.text = comment ?? ""
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
        delegate?.ratingCommentViewControllerDidCancel()
    }
    @IBAction func onDone(sender:AnyObject?) {
        textView.resignFirstResponder()
        delegate?.ratingCommentViewControllerDidSubmitComment(textView.text)
    }
   

}
extension RatingCommentViewController : UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text=="\n" {
            if (!textView.text.isEmpty) {
                onDone(nil)
            }
            return false
        }
        return true
    }
}
protocol RatingCommentViewControllerDelegate {
    func ratingCommentViewControllerDidCancel()
    func ratingCommentViewControllerDidSubmitComment(comment:String)
}
