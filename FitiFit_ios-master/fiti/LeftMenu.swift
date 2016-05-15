//
//  LeftMenu.swift
//  fiti
//
//  Created by Matthew Mayer on 09/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import SnapKit
class LeftMenu : UIView {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menu1Label: UILabel!
    @IBOutlet weak var menu2Label: UILabel!
    @IBOutlet weak var menu3Label: UILabel!
    @IBOutlet weak var menu4Label: UILabel!
    @IBOutlet weak var bt1: UIButton!
    @IBOutlet weak var bt2: UIButton!
    @IBOutlet weak var bt3: UIButton!
    @IBOutlet weak var bt4: UIButton!
    @IBOutlet weak var menu:UIView!;
    @IBOutlet weak var leftConstraint:NSLayoutConstraint!
    var parent:UIView?
    @IBAction func didTapButton(sender:UIButton) {
        delegate?.didTapButtonWithIndex(sender.tag)
    }
    var delegate:LeftMenuDelegate?;
    func attachTo(ncv:UIView) {
        parent = ncv
        self.translatesAutoresizingMaskIntoConstraints = false
        ncv.addSubview(self)
        self.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(ncv.snp_top)
            make.left.equalTo(ncv.snp_left)
            make.bottom.equalTo(ncv.snp_bottom)
            make.width.equalTo(ncv.snp_width)
        }
        let swiper = UISwipeGestureRecognizer(target: self, action: Selector("onSwipe"))
        swiper.direction = .Left
        self.addGestureRecognizer(swiper)
        if let me = APIManager.shared.meTrainer {
            updateProfilePic(me.getOptionalProfileImageURL())
        } else if let me = APIManager.shared.meTrainee {
            updateProfilePic(me.getOptionalProfileImageURL())
        }
        photoImageView.circle()
        

    }
    func updateProfilePic(url:NSURL?) {
        if let url = url {
            photoImageView.setImageWithURL(url, placeholderImage: R.image.avatar())
        } else {
            photoImageView.image = R.image.avatar()
        }
    }
    func onSwipe() {
        hide()
    }
    func show() {
        guard let parent = parent else {
            return
        }
        self.hidden = false
        self.leftConstraint.constant = -262
        parent.layoutIfNeeded()
        self.alpha = 0
        self.leftConstraint.constant = 0
        UIView.animateWithDuration(Constants.Values.AnimationFast, animations: {
            parent.layoutIfNeeded()
            self.alpha = 1
        })
        
    }
    func hide() {
        guard let parent = parent else {
            return
        }
        parent.layoutIfNeeded()
        self.leftConstraint.constant = -262
        self.alpha = 1
        UIView.animateWithDuration(Constants.Values.AnimationFast, animations: {
            parent.layoutIfNeeded()
            self.alpha = 0
            }, completion: { completed in
            self.hidden = true
        })
    }
    @IBAction func didDismissByTappingOnBackground() {
        hide()
    }
}
protocol LeftMenuDelegate {
    func didTapButtonWithIndex(index:Int);
}