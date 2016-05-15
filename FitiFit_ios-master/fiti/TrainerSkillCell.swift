//
//  TrainerSkillCell.swift
//  fiti
//
//  Created by Tuo on 1/6/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import UIKit

class TrainerSkillCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    private var image: UIImage?
    private var imageSelected: UIImage?

    var skill:Skill? {
        didSet {
            render()
        }
    }
    override func awakeFromNib() {
        iconImgView.tintColor = UIColor.fitiBlue()
        render()
    }

    func render() {
        if let skill = skill {
            nameLabel.text = skill.localizedName()
            let skillIconName = skill.icon
            let skillIconNameActive = skill.icon!.stringByAppendingString("-active")
            image = UIImage(named: skillIconName ?? "")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            imageSelected = UIImage(named: skillIconNameActive ?? "")
            
            iconImgView.image = selected ? imageSelected : image
            
        }
    }

    override var selected: Bool {
        didSet {
            render()
        }
    }

    override func prepareForReuse() {
        iconImgView.image = nil
        nameLabel.text = nil
        selected = false
    }



}