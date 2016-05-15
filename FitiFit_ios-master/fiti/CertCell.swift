//
//  CertCell.swift
//  fiti
//
//  Created by Matthew Mayer on 21/03/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class CertCell: UITableViewCell {
    @IBOutlet var skillLabel:UILabel!
    @IBOutlet var skillImage:UIImageView!
    @IBOutlet var imageChecked:UIView!
    @IBOutlet var imagePlus:UIView!
    @IBOutlet var uploadedLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagePlus.hidden = false
        imageChecked.hidden = true
        uploadedLabel.hidden = true
        uploadedLabel.text = "Uploaded".localized;
    }
    func setUploaded(uploaded:Bool) {
        imagePlus.hidden = uploaded
        imageChecked.hidden = !uploaded
        uploadedLabel.hidden = !uploaded

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
