//
//  ChooseDistrictCell.swift
//  fiti
//
//  Created by Tuo on 1/18/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import UIKit

class ChooseDistrictCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        locationLabel.textColor = selected ? UIColor.fitiBlue() : UIColor.colorWithHexString("CACAD2")
    }


    override func prepareForReuse() {
        locationLabel.text = nil
    }
}