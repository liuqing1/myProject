//
//  TrainerDetailsView.swift
//  fiti
//
//  Created by Matthew Mayer on 16/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import SnapKit

import MapKit

class TrainerDetailsView: UIView {
    //views
    @IBOutlet weak var aboutMeTitleLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var videoPlaceholderView: UIView!
    @IBOutlet weak var benefitsLabel: UILabel!
    @IBOutlet weak var benefitsTitleLabel: UILabel!
    @IBOutlet weak var musclesLabel: UILabel!
    @IBOutlet weak var videoPosterImageView: UIImageView!
    @IBOutlet weak var playIcon:UIImageView!
    @IBOutlet weak var mapViewImage: UIImageView!
    @IBOutlet weak var skillsView: UICollectionView!
    @IBOutlet weak var bigPinIcon: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var musclesTitleLabel: UILabel!
    @IBOutlet weak var skillsTitleLabel: UILabel!
    //constraints
    @IBOutlet weak var aboutMeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var skillsDetailHeightConstraint: NSLayoutConstraint!
    var strongHeightConstraint:NSLayoutConstraint!
    var userLocation: CLLocationCoordinate2D?  {didSet { updateUI() }}
    
    var delegate:TrainerDetailsViewDelegate?
    

    let CellIdentifier = "TrainerSkillCell"
    
    var owner:UIViewController?;
    var trainer:Trainer? {
        didSet {
            if (trainer != oldValue) {
                updateUI()
            }
        }
    }
 
    override  func awakeFromNib() {
        super.awakeFromNib()
        aboutMeTitleLabel.text = "About Me".localized
        readMoreButton.setTitle("Read more".localized.uppercaseString, forState: .Normal)
        skillsTitleLabel.text = "skills".localized

        let nib = UINib(nibName: "TrainerSkillCell", bundle: nil)
        skillsView.registerNib(nib, forCellWithReuseIdentifier: CellIdentifier)
        skillsView.backgroundColor = UIColor.clearColor()
        musclesTitleLabel.text = "muscles_worked".localized
        let tapper = UITapGestureRecognizer()
        tapper.addTarget(self, action: Selector("tapVideo"))
        self.videoPlaceholderView.gestureRecognizers = [tapper]
        
        strongHeightConstraint = aboutMeHeightConstraint
        
        skillsDetailHeightConstraint.constant = 0.1
    }

