//
//  TrainerView.swift
//  fiti
//
//  Created by Matthew Mayer on 15/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import MapKit;
import AFNetworking;
import HCSStarRatingView;

class TrainerView: UIView {
    var trainer:Trainer? {didSet {
        if (trainer != oldValue) {
            updateUI()
        }
    }}
    var userLocation: CLLocationCoordinate2D?  {didSet { updateUI() }}
    @IBOutlet weak var nameLabel:UILabel!;
    @IBOutlet weak var skillsLabel:UILabel!;
    @IBOutlet weak var timeLabel:UILabel!;
    @IBOutlet weak var timeTitleLabel:UILabel!;
    
    @IBOutlet weak var priceLabel:UILabel!;
    @IBOutlet weak var distanceLabel:UILabel!;
    @IBOutlet weak var locationLabel:UILabel!;
    @IBOutlet weak var imageView:UIImageView!;
    
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    
    @IBOutlet weak var ratingViewContainer: UIView!
    var ratingView:HCSStarRatingView!
    override  func awakeFromNib() {
        super.awakeFromNib()
        distanceTitleLabel.text = "Distance".localized
        priceTitleLabel.text = "Per hour".localized
        timeTitleLabel.text = "by_drive".localized
        nameLabel.text = " "
        skillsLabel.text = " "
        priceLabel.text = " "
        locationLabel.text = " "
        distanceLabel.text = " "
        timeLabel.text = " "
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        
        ratingView = HCSStarRatingView()
        ratingView.frame = ratingViewContainer.bounds;
        ratingView.maximumValue = 5;
        ratingView.minimumValue = 0

        ratingView.backgroundColor = UIColor.clearColor()
        ratingView.emptyStarImage = R.image.starEmpty()
        ratingView.filledStarImage = R.image.starFilled()
        ratingView.allowsHalfStars = true
        ratingView.accurateHalfStars = true
        ratingView.userInteractionEnabled = false
        ratingViewContainer.addSubview(ratingView)
    }



    func updateUI() {
        guard let trainer = trainer else {
            return;
        }
        nameLabel.text = trainer.name;
        skillsLabel.text = trainer.localizedSkillList()
        priceLabel.text = "¥\(trainer.price)"
        ratingView.value = CGFloat(trainer.averageRating)
        if let userLocation = userLocation {
            let distance = CLLocation.distance(from: userLocation, to:trainer.coordinate());
            distanceLabel.text = String(format: "km".localized, distance/1000);
            timeLabel.text = String(format: "%.0f mins".localized, distance/800); // driving pace 30mph = 800metres/minute approx 
            
        } else {
            distanceLabel.text = "-"
        }
        locationLabel.text = trainer.getFriendlyLocation()
        if let url = trainer.getOptionalProfileImageURL() {
            imageView.image = nil;
            imageView.setImageWithURL(url, placeholderImage: R.image.avatar())
        } else {
            imageView.image = R.image.avatar()
        }
    }
}
