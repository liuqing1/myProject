//
//  TrainerCompleteProfileViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 19/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import Toucan
class TrainerCompleteProfileViewController: RespondsToKeyboardViewController {
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var nameTf: UITextField!
    
    var male:Bool = true
    
    var picker:UIImagePickerController?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var radioFLabel: UILabel!
    @IBOutlet weak var radioMLabel: UILabel!
    @IBOutlet weak var radioFImage: UIImageView!
    @IBOutlet weak var radioMImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        setLocalizedTitle("create_a_profile".localized)
        nextBtn.setTitle("next".localized.uppercaseString, forState: UIControlState.Normal)
        nameTf.text = APIManager.shared.meTrainer?.name
        radioMLabel.text = "male".localized
        radioFLabel.text = "female".localized
        if (APIManager.shared.meTrainer?.gender=="M") {
            onMale(nil)
        } else {
            onFemale(nil)
        }
        nameTf.delegate = self
        
        profileImageView.circle()
        if let me = APIManager.shared.meTrainer {
            if let url = me.getOptionalProfileImageURL() {
                profileImageView.setImageWithURL(url, placeholderImage: R.image.avatar())
            } else {
                profileImageView.image = nil
            }
        }
    }
    @IBAction func onMale(sender: AnyObject?) {
        male = true
        updateGenderUI();
    }
    @IBAction func onProfile(sender: AnyObject?) {
        let sheet = UIAlertController(title: "choose_profile".localized, message: "", preferredStyle: .ActionSheet)
        sheet.addAction(UIAlertAction(title: "Take Photo".localized, style: .Default, handler: { action in
            self.gotoPicker(false);
        }))
        sheet.addAction(UIAlertAction(title: "Choose Existing".localized, style: .Default, handler: { action in
            self.gotoPicker(true);
        }))
        sheet.addAction(UIAlertAction(title: "cancel".localized, style: .Cancel, handler: { action in
            
        }))
        
        presentViewController(sheet, animated: true, completion: nil)
    }
    func gotoPicker(existing:Bool) {
        if (existing) {
            
            if (UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)) {
                let p = UIImagePickerController()
                p.sourceType = .PhotoLibrary
                p.allowsEditing = true
                p.delegate = self
                self.presentViewController(p, animated: true, completion: nil)
                picker = p
            }
            
        } else {
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                let p = UIImagePickerController()
                p.sourceType = .Camera
                p.allowsEditing = true
                p.cameraDevice = .Front
                p.delegate = self
                self.presentViewController(p, animated: true, completion: nil)
                picker = p
            }
        }
    }
    @IBAction func onFemale(sender: AnyObject?) {
        male = false
        updateGenderUI();
    }
    func updateGenderUI() {
        radioMImage.highlighted = male
        radioFImage.highlighted = !male
        radioMLabel.textColor = male ? UIColor.grayColor() : UIColor.lightGrayColor()
        radioFLabel.textColor = !male ? UIColor.grayColor() : UIColor.lightGrayColor()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar()
    }
    @IBAction func onNext() {
        self.view.endEditing(true)
        
        if profileImageView.image == nil {
            let alert = UIAlertController(title: "upload_profile_picture".localized, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        let name = nameTf.text ?? ""
        let gender = (male ? "M" : "F")
        if let me = APIManager.shared.meTrainer {
            APIManager.shared.applyRealmTransaction {
                me.name = name
                me.gender = gender
            }
            APIManager.shared.updateTrainer(["name":name, "gender": gender], success: {
                print("updated name")
                }) { message in
                    print(message);
            }
            let isBigCity:Bool = me.isBigCity()
            self.performSegueWithIdentifier(isBigCity ? "Next" : "SkipLocation", sender: nil)
        }
        
    }
    override func onKeyboardDidShow(notification : NSNotification) {
        super.onKeyboardDidShow(notification)
        scrollView.scrollRectToVisible(CGRectMake(0,250,1,1), animated: true)
    }
}
extension TrainerCompleteProfileViewController:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
extension TrainerCompleteProfileViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage, me = APIManager.shared.meTrainer {
            profileImageView.image = img
            
            let apiimg = Toucan(image: img).resize(CGSize(width: 240, height: 240)).image
            APIManager.shared.uploadImage(apiimg, success: { profile in
                APIManager.shared.applyRealmTransaction({
                    me.profile = profile
                })
                print("success")
                }, error: { msg in
                print("error")
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}