//
//  TrainerRequestCell.swift
//  fiti
//
//  Created by Matthew Mayer on 27/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TrainerRequestCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    @IBOutlet weak var buttonPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptBtn: UIButton!
    
    @IBOutlet weak var rejectBtn: UIButton!
    
    var delegate:TrainerRequestCellDelegate?;
    var booking:Booking!
    
    let constantPaddingWithButtons:CGFloat = 86.0;
    let constantPaddingNoButtons:CGFloat = 16.0;
    
    
    var showsButtons:Bool = false {
        didSet {
            acceptBtn.hidden = !showsButtons
            rejectBtn.hidden = !showsButtons
            buttonPaddingConstraint.constant = showsButtons ? constantPaddingWithButtons : constantPaddingNoButtons
        }
    }
    
    
    @IBAction func didAccept(sender: AnyObject) {
        delegate?.didAccept(booking);
    }
    
    @IBAction func didReject(sender: AnyObject) {
        delegate?.didReject(booking)
    }
    
    override func awakeFromNib() {
        avatarImageView.clipsToBounds = true
        avatarImageView.circle()
        
    }
}
protocol TrainerRequestCellDelegate {
    func didAccept(booking:Booking);
    func didReject(booking:Booking);
}