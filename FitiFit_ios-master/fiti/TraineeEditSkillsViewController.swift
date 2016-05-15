//
//  TraineeEditSkillsViewController
//  fiti
//
//  Created by Matthew Mayer on 21/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TraineeEditSkillsViewController: BaseEditSkillsViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (section, id) in categories.enumerate() {
            for (row, skill) in Skill.allSkillsInCategory(id).enumerate() {
                if let skills=APIManager.shared.meTrainee?.skills where skills.contains(skill) {
                    collectionView.selectItemAtIndexPath(NSIndexPath(forRow: row, inSection: section), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
                }
            }
        }
        
        setLocalizedTitle("pick_your_skills".localized)
        
        
    }
    override func caption() -> String {
        return "add_your_skills_trainee".localized;
    }

    
    @IBAction func onNext() {
        let skillIds = getSelectedSkillIds()
        if (skillIds.isEmpty) {
            let alert = UIAlertController(title: "min_1_skill".localized, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return;
        }
        
        if let me = APIManager.shared.meTrainee {
            APIManager.shared.applyRealmTransaction {
                me.setSkillsByIds(skillIds)
            }
            APIManager.shared.updateTrainee(["skills":skillIds], success: {
                print("updated skills")
                }) { message in
                    print(message);
            }
            
            self.performSegueWithIdentifier("Next", sender: nil)
        }
    }
}

