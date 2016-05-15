//
//  RequireLoginAlert.swift
//  fiti
//
//  Created by Matthew Mayer on 22/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class RequireLoginAlert {
    static func presentTraineeLoginAlert(vc:UIViewController, segueIdentifier:String) {
        let alert = UIAlertController(title: "not_member".localized, message: nil, preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .Cancel, handler: { action in
            print("cancel")
        }))
        alert.addAction(UIAlertAction(title: "register".localized, style: .Default, handler: { action in
            APIManager.shared.logout()
            vc.performSegueWithIdentifier(segueIdentifier, sender: nil)
        }))
        vc.presentViewController(alert, animated: true, completion: nil)
    }
}