    private func toBullets(string:String)->String {
        let lines:[String] = string.componentsSeparatedByString("\n");
        let linesPreceededByBullets:[String] = lines.map { line -> String in
            return "•\t\(line)\n"
        }
        return (linesPreceededByBullets as NSArray).componentsJoinedByString("");
    }
    private func formattedBio(trainer:Trainer)->NSAttributedString {
        let string = NSMutableAttributedString()
        
    
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.paragraphSpacingBefore = 8
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .Center
        
        let paragraphStyleTitle = NSMutableParagraphStyle()
        paragraphStyleTitle.paragraphSpacing = 8
        paragraphStyleTitle.paragraphSpacingBefore = 16
        paragraphStyleTitle.lineSpacing = 8
        paragraphStyleTitle.alignment = .Center
        
        let paragraphStyleBullets = NSMutableParagraphStyle()
        paragraphStyleBullets.tabStops = [NSTextTab(textAlignment: .Left, location: 15, options: [:])];
        paragraphStyleBullets.defaultTabInterval = 15;
        paragraphStyleBullets.firstLineHeadIndent = 0;
        paragraphStyleBullets.headIndent = 15;
        paragraphStyleBullets.paragraphSpacing = 4
        paragraphStyleBullets.paragraphSpacingBefore = 4
        
        
        let mainFont = UIFont(name: Constants.Fonts.MonsterratLight, size: 15)!
        let titleFont = UIFont(name: Constants.Fonts.MonsterratRegular, size: 14)!
        let textFont = UIFont(name: Constants.Fonts.MonsterratRegular, size: 14)!

        let mainAttribs = [NSFontAttributeName:mainFont,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:UIColor.fitiGray()];
        
        let titleAttribs = [NSFontAttributeName:titleFont,NSParagraphStyleAttributeName:paragraphStyleTitle,NSForegroundColorAttributeName:UIColor.fitiBlue()];
        
        let bulletStyle = [NSFontAttributeName:textFont,NSForegroundColorAttributeName:UIColor.fitiLightGray(), NSParagraphStyleAttributeName:paragraphStyleBullets];

        string.appendAttributedString(NSAttributedString(string: "\(trainer.bio)\n", attributes: mainAttribs))

        
        string.appendAttributedString(NSAttributedString(string: "certifications".localized+"\n", attributes: titleAttribs))
        string.appendAttributedString(NSAttributedString(string: toBullets(trainer.qualifications), attributes: bulletStyle))

        
        string.appendAttributedString(NSAttributedString(string: "education".localized+"\n", attributes: titleAttribs))
        string.appendAttributedString(NSAttributedString(string: toBullets(trainer.education), attributes: bulletStyle))
        
        string.appendAttributedString(NSAttributedString(string: "experience".localized+"\n", attributes: titleAttribs))
        string.appendAttributedString(NSAttributedString(string: toBullets(trainer.experience), attributes: bulletStyle))
        
        return string;
    }
    internal func updateUI() {
        guard let trainer = trainer else {
            return;
        }
        aboutMeLabel.attributedText = formattedBio(trainer)

        if let firstSkill = trainer.skills.first {
            benefitsLabel.text = firstSkill.localizedDesciption()
            musclesLabel.text = firstSkill.localizedMuscles()
            benefitsTitleLabel.text = String(format:"benefit_of_x".localized, firstSkill.localizedName() ?? "")
            bigPinIcon.image = firstSkill.pinImageSelected(true)
        }
        
        videoPlaceholderView.backgroundColor = UIColor.clearColor()
        playIcon.hidden = true
//        if let url = NSURL(string: trainer.videoPosterURL) {
//            let req = NSURLRequest(URL: url)
//            self.videoPosterImageView.setImageWithURLRequest(req, placeholderImage: UIImage(named: "video-library"), success: {req, res, im in
//                    self.videoPosterImageView.image = im;
//                    self.playIcon.hidden = false
//                }, failure: nil);
//            
//        }
        self.videoPosterImageView.image = UIImage(named: "video-library");
        self.playIcon.hidden = false
        skillsView.reloadData()

        let options = MKMapSnapshotOptions()
        options.region = MKCoordinateRegionMakeWithDistance(trainer.coordinate(), 1000, 1000)
        options.size = mapViewImage.bounds.size
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler { snapshot, err in
            self.mapViewImage.image = snapshot?.image
        }
        
        
        if let userLocation = userLocation {
            let distance = CLLocation.distance(from: userLocation, to:trainer.coordinate());
            distanceLabel.text = String(format: "km".localized, distance/1000);
            addressLabel.text = "getting_address".localized
            MapUtils.reverseGeocodeLocation(CLLocation(latitude: trainer.coordinate().latitude, longitude: trainer.coordinate().longitude)){
                (address: String) -> Void in
                self.addressLabel.text = address
            }
        } else {
            distanceLabel.text = " ";
        }
        
        
        
    }

    @IBAction func tapReadMore() {
        strongHeightConstraint.active = !strongHeightConstraint.active
        if (strongHeightConstraint.active) {
            readMoreButton.setTitle("Read more".localized.uppercaseString, forState: .Normal)
            delegate?.trainerDetailsViewDidCloseAboutUs()
        } else {
            readMoreButton.setTitle("Close".localized.uppercaseString, forState: .Normal)
        }
    }
    func tapVideo() {
        guard let delegate = delegate, trainer = trainer, url = NSURL(string:trainer.videoURL) else {
            return
        }
        delegate.trainerDetailsViewDidLaunchVideo(url)
    }

}

extension TrainerDetailsView : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let trainer = trainer {
            return Int(trainer.skills.count)
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! TrainerSkillCell
        if let trainer = trainer {
            cell.skill = trainer.skills[indexPath.row]
        }
        return cell
    }
}

extension TrainerDetailsView : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        skillsDetailHeightConstraint.constant = 220
        if let trainer = trainer {
            let skill = trainer.skills[indexPath.row]
            
            benefitsLabel.text = skill.localizedDesciption()
            musclesLabel.text = skill.localizedMuscles()
            benefitsTitleLabel.text = String(format:"benefit_of_x".localized, skill.localizedName() ?? "")
            
        }
    }

}
protocol TrainerDetailsViewDelegate {
    func trainerDetailsViewDidLaunchVideo(url:NSURL);
    func trainerDetailsViewDidCloseAboutUs();
}

 