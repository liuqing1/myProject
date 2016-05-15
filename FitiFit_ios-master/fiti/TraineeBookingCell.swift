//
//  TraineeBookingCell.swift
//  fiti
//
//  Created by Matthew Mayer on 15/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//


import UIKit

class TraineeBookingCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    
    var booking:Booking!
    
    let constantPaddingWithButtons:CGFloat = 86.0;
    let constantPaddingNoButtons:CGFloat = 16.0;
    
    
    
    
    override func awakeFromNib() {
        avatarImageView.clipsToBounds = true
        avatarImageView.circle()
    }
}
