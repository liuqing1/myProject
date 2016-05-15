//
//  EditSkillsViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 21/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class BaseEditSkillsViewController: BaseViewController {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let CellIdentifier = "TrainerSkillCell"
    let categories = Skill.allCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        
        
        nextBtn.setTitle("next".localized.uppercaseString, forState:.Normal)
        let nib = UINib(nibName: "TrainerSkillCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: CellIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        
        
        
    }
    func getSelectedSkillIds()->[String] {
        var skillIds:[String] = []
        let indexPaths = collectionView.indexPathsForSelectedItems() ?? []
        for indexPath in indexPaths {
            if let skillid = Skill.allSkillsInCategory(categories[indexPath.section])[indexPath.row].id {
                skillIds.append(skillid)
            }
        }
        return skillIds
    }
    func caption()->String {
        return "-"
    }
    
}
extension BaseEditSkillsViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(Skill.allSkillsInCategory(categories[section]).count)
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return categories.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! TrainerSkillCell
        let skills =  Skill.allSkillsInCategory(categories[indexPath.section])
        let skill = skills[indexPath.row]
        cell.skill = skill
        return cell
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind==UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TrainerSkillsHeader", forIndexPath: indexPath) as! TrainerSkillsHeader
            let cat = categories[indexPath.section]
            view.label.text = "skill-cat-\(cat)".localized
            let isFirst =  indexPath.section == 0
            view.checkmark.hidden = !isFirst
            view.instructions.hidden = !isFirst
            view.instructions.attributedText = NSAttributedString(string:caption(), attributes:Constants.Attributes.getFitiSpacedStyle())
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TrainerSkillsFooter", forIndexPath: indexPath)
            return view
        }
    }
}

extension BaseEditSkillsViewController : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("did select: \(indexPath.row)")
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(0, section==0 ? 220 : 60)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(0, section==categories.count-1 ? 60 : 0)
    }
    
}
