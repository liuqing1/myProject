//
//  TutorialStepTwoViewController.swift
//  fiti
//
//  Created by Daniel Contreras on 4/6/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TutorialStepTwoViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let animationDuration:NSTimeInterval = 0.8
    let targetBottomConstraint:CGFloat = 0
    let characterSpacing:CGFloat = 1
    let lineSpacing:CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        descriptionLabel.setCharacterSpacing(characterSpacing)
        descriptionLabel.setLineSpacing(lineSpacing)
        titleLabel.setCharacterSpacing(characterSpacing)
        titleLabel.setLineSpacing(lineSpacing)
        descriptionLabel.textAlignment = .Center
        titleLabel.textAlignment = .Center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        bottomConstraint.constant = targetBottomConstraint //target for constraint value
        
        UIView.animateWithDuration(animationDuration, delay:0, options:[.CurveEaseOut], animations: {
            self.view.layoutIfNeeded() //this causes the animation to be updated each frame
            }, completion: { completed in
                //animation is done
        })
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
