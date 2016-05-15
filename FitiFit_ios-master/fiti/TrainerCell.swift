//
//  TrainerCell.swift
//  fiti
//
//  Created by Matthew Mayer on 22/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit

class TrainerCell: UITableViewCell {
    var trainer:Trainer? {didSet { updateUI() }}
    var trainerView:TrainerView?
    override func awakeFromNib() {
        super.awakeFromNib()
        trainerView = contentView.embedFromNIB("TrainerView") as? TrainerView
        layoutMargins = UIEdgeInsetsZero
    }
    func updateUI() {
        if let trainerView = trainerView, trainer = trainer {
            trainerView.trainer = trainer
        }
        
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   

}
