//
//  DislikeView.swift
//  fiti
//
//  Created by Matthew Mayer on 28/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class DislikeView: UIView {
    
    static var DislikeViewHeight = 410.0
    static var DislikeViewWidth = 310.0
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var reasonLabels: [UILabel]!
    @IBOutlet var reasonButtons: [UIButton]!
    @IBOutlet weak var okBtn: UIButton!
    
    var reason:Int = 0
    
    var delegate:DislikeViewDelegate?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        okBtn.setTitle("submit".localized, forState: .Normal)
        titleLabel.text = "neg_title".localized
        for i in 1...6 {
            reasonLabels[i-1].text="neg_\(i)".localized
            reasonButtons[i-1].addTarget(self, action: Selector("didTapReason:"), forControlEvents: .TouchUpInside)
            reasonButtons[i-1].tag = i
        }
        updateUI()
    }
    func didTapReason(sender:UIButton) {
        let value = sender.tag
        reason = value
        updateUI()
    }
    private func updateUI() {
        okBtn.backgroundColor = reason > 0 ? UIColor.fitiBlue() : UIColor.fitiGray()
        okBtn.enabled = reason > 0
        for i in 1...6 {
            reasonLabels[i-1].textColor = i==reason ? UIColor.fitiBlue() : UIColor.fitiGray()
        }
    }
    @IBAction func didPressOK(sender:AnyObject) {
        if (reason>0 && reason<6) {
            delegate?.dislikeViewDidGivePrivateFeedback(reasonLabels[reason-1].text ?? "")
        } else if (reason==6) {
            delegate?.dislikeViewDidRequestCustomFeedback()
        }
    }

}
protocol DislikeViewDelegate {
    func dislikeViewDidGivePrivateFeedback(privateFeedback:String)
    func dislikeViewDidRequestCustomFeedback()
}
