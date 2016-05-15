//
//  TrainerUpcomingBookingCell.swift
//  fiti
//
//  Created by Matthew Mayer on 26/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TrainerUpcomingBookingCell: UITableViewCell {
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nextDot: UIImageView!
    override func awakeFromNib() {
        descLabel.text = ""
        timeLabel.text = ""
        nextDot.hidden = true
    }
    

}
