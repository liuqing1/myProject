//
//  RatingView.swift
//  fiti
//
//  Created by Matthew Mayer on 27/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import HCSStarRatingView

class RatingView: UIView {

    static var RatingViewHeight = 342.0
    static var RatingViewWidth = 310.0
    
    var booking:Booking? {
        didSet {
            updateBooking()
        }
    }
    
    var delegate:RatingViewDelegate?
    var comment:String?
    var stars:Int = 0
    var privateFeedback:String?
    var ratingView:HCSStarRatingView!
    
    @IBOutlet weak var rateTheSessionHeaderLabel: UILabel!
  
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var starRatingContainer: UIView!
    @IBOutlet weak var durationTitleLabel: UILabel!

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trainerTitleLabel: UILabel!
    @IBOutlet weak var leaveCommentButton: UIButton!
    @IBOutlet weak var trainerLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    override func awakeFromNib() {
        rateTheSessionHeaderLabel.text = "rate_the_session".localized
        priceTitleLabel.text = "price".localized
        durationTitleLabel.text = "Duration".localized
        trainerTitleLabel.text = "Trainer".localized
        instructionsLabel.text = "rate_instructions".localized
        leaveCommentButton.setTitle("share_comment".localized, forState: .Normal)
        okButton.setTitle("submit".localized, forState: .Normal)
        okButton.enabled = false
        
        let ratingView = HCSStarRatingView()
        ratingView.frame = starRatingContainer.bounds;
        ratingView.maximumValue = 5;
        ratingView.minimumValue = 0
        ratingView.value = 0
        ratingView.backgroundColor = UIColor.clearColor()
        ratingView.tintColor = UIColor.whiteColor()
        ratingView.allowsHalfStars = false;
        
        ratingView.addTarget(self, action: Selector("starsDidChange:"), forControlEvents: .ValueChanged);
        starRatingContainer.addSubview(ratingView)
        self.ratingView = ratingView
        
    }
    func updateBooking() {
        if let booking = booking {
            priceLabel.text = String(format:"¥%.02f",booking.cost)
            trainerLabel.text = booking.trainer?.name
            durationLabel.text = booking.duration.inHours()
        }
        
    }
    func starsDidChange(sender:AnyObject) {
        stars = Int(self.ratingView.value)
        okButton.enabled = true
    }
    
    @IBAction func didPressOK(sender: AnyObject) {
        if (stars>0) {
            delegate?.ratingViewDidDismiss(stars: stars, comment:comment ?? "")
        }
        
    }
    
    @IBAction func didPressLeaveComment(sender: AnyObject) {
        delegate?.ratingViewDidRequestComment()
    }
    
}
protocol RatingViewDelegate {
    func ratingViewDidDismiss(stars stars:Int, comment:String)
    func ratingViewDidRequestComment()
}
