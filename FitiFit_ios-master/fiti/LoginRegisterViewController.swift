//
//  LoginRegisterViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 08/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class LoginRegisterViewController: BaseViewController {
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        
        skipButton.setTitle("skip_for".localized, forState: .Normal)
        registerButton.setTitle("register".localized.uppercaseString, forState: .Normal)
        loginButton.setTitle("sign_in".localized.uppercaseString, forState: .Normal)
        sloganLabel.text = "slogan".localized
        
        
        logoImage.image = Util.isChinese() ? R.image.logoZh() : R.image.logo()
       
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (APIManager.shared.cachedLogin()) {
            FitiLoadingHUD.showHUDForView(view, text: "")
        }
        hideNavBar()
    }
    override func viewDidAppear(animated: Bool) {
        if (APIManager.shared.cachedLogin()) {
            if let _ = APIManager.shared.meTrainer {
                self.performSegueWithIdentifier("CachedTrainerLogin", sender: nil);
            } else if let _ = APIManager.shared.meTrainee {
                self.performSegueWithIdentifier("CachedTraineeLogin", sender: nil);
            }
            FitiLoadingHUD.hide()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
